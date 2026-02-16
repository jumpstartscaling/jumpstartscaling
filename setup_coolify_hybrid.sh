#!/bin/bash
set -e

ZONE_ID="f1e606b93260b3e12a939612c12c6370"
TOKEN="A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
SERVER_IP="150.136.117.198"

echo "=================================================="
echo "COOLIFY HYBRID SETUP - REVERSE PROXY ONLY"
echo "=================================================="

echo ""
echo "Step 1: Update ALL DNS to Point to Server IP"
echo "--------------------------------------------------"

python3 << PY
import requests

ZONE_ID = "${ZONE_ID}"
TOKEN = "${TOKEN}"
IP = "${SERVER_IP}"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

# All domains that should point to server
domains = [
    "jumpstartscaling.com",
    "www.jumpstartscaling.com",
    "api.jumpstartscaling.com",
    "n8n.jumpstartscaling.com",
    "cockpit.jumpstartscaling.com",
    "spark.jumpstartscaling.com"  # Coolify UI
]

for domain in domains:
    # Delete existing records
    resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?name={domain}", headers=HEADERS)
    for r in resp.json().get('result', []):
        requests.delete(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records/{r['id']}", headers=HEADERS)
        print(f"Deleted old {r['type']} record for {domain}")
    
    # Create A record
    resp = requests.post(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records", headers=HEADERS, json={
        "type": "A",
        "name": domain,
        "content": IP,
        "proxied": True,  # Enable Cloudflare proxy
        "ttl": 1
    })
    
    if resp.status_code == 200:
        print(f"✓ {domain:40s} -> {IP} (proxied)")
    else:
        print(f"✗ Failed: {domain} - {resp.text}")

# Set SSL to Full
requests.patch(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/settings/ssl", headers=HEADERS, json={"value": "full"})
print("\n✓ SSL set to FULL")
PY

echo ""
echo "Step 2: Configure Coolify for Hybrid Mode"
echo "--------------------------------------------------"

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'SERVER'
set -e

echo "Checking Coolify installation..."
sudo docker ps | grep coolify || echo "⚠️  Coolify containers not running yet"

echo ""
echo "Ensuring ports 80/443 are available for Traefik..."
# Stop any conflicting services
sudo systemctl stop nginx 2>/dev/null || true
sudo systemctl stop cloudflared 2>/dev/null || true

# Make sure apps are still running
echo ""
echo "Verifying applications are running:"
curl -I http://localhost:8100 2>&1 | head -3 || echo "⚠️  Next.js not on 8100"
curl -I http://localhost:5678 2>&1 | head -3 || echo "⚠️  n8n not on 5678"
curl -I http://localhost:9090 2>&1 | head -3 || echo "⚠️  Cockpit not on 9090"

echo ""
echo "PM2 Status:"
pm2 list 2>/dev/null || echo "PM2 not showing processes"

SERVER

echo ""
echo "=================================================="
echo "SETUP COMPLETE"
echo "=================================================="
echo ""
echo "Next steps (MANUAL - via Coolify UI):"
echo ""
echo "1. Access Coolify at: http://spark.jumpstartscaling.com:8000"
echo "   (or http://150.136.117.198:8000 if DNS not propagated)"
echo ""
echo "2. Complete initial setup wizard"
echo ""
echo "3. For each app, add as 'Simple Service':"
echo "   a) Next.js:"
echo "      - Name: jumpstart-next"
echo "      - Type: Simple Service"
echo "      - Port: 8100"
echo "      - Domain: jumpstartscaling.com"
echo "      - Service URL: http://host.docker.internal:8100"
echo ""
echo "   b) n8n:"
echo "      - Name: n8n"
echo "      - Type: Simple Service"  
echo "      - Port: 5678"
echo "      - Domain: n8n.jumpstartscaling.com"
echo "      - Service URL: http://host.docker.internal:5678"
echo ""
echo "   c) Cockpit:"
echo "      - Name: cockpit"
echo "      - Type: Simple Service"
echo "      - Port: 9090"
echo "      - Domain: cockpit.jumpstartscaling.com"
echo "      - Service URL: http://host.docker.internal:9090"
echo ""
echo "4. Traefik will automatically handle SSL and routing"
echo ""
