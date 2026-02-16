#!/bin/bash
# EMERNCY FALLBACK: DIRECT IP
# This script reverts everything to a standard Web Server setup.

SERVER_IP="150.136.117.198"
ZONE_ID="f1e606b93260b3e12a939612c12c6370"
TOKEN="A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"

echo "--- 1. STOPPING TUNNEL (Server) ---"
ssh -i ~/.ssh/id_rsa opc@$SERVER_IP << 'EOF'
  sudo systemctl stop cloudflared || true
  sudo systemctl disable cloudflared || true
  sudo pkill -f cloudflared || true
  
  # Ensure Firewall is OPEN (Redundant but safe)
  sudo firewall-cmd --permanent --add-port=80/tcp
  sudo firewall-cmd --permanent --add-port=443/tcp
  sudo firewall-cmd --reload
  sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
  sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
  sudo netfilter-persistent save || true
EOF

echo "--- 2. CONFIGURING NGINX (Server) ---"
ssh -i ~/.ssh/id_rsa opc@$SERVER_IP << 'EOF'
sudo tee /etc/nginx/nginx.conf > /dev/null << 'NGINX'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events { worker_connections 1024; }

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    # PROXY HEADERS
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    # MAIN SITE (8100)
    server {
        listen 80;
        server_name jumpstartscaling.com www.jumpstartscaling.com;
        location / { proxy_pass http://127.0.0.1:8100; }
    }

    # API (8100 for now, unless distinct)
    server {
        listen 80;
        server_name api.jumpstartscaling.com;
        location / { proxy_pass http://127.0.0.1:8100; }
    }

    # N8N (5678)
    server {
        listen 80;
        server_name n8n.jumpstartscaling.com;
        location / { proxy_pass http://127.0.0.1:5678; }
    }

    # COCKPIT (9090)
    server {
        listen 80;
        server_name cockpit.jumpstartscaling.com;
        location / { proxy_pass http://127.0.0.1:9090; }
    }
}
NGINX
sudo nginx -t
sudo systemctl restart nginx
EOF

echo "--- 3. UPDATING CLOUDFLARE DNS (Script) ---"
# Python script to brute-force the A records and SSL Mode
cat << 'PY' > update_cf_direct.py
import requests

ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
IP = "150.136.117.198"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

def update_rec(name):
    # Delete existing
    recs = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?name={name}", headers=HEADERS).json()['result']
    for r in recs:
        requests.delete(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records/{r['id']}", headers=HEADERS)
    # Create A
    requests.post(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records", headers=HEADERS, json={
        "type": "A", "name": name, "content": IP, "proxied": True, "ttl": 1
    })
    print(f"Updated {name} -> {IP}")

# Update Records
targets = ["jumpstartscaling.com", "www.jumpstartscaling.com", "api.jumpstartscaling.com", "n8n.jumpstartscaling.com", "cockpit.jumpstartscaling.com"]
for t in targets: update_rec(t)

# FORCE FLEXIBLE SSL (Required for Port 80)
requests.patch(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/settings/ssl", headers=HEADERS, json={"value": "flexible"})
print("SSL set to FLEXIBLE")

PY
python3 update_cf_direct.py

echo "✅ DONE. Accessing site directly."
