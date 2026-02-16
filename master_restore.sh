#!/bin/bash
# MASTER RESTORE SCRIPT
# 1. Updates DNS to Tunnel
# 2. Restarts Tunnel Service
# 3. Restarts Next.js

SERVER_IP="150.136.117.198"
SSH_KEY=~/.ssh/id_rsa

echo "--- 1. CONFIRMING TUNNEL ID & DNS ---"
# We re-run the generator logic to ensure DNS matches the Tunnel present on the server.
# But we need to know WHICH tunnel is on the server to point DNS to it.
# We will READ the config from the server first.

echo "Reading Tunnel ID from Server..."
TUNNEL_ID=$(ssh -i $SSH_KEY opc@$SERVER_IP "grep 'tunnel:' /etc/cloudflared/config.yml | awk '{print \$2}'")

if [ -z "$TUNNEL_ID" ]; then
    echo "❌ No Tunnel ID found on server. Re-running setup..."
    ./switch_to_pure_tunnel.sh
    exit 0
fi

echo "✅ Found Tunnel ID: $TUNNEL_ID"

# Now Update DNS to this ID
echo "Updating DNS to $TUNNEL_ID.cfargotunnel.com..."
cat << PY > update_dns_master.py
import requests
TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}
TARGET = "$TUNNEL_ID.cfargotunnel.com"

records = ["jumpstartscaling.com", "www.jumpstartscaling.com", "api.jumpstartscaling.com", "n8n.jumpstartscaling.com", "cockpit.jumpstartscaling.com"]

for rec in records:
    # Delete existing
    try:
        existing = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?name={rec}", headers=HEADERS).json().get('result', [])
        for e in existing:
            requests.delete(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records/{e['id']}", headers=HEADERS)
    except Exception as e:
        print(f"Error checking {rec}: {e}")

    # Create CNAME
    requests.post(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records", headers=HEADERS, json={
        "type": "CNAME", "name": rec, "content": TARGET, "proxied": True, "ttl": 1
    })
    print(f"Set {rec} -> {TARGET}")

PY
python3 update_dns_master.py

echo "--- 2. RESTARTING SERVER SERVICES ---"
ssh -i $SSH_KEY opc@$SERVER_IP << 'EOF'
  echo "Restarting Cloudflared..."
  sudo systemctl restart cloudflared
  
  echo "Restarting Next.js..."
  cd ~/jumpstart-next
  pm2 restart jumpstart-next || pm2 start npm --name "jumpstart-next" -- run dev
  pm2 save
  
  echo "Checking Ports..."
  sudo netstat -tulpn | grep 8100
  sudo systemctl status cloudflared --no-pager
EOF

echo "✅ MASTER RESTORE COMPLETE."
