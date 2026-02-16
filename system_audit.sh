#!/bin/bash
set -e

echo "==================================================="
echo "COMPREHENSIVE SYSTEM AUDIT"
echo "==================================================="

SERVER="opc@150.136.117.198"
SSH_KEY="~/.ssh/id_rsa"

echo ""
echo "1. CLOUDFLARE TUNNEL ID VERIFICATION"
echo "---------------------------------------------------"

# Get tunnel ID from DNS records
python3 << 'PYTHON'
import requests

ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

print("\nDNS Records Analysis:")
print("-" * 50)
resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records", headers=HEADERS)
for r in resp.json().get('result', []):
    if 'jumpstartscaling' in r['name']:
        content = r['content']
        if 'cfargotunnel' in content:
            tunnel_id = content.split('.')[0]
            print(f"{r['name']:40s} → {tunnel_id}")
        else:
            print(f"{r['name']:40s} → {content} (NOT TUNNEL)")

print("\nActive Tunnels in Cloudflare:")
print("-" * 50)
azone = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}", headers=HEADERS).json()
acc_id = azone['result']['account']['id']
tunnels = requests.get(f"https://api.cloudflare.com/client/v4/accounts/{acc_id}/tunnels?is_deleted=false", headers=HEADERS).json().get('result', [])
for t in tunnels:
    print(f"Name: {t['name']:30s} ID: {t['id']}")
    print(f"  Status: {t.get('status', 'UNKNOWN')}")
    print(f"  Created: {t.get('created_at', 'UNKNOWN')}")
PYTHON

echo ""
echo "2. SERVER TUNNEL CONFIGURATION"
echo "---------------------------------------------------"

ssh -i $SSH_KEY $SERVER << 'SERVER_AUDIT'
echo "Tunnel Config (/etc/cloudflared/config.yml):"
if [ -f /etc/cloudflared/config.yml ]; then
    cat /etc/cloudflared/config.yml
else
    echo "  ⚠️  File not found!"
fi

echo ""
echo "Cloudflared Service Status:"
sudo systemctl status cloudflared --no-pager 2>&1 | head -20

echo ""
echo "Cloudflared Process:"
ps aux | grep cloudflared | grep -v grep || echo "  ⚠️  No cloudflared process running"

echo ""
echo "Recent Cloudflared Logs:"
sudo journalctl -u cloudflared -n 30 --no-pager 2>&1 | tail -20
SERVER_AUDIT

echo ""
echo "3. APPLICATION STATUS"
echo "---------------------------------------------------"

ssh -i $SSH_KEY $SERVER << 'APPS'
echo "PM2 Processes:"
pm2 list 2>/dev/null || echo "  PM2 not running or not installed"

echo ""
echo "Port Listeners:"
sudo netstat -tlnp | grep -E ':(8100|5678|9090|80|443)' || echo "  No processes on expected ports"

echo ""
echo "Next.js (Port 8100):"
curl -I http://localhost:8100 2>&1 | head -5 || echo "  ⚠️  Not responding"

echo ""
echo "n8n (Port 5678):"
curl -I http://localhost:5678 2>&1 | head -5 || echo "  ⚠️  Not responding"

echo ""
echo "Cockpit (Port 9090):"
curl -I http://localhost:9090 2>&1 | head -5 || echo "  ⚠️  Not responding"
APPS

echo ""
echo "4. CLOUDFLARE CONFIGURATION"
echo "---------------------------------------------------"

python3 << 'CFCONFIG'
import requests

ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

print("SSL Mode:")
resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/settings/ssl", headers=HEADERS)
print(f"  {resp.json()['result']['value'].upper()}")

print("\nAlways Use HTTPS:")
resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/settings/always_use_https", headers=HEADERS)
print(f"  {resp.json()['result']['value'].upper()}")
CFCONFIG

echo ""
echo "==================================================="
echo "AUDIT COMPLETE"
echo "==================================================="
