import requests

ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
NEW_IP = "193.122.168.215"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

print("Updating DNS to new server IP...")

domains = [
    ("spark.jumpstartscaling.com", False),  # No proxy for Coolify
    ("jumpstartscaling.com", True),
    ("www.jumpstartscaling.com", True),
    ("n8n.jumpstartscaling.com", True),
    ("cockpit.jumpstartscaling.com", True),
    ("api.jumpstartscaling.com", True)
]

for domain, proxied in domains:
    # Delete existing
    resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?name={domain}", headers=HEADERS)
    for r in resp.json().get('result', []):
        requests.delete(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records/{r['id']}", headers=HEADERS)
        print(f"Deleted old record for {domain}")
    
    # Create new A record
    resp = requests.post(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records", headers=HEADERS, json={
        "type": "A",
        "name": domain,
        "content": NEW_IP,
        "proxied": proxied,
        "ttl": 1
    })
    
    if resp.status_code == 200:
        proxy_status = "proxied" if proxied else "direct"
        print(f"✓ {domain:40s} → {NEW_IP} ({proxy_status})")
    else:
        print(f"✗ Failed: {domain}")

print("\n✓ DNS update complete!")
