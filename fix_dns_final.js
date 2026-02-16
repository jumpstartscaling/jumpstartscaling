const https = require('https');

const TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG";
const ZONE_NAME = "jumpstartscaling.com";
const TARGET_IP = "150.136.117.198";

// COMPLETE LIST of all subdomains to migrate to Oracle Cloud
const SUBDOMAINS = [
    // Previously Tunnel CNAMEs
    'n8n', 'api', 'ai', 'cms', 'godmode', 'cockpit',
    'reaper', 'reaper-api', 'no', 'ion', 'ion-api', 'ion-ai',
    'chrisamaya.work', '*', 'www',

    // Previously Legacy A Records (pointing to 72.61.15.216)
    'app', 'b', 'connect', 'core', 'egg', 'gitthis', 'god',
    'green', 'hero', 'jjj', 'launch', 'net1', 'nocore',
    'office', 'red', 'solar', 'spark', 'universe'
];

async function request(method, path, data = null) {
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
            res.on('data', c => body += c);
            res.on('end', () => {
                try {
                    resolve(JSON.parse(body || '{}'));
                } catch (e) { resolve({}); }
            });
        });
        req.on('error', e => reject(e));
        if (data) req.write(JSON.stringify(data));
        req.end();
    });
}

async function main() {
    console.log("🔍 Fetching Zone...");
    const z = await request('GET', `/zones?name=${ZONE_NAME}`);
    const zoneId = z.result?.[0]?.id;
    if (!zoneId) return console.error("❌ Zone not found");
    console.log(`✅ Zone ID: ${zoneId}`);

    console.log("🔍 Fetching All Records...");
    const r = await request('GET', `/zones/${zoneId}/dns_records?per_page=100`);
    const records = r.result || [];

    // 1. Fix Root (@) - Always A
    const root = records.find(x => x.name === ZONE_NAME);
    if (root) {
        if (root.type === 'CNAME') {
            await request('DELETE', `/zones/${zoneId}/dns_records/${root.id}`);
            await request('POST', `/zones/${zoneId}/dns_records`, {
                type: 'A', name: ZONE_NAME, content: TARGET_IP, proxied: true
            });
            console.log("✅ Root Fixed to A.");
        } else if (root.content !== TARGET_IP) {
            await request('PUT', `/zones/${zoneId}/dns_records/${root.id}`, {
                type: 'A', name: ZONE_NAME, content: TARGET_IP, proxied: true
            });
            console.log("✅ Root IP Updated.");
        } else {
            console.log("✅ Root is correct.");
        }
    } else {
        await request('POST', `/zones/${zoneId}/dns_records`, {
            type: 'A', name: ZONE_NAME, content: TARGET_IP, proxied: true
        });
    }

    // 2. Fix Subdomains -> Force A Record
    for (const sub of SUBDOMAINS) {
        const expectedName = sub === '*' ? `*.${ZONE_NAME}` : `${sub}.${ZONE_NAME}`;
        const existing = records.find(x => x.name === expectedName);

        if (existing) {
            // Needs update if:
            // 1. Not Type A
            // 2. Not pointing to Target IP
            const needsUpdate = existing.type !== 'A' || existing.content !== TARGET_IP;

            if (needsUpdate) {
                console.log(`🔄 Updating ${sub} to A Record (${TARGET_IP})...`);
                if (existing.type !== 'A') {
                    // Change Type requires Delete/Create (safe default)
                    await request('DELETE', `/zones/${zoneId}/dns_records/${existing.id}`);
                    await request('POST', `/zones/${zoneId}/dns_records`, {
                        type: 'A', name: sub, content: TARGET_IP, proxied: true
                    });
                } else {
                    await request('PUT', `/zones/${zoneId}/dns_records/${existing.id}`, {
                        type: 'A', name: sub, content: TARGET_IP, proxied: true
                    });
                }
            } else {
                console.log(`✅ ${sub} is correct.`);
            }
        } else {
            console.log(`🔨 Creating ${sub} as A Record...`);
            await request('POST', `/zones/${zoneId}/dns_records`, {
                type: 'A', name: sub, content: TARGET_IP, proxied: true
            });
        }
    }

    console.log("🎉 FULL ZONE OVERRIDE COMPLETE - ALL RECORDS POINT TO 150.136.117.198");
}

main().catch(console.error);
