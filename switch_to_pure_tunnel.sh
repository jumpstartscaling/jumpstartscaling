#!/bin/bash
echo "🛡️ SWITCHING TO PURE TUNNEL (NO NGINX)..."

# Upload the generator script again to be sure
# (Content is same as before, just ensuring it exists)
cat << 'PY' > emergency_tunnel_gen.py
import requests
import json
import base64
import os

API_TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TUNNEL_NAME = "jumpstart-pure-v1"

HEADERS = {
    "Authorization": f"Bearer {API_TOKEN}",
    "Content-Type": "application/json"
}

def log(msg):
    print(msg)

def run():
    # 1. Get Account ID
    resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}", headers=HEADERS)
    acc_id = resp.json()['result']['account']['id']
    
    # 2. Cleanup Old Tunnels
    tunnels = requests.get(f"https://api.cloudflare.com/client/v4/accounts/{acc_id}/tunnels?is_deleted=false", headers=HEADERS).json()['result']
    for t in tunnels:
        log(f"Deleting old tunnel: {t['name']}")
        requests.delete(f"https://api.cloudflare.com/client/v4/accounts/{acc_id}/tunnels/{t['id']}", headers=HEADERS)
        
    # 3. Create New Tunnel
    import secrets
    secret = secrets.token_hex(32)
    b64_secret = base64.b64encode(secret.encode('utf-8')).decode('utf-8')
    
    resp = requests.post(f"https://api.cloudflare.com/client/v4/accounts/{acc_id}/tunnels", headers=HEADERS, json={
        "name": TUNNEL_NAME, "tunnel_secret": b64_secret
    })
    tunnel_id = resp.json()['result']['id']
    log(f"Created Tunnel: {tunnel_id}")
    
    # 4. Generate Token
    raw_token = {"a": acc_id, "t": tunnel_id, "s": secret}
    token = base64.b64encode(json.dumps(raw_token).encode('utf-8')).decode('utf-8')
    
    with open("FINAL_TOKEN.txt", "w") as f:
        f.write(token)
    
    # 5. Update DNS
    target = f"{tunnel_id}.cfargotunnel.com"
    records = ["jumpstartscaling.com", "www.jumpstartscaling.com", "api.jumpstartscaling.com", "n8n.jumpstartscaling.com", "cockpit.jumpstartscaling.com"]
    
    for rec in records:
        # Delete existing
        existing = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?name={rec}", headers=HEADERS).json()['result']
        for e in existing:
            requests.delete(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records/{e['id']}", headers=HEADERS)
        # Create
        requests.post(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records", headers=HEADERS, json={
            "type": "CNAME", "name": rec, "content": target, "proxied": True, "ttl": 1
        })
    log("DNS Updated.")

if __name__ == "__main__":
    run()
PY

# Copy to server and execute everything
scp -i ~/.ssh/id_rsa emergency_tunnel_gen.py opc@150.136.117.198:~/emergency_tunnel_gen.py

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  set -e
  echo "--- 1. KILLING NGINX ---"
  sudo systemctl stop nginx || true
  sudo systemctl disable nginx || true
  # Free up port 80 just in case, though Tunnel doesn't need it.
  
  echo "--- 2. GENERATING TUNNEL & DNS ---"
  python3 emergency_tunnel_gen.py
  
  echo "--- 3. INSTALLING TUNNEL (Token Mode) ---"
  sudo systemctl stop cloudflared || true
  sudo cloudflared service uninstall || true
  sudo pkill -f cloudflared || true
  
  TOKEN=$(cat FINAL_TOKEN.txt)
  sudo cloudflared service install "$TOKEN"
  
  echo "--- 4. CONFIGURING INGRESS (Direct to Apps) ---"
  # MINIMAL CONFIG - NO credentials-file, NO tunnel UUID.
  # Just Ingress. The Token handles the rest.
  sudo tee /etc/cloudflared/config.yml > /dev/null << YAML
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

  echo "--- 5. RESTARTING ---"
  sudo systemctl restart cloudflared
  sudo systemctl status cloudflared --no-pager
  
  echo "✅ PURE TUNNEL ARCHITECTURE ACTIVE."
EOF
