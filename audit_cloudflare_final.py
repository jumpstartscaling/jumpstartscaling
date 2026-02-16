import requests
import json
import sys

# CONFIG
ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

print("🔍 DEEP CLOUDFLARE AUDIT")
print("========================")

# 1. SSL MODE (Critical for Tunnel)
try:
    resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/settings/ssl", headers=HEADERS)
    ssl_val = resp.json()['result']['value']
    print(f"🔐 SSL Mode: {ssl_val.upper()}")
except Exception as e:
    print(f"❌ SSL Check Failed: {e}")

# 2. DNS RECORDS
print("\n🌍 DNS Records (Active):")
try:
    resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?per_page=50", headers=HEADERS)
    for r in resp.json().get('result', []):
        if "jumpstartscaling" in r['name']:
            # Check if it's pointing to tunnel
            target = r['content']
            is_tunnel = "cfargotunnel.com" in target
            icon = "✅" if is_tunnel else "⚠️"
            print(f"   {icon} {r['name']} ({r['type']}) -> {target} [Proxied: {r['proxied']}]")
except Exception as e:
    print(f"❌ DNS Check Failed: {e}")

# 3. TUNNELS CHECK
print("\n🚇 Tunnel Status:")
try:
    # Get Account ID first
    azone = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}", headers=HEADERS).json()
    acc_id = azone['result']['account']['id']
    
    # List Tunnels
    tunnels = requests.get(f"https://api.cloudflare.com/client/v4/accounts/{acc_id}/tunnels?is_deleted=false", headers=HEADERS).json().get('result', [])
    for t in tunnels:
        status = t.get('status', 'UNKNOWN')
        color = "✅" if status == "healthy" else "❌"
        print(f"   {color} {t['name']} (ID: {t['id']})")
        print(f"      Status: {status}")
        # print(f"      Conns: {t.get('connections', [])}") # Verbose
except Exception as e:
    print(f"❌ Tunnel Check Failed: {e}")

print("\n========================")
