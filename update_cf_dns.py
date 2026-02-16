import urllib.request
import json
import sys

TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
ZONE_NAME = "jumpstartscaling.com"
TARGET_IP = "150.136.117.198"
LOG_FILE = "/tmp/dns_log.txt"

def log(msg):
    with open(LOG_FILE, "a") as f:
        f.write(f"[DNS] {msg}\n")
    print(f"[DNS] {msg}")

def request(method, url, data=None):
    headers = {
        "Authorization": f"Bearer {TOKEN}",
        "Content-Type": "application/json"
    }
    req = urllib.request.Request(url, headers=headers, method=method)
    
    if data:
        json_data = json.dumps(data).encode('utf-8')
        req.data = json_data
        
    try:
        with urllib.request.urlopen(req) as r:
            response = r.read().decode('utf-8')
            return json.loads(response)
    except urllib.error.HTTPError as e:
        err_body = e.read().decode('utf-8')
        log(f"HTTP Error {e.code}: {err_body}")
        return None
    except Exception as e:
        log(f"Request Error: {e}")
        return None

def get_zone_id():
    url = f"https://api.cloudflare.com/client/v4/zones?name={ZONE_NAME}"
    data = request("GET", url)
    if not data or not data.get('success'):
        log(f"Error fetching zone. Success: {data.get('success') if data else 'None'}")
        return None
    
    if not data['result']:
        log("No zone found with that name.")
        return None
        
    return data['result'][0]['id']

def get_records(zone_id):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    data = request("GET", url)
    if data and data.get('success'):
        return data['result']
    return []

def update_record(zone_id, record_id, record_type, name, content, proxied=True):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{record_id}"
    payload = {
        "type": record_type,
        "name": name,
        "content": content,
        "proxied": proxied
    }
    data = request("PUT", url, payload)
    if data and data.get('success'):
        log(f"Successfully updated {name} to {content}")
    else:
        log(f"Failed to update {name}")

def create_record(zone_id, record_type, name, content, proxied=True):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    payload = {
        "type": record_type,
        "name": name,
        "content": content,
        "proxied": proxied
    }
    data = request("POST", url, payload)
    if data and data.get('success'):
        log(f"Successfully created {name} -> {content}")
    else:
        log(f"Failed to create {name}")

def delete_record(zone_id, record_id):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{record_id}"
    request("DELETE", url)
    log(f"Deleted record {record_id}")

def main():
    # Clear log
    with open(LOG_FILE, "w") as f:
        f.write("--- Starting DNS Update ---\n")

    log("Starting script...")
    
    # 1. Get Zone
    zone_id = get_zone_id()
    if not zone_id:
        log("FATAL: Could not get Zone ID")
        return

    log(f"Found Zone ID: {zone_id}")
    
    # 2. Get Existing Records
    records = get_records(zone_id)
    
    # Trackers
    root_record = None
    www_record = None
    
    # Scan records
    for r in records:
        # Check Root (@)
        if r['name'] == ZONE_NAME:
            root_record = r
        
        # Check WWW
        if r['name'] == f"www.{ZONE_NAME}":
            www_record = r

    # 3. Update ROOT (@)
    if root_record:
        if root_record['type'] == 'CNAME':
            log("Root is currently CNAME (Tunnel). Deleting...")
            delete_record(zone_id, root_record['id'])
            log("Creating new A record...")
            create_record(zone_id, 'A', ZONE_NAME, TARGET_IP)
        else:
            log("Updating existing A record for Root...")
            update_record(zone_id, root_record['id'], 'A', ZONE_NAME, TARGET_IP)
    else:
        log("No root record found. Creating...")
        create_record(zone_id, 'A', ZONE_NAME, TARGET_IP)

    # 4. Update WWW
    if www_record:
        log("Updating existing WWW record...")
        update_record(zone_id, www_record['id'], 'CNAME', 'www', ZONE_NAME)
    else:
        log("Creating WWW record...")
        create_record(zone_id, 'CNAME', 'www', ZONE_NAME)

    log("DNS Update Complete.")

if __name__ == "__main__":
    main()
