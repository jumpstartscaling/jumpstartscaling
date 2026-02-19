import requests
import json

ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

print("--- CLOUDFLARED CONFIG CHECK ---")

# 1. SSL SETTING
resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/settings/ssl", headers=HEADERS)
ssl_val = resp.json()['result']['value']
print(f"SSL MODE: {ssl_val}")

# 2. ALWAYS USE HTTPS
resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/settings/always_use_https", headers=HEADERS)
https_val = resp.json()['result']['value']
print(f"ALWAYS HTTPS: {https_val}")

# 3. DNS RECORDS
print("\n--- DNS RECORDS ---")
resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?per_page=50", headers=HEADERS)
for r in resp.json()['result']:
    if r['name'].endswith('jumpstartscaling.com'):
        print(f"{r['name']} ({r['type']}) -> {r['content']} [Proxied: {r['proxied']}]")

# 4. TUNNEL STATUS
url = f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}"
acc_id = requests.get(url, headers=HEADERS).json()['result']['account']['id']
resp = requests.get(f"https://api.cloudflare.com/client/v4/accounts/{acc_id}/tunnels?is_deleted=false", headers=HEADERS)
print("\n--- TUNNELS ---")
for t in resp.json()['result']:
    print(f"Tunnel: {t['name']} ({t['id']}) - Status: {t['status']}")
