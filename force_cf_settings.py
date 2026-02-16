import requests
import json
import time

ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

def update_ssl():
    print("Setting SSL to FULL...")
    url = f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/settings/ssl"
    data = {"value": "full"}
    requests.patch(url, headers=HEADERS, json=data)

def update_https():
    print("Setting Always Use HTTPS to ON...")
    url = f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/settings/always_use_https"
    data = {"value": "on"}
    requests.patch(url, headers=HEADERS, json=data)

def clear_cache():
    print("Purging Cache...")
    url = f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/purge_cache"
    requests.post(url, headers=HEADERS, json={"purge_everything": True})

if __name__ == "__main__":
    update_ssl()
    update_https()
    clear_cache()
    print("✅ Cloudflare Config Optimized for Tunnel.")
