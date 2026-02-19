import requests
import json
import base64
import os
import subprocess
import time

# --- CONFIG ---
API_TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TUNNEL_NAME = "jumpstart-auto-v5"
SERVER_USER = "opc"
SERVER_IP = "150.136.117.198"
SSH_KEY = os.path.expanduser("~/.ssh/id_rsa")

HEADERS = {
    "Authorization": f"Bearer {API_TOKEN}",
    "Content-Type": "application/json"
}

def log(msg):
    print(f"[AUTO-INSTALL] {msg}")

def run_ssh(cmd):
    full_cmd = ["ssh", "-i", SSH_KEY, "-o", "StrictHostKeyChecking=no", f"{SERVER_USER}@{SERVER_IP}", cmd]
    res = subprocess.run(full_cmd, capture_output=True, text=True)
    if res.returncode != 0:
        log(f"SSH Error: {res.stderr}")
        return False
    return True

def get_account_id():
    log("Fetching Account ID...")
    url = f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}"
    resp = requests.get(url, headers=HEADERS)
    if resp.status_code != 200:
        log(f"Failed to get zone: {resp.text}")
        exit(1)
    return resp.json()['result']['account']['id']

def create_tunnel(account_id):
    log(f"Creating Tunnel '{TUNNEL_NAME}'...")
    import secrets
    tunnel_secret = secrets.token_hex(32)
    
    # Check existing to delete (cleanup)
    url = f"https://api.cloudflare.com/client/v4/accounts/{account_id}/tunnels?name={TUNNEL_NAME}&is_deleted=false"
    resp = requests.get(url, headers=HEADERS)
    existing = resp.json().get('result', [])
    for t in existing:
        log(f"Deleting existing tunnel {t['id']}...")
        requests.delete(f"https://api.cloudflare.com/client/v4/accounts/{account_id}/tunnels/{t['id']}", headers=HEADERS)
    
    # Create New
    url = f"https://api.cloudflare.com/client/v4/accounts/{account_id}/tunnels"
    payload = {
        "name": TUNNEL_NAME,
        "tunnel_secret": base64.b64encode(tunnel_secret.encode('utf-8')).decode('utf-8')
    }
    resp = requests.post(url, headers=HEADERS, json=payload)
    if resp.status_code != 200:
        log(f"Create failed: {resp.text}")
        exit(1)
        
    data = resp.json()
    return data['result']['id'], payload['tunnel_secret']

def generate_token(account_id, tunnel_id, tunnel_secret):
    raw = {"a": account_id, "t": tunnel_id, "s": tunnel_secret}
    return base64.b64encode(json.dumps(raw).encode('utf-8')).decode('utf-8')

def update_dns(tunnel_id):
    log("Updating DNS...")
    target = f"{tunnel_id}.cfargotunnel.com"
    records = ["jumpstartscaling.com", "www.jumpstartscaling.com", "api.jumpstartscaling.com", "n8n.jumpstartscaling.com", "cockpit.jumpstartscaling.com"]
    
    for rec in records:
        # Delete existing
        s_url = f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?name={rec}"
        matches = requests.get(s_url, headers=HEADERS).json().get('result', [])
        for m in matches:
            requests.delete(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records/{m['id']}", headers=HEADERS)
            
        # Create CNAME
        c_url = f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records"
        requests.post(c_url, headers=HEADERS, json={
            "type": "CNAME", "name": rec, "content": target, "proxied": True, "ttl": 1
        })

def install_remote(token, tunnel_id):
    log("SSH: Uninstalling old service...")
    run_ssh("sudo systemctl stop cloudflared; sudo cloudflared service uninstall; sudo pkill -f cloudflared")
    
    log("SSH: Installing new service...")
    cmd = f"sudo cloudflared service install {token}"
    if not run_ssh(cmd):
        log("Install failed remote")
        exit(1)
        
    log("SSH: Writing Config...")
    config_yml = f"""
tunnel: {tunnel_id}
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
"""
    # Write config remotely using base64 to avoid quoting hell
    b64_config = base64.b64encode(config_yml.encode('utf-8')).decode('utf-8')
    run_ssh(f"echo {b64_config} | base64 -d | sudo tee /etc/cloudflared/config.yml")
    
    log("SSH: Restarting...")
    run_ssh("sudo systemctl restart cloudflared")

def main():
    acc_id = get_account_id()
    tid, secret = create_tunnel(acc_id)
    token = generate_token(acc_id, tid, secret)
    
    update_dns(tid)
    install_remote(token, tid)
    log("✅ SUCCESS")

if __name__ == "__main__":
    main()
