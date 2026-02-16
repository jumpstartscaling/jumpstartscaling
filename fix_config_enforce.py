import requests
import json
import sys

# CONFIG
ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
TUNNEL_NAME = "jumpstart-pure-v1"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

print("🔧 FIXING CLOUDFLARE CONFIG...")

# 1. FORCE SSL TO FULL
print("1️⃣  Setting SSL to FULL (Required for Tunnels)...")
url = f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/settings/ssl"
requests.patch(url, headers=HEADERS, json={"value": "full"})

# 2. FORCE HTTPS
print("2️⃣  Setting Always Use HTTPS to ON...")
url = f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/settings/always_use_https"
requests.patch(url, headers=HEADERS, json={"value": "on"})

# 3. GET TUNNEL ID
print(f"3️⃣  Fetching ID for tunnel '{TUNNEL_NAME}'...")
# Get Account ID first
azone = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}", headers=HEADERS).json()
acc_id = azone['result']['account']['id']

# Search Tunnel
tunnels = requests.get(f"https://api.cloudflare.com/client/v4/accounts/{acc_id}/tunnels?name={TUNNEL_NAME}&is_deleted=false", headers=HEADERS).json().get('result', [])
if not tunnels:
    print(f"❌ Tunnel '{TUNNEL_NAME}' not found! Cannot update DNS.")
    # Fallback: List all tunnels and pick the most recent one?
    # No, stick to the plan. If it's missing, we need to re-create.
    sys.exit(1)

tunnel_id = tunnels[0]['id']
print(f"   Found ID: {tunnel_id}")

# 4. UPDATE DNS
print("4️⃣  Updating DNS Records...")
target = f"{tunnel_id}.cfargotunnel.com"
records = ["jumpstartscaling.com", "www.jumpstartscaling.com", "api.jumpstartscaling.com", "n8n.jumpstartscaling.com", "cockpit.jumpstartscaling.com"]

for rec in records:
    # Delete existing
    existing = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?name={rec}", headers=HEADERS).json().get('result', [])
    for e in existing:
        requests.delete(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records/{e['id']}", headers=HEADERS)
    
    # Create CNAME
    requests.post(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records", headers=HEADERS, json={
        "type": "CNAME", "name": rec, "content": target, "proxied": True, "ttl": 1
    })
    print(f"   Set {rec} -> {target}")

print("✅ CONFIGURATION FIXED.")
