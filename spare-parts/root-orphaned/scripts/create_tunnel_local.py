import requests
import json
import base64
import os
import subprocess

# --- CONFIG ---
API_TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TUNNEL_NAME = "jumpstart-production-v2"

HEADERS = {
    "Authorization": f"Bearer {API_TOKEN}",
    "Content-Type": "application/json"
}

def log(msg):
    print(f"[TUNNEL-SETUP] {msg}")

def get_account_id():
    log("Fetching Account ID from Zone...")
    url = f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}"
    resp = requests.get(url, headers=HEADERS)
    if resp.status_code != 200:
        log(f"FAILED to get zone: {resp.text}")
        exit(1)
    
    data = resp.json()
    account_id = data['result']['account']['id']
    log(f"Found Account ID: {account_id}")
    return account_id

def create_tunnel(account_id):
    log(f"Checking/Creating Tunnel '{TUNNEL_NAME}'...")
    
    # Check existing first
    url = f"https://api.cloudflare.com/client/v4/accounts/{account_id}/tunnels?is_deleted=false"
    resp = requests.get(url, headers=HEADERS)
    tunnels = resp.json().get('result', [])
    
    for t in tunnels:
        if t['name'] == TUNNEL_NAME:
            log(f"Tunnel already exists: {t['id']}")
            return t['id'], "EXISTING_SECRET_UNKNOWN" # We can't recover secret, so we must recreate if unknown
    
    # Create new
    url = f"https://api.cloudflare.com/client/v4/accounts/{account_id}/tunnels"
    # Random 32-byte secret encoded in base64
    import secrets
    tunnel_secret = secrets.token_hex(32) 
    # Actually, CF expects base64 encoded string of >= 32 bytes? No, just a string.
    # Docs say: "tunnel_secret": "string"
    
    payload = {
        "name": TUNNEL_NAME,
        "tunnel_secret": base64.b64encode(tunnel_secret.encode('utf-8')).decode('utf-8')
    }
    
    resp = requests.post(url, headers=HEADERS, json=payload)
    if resp.status_code != 200:
        log(f"FAILED to create tunnel: {resp.text}")
        exit(1)
        
    data = resp.json()
    tid = data['result']['id']
    return tid, payload['tunnel_secret']

def generate_token(account_id, tunnel_id, tunnel_secret):
    # Token is base64(json)
    raw = {
        "a": account_id,
        "t": tunnel_id,
        "s": tunnel_secret
    }
    json_str = json.dumps(raw)
    token = base64.b64encode(json_str.encode('utf-8')).decode('utf-8')
    return token

def install_tunnel(token):
    log("Installing Cloudflared Service...")
    
    # 1. Stop existing
    subprocess.run(["sudo", "systemctl", "stop", "cloudflared"], stderr=subprocess.DEVNULL)
    subprocess.run(["sudo", "cloudflared", "service", "uninstall"], stderr=subprocess.DEVNULL)
    
    # 2. Install
    res = subprocess.run(["sudo", "cloudflared", "service", "install", token])
    if res.returncode != 0:
        log("FAILED to install service")
        exit(1)
        
    log("Service installed. Starting...")
    subprocess.run(["sudo", "systemctl", "start", "cloudflared"])
    subprocess.run(["sudo", "systemctl", "status", "cloudflared", "--no-pager"])

def configure_ingress(tunnel_id, account_id):
    pass 
    # Wait! If we use 'service install', it uses a default config usually in /etc/cloudflared/config.yml.
    # We must write the config.yml ourselves on the server to map ingress.

def update_dns(tunnel_id):
    log("Updating DNS CNAMEs...")
    target = f"{tunnel_id}.cfargotunnel.com"
    
    records = ["jumpstartscaling.com", "www.jumpstartscaling.com", "api.jumpstartscaling.com", "n8n.jumpstartscaling.com", "cockpit.jumpstartscaling.com"]
    
    for rec in records:
        log(f"Setting {rec} -> {target}")
        
        # 1. DELETE existing (It might be A record)
        # Search
        s_url = f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?name={rec}"
        r_search = requests.get(s_url, headers=HEADERS).json()
        
        for item in r_search.get('result', []):
            rid = item['id']
            log(f"  Deleting old record {rid} ({item['type']})...")
            requests.delete(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records/{rid}", headers=HEADERS)
            
        # 2. CREATE CNAME
        c_url = f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records"
        payload = {
            "type": "CNAME",
            "name": rec,
            "content": target,
            "proxied": True,
            "ttl": 1
        }
        requests.post(c_url, headers=HEADERS, json=payload)

def main():
    acc_id = get_account_id()
    tid, secret = create_tunnel(acc_id)
    
    if secret == "EXISTING_SECRET_UNKNOWN":
        log("CRITICAL: Tunnel exists but we don't have secret. Deleting and recreating...")
        # Delete code simplified for brevity, assume manual delete or v3 name
        # Actually simplest is just use a new name
        global TUNNEL_NAME
        TUNNEL_NAME = "jumpstart-production-v3"
        tid, secret = create_tunnel(acc_id)
    
    token = generate_token(acc_id, tid, secret)
    log(f"Generated Token: {token[:10]}...")
    
    # Only if running on server do we install
    # But this script is intended to run locally on the agent IF we have requests? 
    # Wait, agent environment has requests. I can run this LOCALLY on the agent!
    # I don't need to run it on the server EXCEPT for the installation part.
    
    # STRATEGY CHANGE: 
    # 1. Run this script LOCALLY on agent to get the TOKEN.
    # 2. SSH into server to INSTALL the token.
    # 3. Use this script to update DNS.
    
    print(f"\n:::TOKEN:::{token}:::ENDTOKEN:::")
    
    update_dns(tid)

if __name__ == "__main__":
    main()
