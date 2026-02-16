#!/bin/bash
# Add DNS record for Coolify UI access

ZONE_ID="f1e606b93260b3e12a939612c12c6370"
TOKEN="A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
SERVER_IP="150.136.117.198"

echo "Adding DNS record for coolify.jumpstartscaling.com..."

python3 << PY
import requests

ZONE_ID = "${ZONE_ID}"
TOKEN = "${TOKEN}"
IP = "${SERVER_IP}"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

# Delete existing coolify record if any
resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?name=coolify.jumpstartscaling.com", headers=HEADERS)
for r in resp.json().get('result', []):
    requests.delete(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records/{r['id']}", headers=HEADERS)
    print(f"Deleted old record: {r['type']}")

# Create A record pointing to server IP
resp = requests.post(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records", headers=HEADERS, json={
    "type": "A",
    "name": "coolify.jumpstartscaling.com",
    "content": IP,
    "proxied": False,  # Direct connection for now
    "ttl": 1
})

if resp.status_code == 200:
    print(f"✓ Created DNS: coolify.jumpstartscaling.com -> {IP}")
else:
    print(f"✗ Error: {resp.text}")
PY

echo ""
echo "DNS updated. You can access Coolify at:"
echo "  http://coolify.jumpstartscaling.com:8000"
echo "  or"
echo "  http://150.136.117.198:8000"
