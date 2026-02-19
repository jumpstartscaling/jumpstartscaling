const net = require('net');

const HOST = '150.136.117.198';
// Ports Cloudflare supports:
// HTTP: 80, 8080, 8880, 2052, 2082, 2086, 2095
// HTTPS: 443, 2053, 2083, 2087, 2096, 8443
const PORTS = [80, 443, 8080, 8443, 2052, 2053, 2082, 2083, 2086, 2087, 2095, 2096, 8880];

console.log(`Scanning ${HOST} for open Cloudflare-compatible ports...`);

async function checkPort(port) {
    return new Promise((resolve) => {
        const socket = new net.Socket();
        socket.setTimeout(2000); // 2s timeout

        socket.on('connect', () => {
            console.log(`[PASS] Port ${port} is OPEN!`);
            socket.destroy();
            resolve(port);
        });

        socket.on('timeout', () => {
            console.log(`[FAIL] Port ${port} timed out.`);
            socket.destroy();
            resolve(null);
        });

        socket.on('error', (err) => {
            // connection resused usually means firewall active/reject packet, or no listener
            // but if we get "refused", it implies the PACKET got there and was rejected by OS.
            // which means the FIREWALL IS OPEN but nothing is listening?
            // "timed out" usually means DROP (Firewall blocked).
            console.log(`[FAIL] Port ${port} error: ${err.message}`);
            resolve(null);
        });

        socket.connect(port, HOST);
    });
}

async function scan() {
    const results = [];
    for (const port of PORTS) {
        const openPort = await checkPort(port);
        if (openPort) results.push(openPort);
    }

    console.log("\n--- SUMMARY ---");
    if (results.length > 0) {
        console.log(`FOUND OPEN PORTS: ${results.join(', ')}`);
        console.log("Recommend switching Nginx to one of these.");
    } else {
        console.log("No common Cloudflare ports appear open.");
    }
}

scan();
