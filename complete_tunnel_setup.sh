#!/bin/bash
set -e

SERVER="opc@150.136.117.198"
SSH_KEY="~/.ssh/id_rsa"
ZONE_ID="f1e606b93260b3e12a939612c12c6370"
API_TOKEN="A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"

echo "======================================"
echo "COMPLETE TUNNEL SETUP - NO NGINX"
echo "======================================"

echo ""
echo "STEP 1: Verify Applications Running on Server"
echo "--------------------------------------"
ssh -i $SSH_KEY $SERVER << 'VERIFY'
echo "Checking Next.js on port 8100..."
curl -I http://localhost:8100 2>&1 | head -3 || echo "⚠️  Next.js NOT responding on 8100"

echo ""
echo "Checking n8n on port 5678..."
curl -I http://localhost:5678 2>&1 | head -3 || echo "⚠️  n8n NOT responding on 5678"

echo ""
echo "Checking Cockpit on port 9090..."
curl -I http://localhost:9090 2>&1 | head -3 || echo "⚠️  Cockpit NOT responding on 9090"

echo ""
echo "Checking PM2 processes..."
pm2 list || echo "PM2 not showing processes"

echo ""
echo "Checking listening ports..."
sudo netstat -tlnp | grep -E ':(8100|5678|9090)' || echo "No services found on expected ports"
VERIFY

echo ""
echo "STEP 2: Create Fresh Tunnel via Cloudflare API"
echo "--------------------------------------"

python3 << 'PYTHON'
import requests
import json
import base64
import secrets

ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
TUNNEL_NAME = "jumpstart-complete-reset"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

# Get Account ID
resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}", headers=HEADERS)
acc_id = resp.json()['result']['account']['id']
print(f"Account ID: {acc_id}")

# Delete ALL old tunnels
tunnels = requests.get(f"https://api.cloudflare.com/client/v4/accounts/{acc_id}/tunnels?is_deleted=false", headers=HEADERS).json().get('result', [])
for t in tunnels:
    print(f"Deleting old tunnel: {t['name']}")
    requests.delete(f"https://api.cloudflare.com/client/v4/accounts/{acc_id}/tunnels/{t['id']}", headers=HEADERS)

# Create new tunnel
secret = secrets.token_hex(32)
b64_secret = base64.b64encode(secret.encode('utf-8')).decode('utf-8')

resp = requests.post(f"https://api.cloudflare.com/client/v4/accounts/{acc_id}/tunnels", headers=HEADERS, json={
    "name": TUNNEL_NAME,
    "tunnel_secret": b64_secret
})

if resp.status_code != 200:
    print(f"ERROR creating tunnel: {resp.text}")
    exit(1)

tunnel_id = resp.json()['result']['id']
print(f"Created Tunnel ID: {tunnel_id}")

# Generate install token
raw_token = {"a": acc_id, "t": tunnel_id, "s": secret}
install_token = base64.b64encode(json.dumps(raw_token).encode('utf-8')).decode('utf-8')

# Save to files for next steps
with open("/tmp/tunnel_id.txt", "w") as f:
    f.write(tunnel_id)
with open("/tmp/install_token.txt", "w") as f:
    f.write(install_token)

print(f"Token saved to /tmp/install_token.txt")

# Update DNS
target = f"{tunnel_id}.cfargotunnel.com"
records = ["jumpstartscaling.com", "www.jumpstartscaling.com", "api.jumpstartscaling.com", "n8n.jumpstartscaling.com", "cockpit.jumpstartscaling.com"]

for rec in records:
    # Delete existing
    existing = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?name={rec}", headers=HEADERS).json().get('result', [])
    for e in existing:
        requests.delete(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records/{e['id']}", headers=HEADERS)
    
    # Create CNAME
    requests.post(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records", headers=HEADERS, json={
        "type": "CNAME",
        "name": rec,
        "content": target,
        "proxied": True,
        "ttl": 1
    })
    print(f"DNS: {rec} -> {target}")

# Set SSL to Full
requests.patch(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/settings/ssl", headers=HEADERS, json={"value": "full"})
print("SSL Mode: FULL")

PYTHON

TUNNEL_ID=$(cat /tmp/tunnel_id.txt)
INSTALL_TOKEN=$(cat /tmp/install_token.txt)

echo ""
echo "STEP 3: Install Tunnel on Server"
echo "--------------------------------------"
echo "Tunnel ID: $TUNNEL_ID"

ssh -i $SSH_KEY $SERVER << INSTALL
set -e

# Stop everything
echo "Stopping old services..."
sudo systemctl stop cloudflared 2>/dev/null || true
sudo systemctl stop nginx 2>/dev/null || true
sudo systemctl disable nginx 2>/dev/null || true
sudo cloudflared service uninstall 2>/dev/null || true
sudo pkill -9 cloudflared 2>/dev/null || true

# Disable SELinux
echo "Disabling SELinux..."
sudo setenforce 0 2>/dev/null || true

# Install tunnel service
echo "Installing tunnel with token..."
sudo cloudflared service install "$INSTALL_TOKEN"

# Write config
echo "Writing ingress config..."
sudo tee /etc/cloudflared/config.yml > /dev/null << 'YAML'
ingress:
  - hostname: jumpstartscaling.com
    service: http://localhost:8100
  - hostname: www.jumpstartscaling.com
    service: http://localhost:8100
  - hostname: n8n.jumpstartscaling.com
    service: http://localhost:5678
  - hostname: cockpit.jumpstartscaling.com
    service: http://localhost:9090
  - hostname: api.jumpstartscaling.com
    service: http://localhost:8100
  - service: http_status:404
YAML

# Start service
echo "Starting cloudflared..."
sudo systemctl restart cloudflared
sudo systemctl enable cloudflared

# Wait for startup
sleep 5

echo ""
echo "Service Status:"
sudo systemctl status cloudflared --no-pager || true

echo ""
echo "Recent Logs:"
sudo journalctl -u cloudflared -n 20 --no-pager || true

INSTALL

echo ""
echo "======================================"
echo "SETUP COMPLETE"
echo "======================================"
echo "Tunnel ID: $TUNNEL_ID"
echo "DNS updated for all subdomains"
echo "Please wait 30 seconds for propagation, then test:"
echo "  - https://jumpstartscaling.com"
echo "  - https://n8n.jumpstartscaling.com"
echo "  - https://cockpit.jumpstartscaling.com"
