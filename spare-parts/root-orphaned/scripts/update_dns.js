const https = require('https');
const fs = require('fs');

const TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG";
const ZONE_NAME = "jumpstartscaling.com";
const TARGET_IP = "150.136.117.198";
const LOG_FILE = "/tmp/dns_status.log";

function log(msg) {
    console.log(`[DNS] ${msg}`);
    try { fs.appendFileSync(LOG_FILE, `[DNS] ${msg}\n`); } catch (e) { }
}

function request(method, path, data = null) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'api.cloudflare.com',
            port: 443,
            path: '/client/v4' + path,
            method: method,
            headers: {
                'Authorization': `Bearer ${TOKEN}`,
                'Content-Type': 'application/json'
            }
        };

        const req = https.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                try {
                    resolve(JSON.parse(body));
                } catch (e) {
                    resolve({ success: false, errors: [{ message: "Invalid JSON response" }] });
                }
            });
        });

        req.on('error', (e) => {
            log(`Request Error: ${e.message}`);
            resolve(null);
        });

        if (data) {
            req.write(JSON.stringify(data));
        }
        req.end();
    });
}

async function main() {
    log("Starting Node.js DNS Update...");

    // 1. Get Zone ID
    const zoneData = await request('GET', `/zones?name=${ZONE_NAME}`);
    if (!zoneData || !zoneData.success || zoneData.result.length === 0) {
        log(`FATAL: Could not find zone. Errors: ${JSON.stringify(zoneData?.errors)}`);
        return;
    }
    const zoneId = zoneData.result[0].id;
    log(`Found Zone ID: ${zoneId}`);

    // 2. Get Records
    const recordsData = await request('GET', `/zones/${zoneId}/dns_records`);
    const records = recordsData?.result || [];

    let rootRecord = records.find(r => r.name === ZONE_NAME);
    let wwwRecord = records.find(r => r.name === `www.${ZONE_NAME}`);

    // 3. Update Root
    if (rootRecord) {
        if (rootRecord.type === 'CNAME') {
            log("Root is CNAME. Deleting...");
            await request('DELETE', `/zones/${zoneId}/dns_records/${rootRecord.id}`);
            log("Creating new A Record...");
            await request('POST', `/zones/${zoneId}/dns_records`, {
                type: 'A', name: ZONE_NAME, content: TARGET_IP, proxied: true
            });
        } else {
            log("Updating Root A Record...");
            await request('PUT', `/zones/${zoneId}/dns_records/${rootRecord.id}`, {
                type: 'A', name: ZONE_NAME, content: TARGET_IP, proxied: true
            });
        }
    } else {
        log("Creating Root A Record...");
        await request('POST', `/zones/${zoneId}/dns_records`, {
            type: 'A', name: ZONE_NAME, content: TARGET_IP, proxied: true
        });
    }

    // 4. Update WWW
    if (wwwRecord) {
        log("Updating WWW CNAME...");
        await request('PUT', `/zones/${zoneId}/dns_records/${wwwRecord.id}`, {
            type: 'CNAME', name: 'www', content: ZONE_NAME, proxied: true
        });
    } else {
        log("Creating WWW CNAME...");
        await request('POST', `/zones/${zoneId}/dns_records`, {
            type: 'CNAME', name: 'www', content: ZONE_NAME, proxied: true
        });
    }

    log("DNS Update Completed Successfully.");
}

main();
