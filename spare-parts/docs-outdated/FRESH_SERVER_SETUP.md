# Fresh Server Setup - Complete Guide

## Step 1: Wipe Server (Oracle Cloud Console)

1. Go to: https://cloud.oracle.com
2. Navigate to: **Compute → Instances**
3. Find your instance: `host-10-0-0-187`
4. **More Actions → Terminate**
   - OR keep instance and do **More Actions → Reboot → Reinstall OS**
5. **Create New Instance** (if terminated):
   - Shape: Same as before (ARM or AMD)
   - Image: Oracle Linux 8
   - SSH Key: Use same key
   - **NOTE THE NEW IP ADDRESS**

## Step 2: Update DNS (While Server Rebuilds)

Update Cloudflare DNS to new IP:

```bash
# Run this locally (replace NEW_IP with actual IP)
NEW_IP="YOUR_NEW_IP_HERE"

python3 << PY
import requests
ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
IP = "$NEW_IP"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

domains = [
    ("spark.jumpstartscaling.com", False),  # No proxy for Coolify UI
    ("jumpstartscaling.com", True),
    ("www.jumpstartscaling.com", True),
    ("n8n.jumpstartscaling.com", True),
    ("cockpit.jumpstartscaling.com", True)
]

for domain, proxied in domains:
    # Delete old
    resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?name={domain}", headers=HEADERS)
    for r in resp.json().get('result', []):
        requests.delete(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records/{r['id']}", headers=HEADERS)
    
    # Create new
    requests.post(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records", headers=HEADERS, json={
        "type": "A", "name": domain, "content": IP, "proxied": proxied, "ttl": 1
    })
    print(f"✓ {domain} → {IP} (proxied: {proxied})")
PY
```

## Step 3: Initial Server Setup

SSH to new server:
```bash
ssh opc@NEW_IP

# Update system
sudo yum update -y

# Install Docker
curl -fsSL https://get.docker.com | bash
sudo usermod -aG docker opc
sudo systemctl enable docker
sudo systemctl start docker

# IMPORTANT: Logout and login again
exit
ssh opc@NEW_IP
```

## Step 4: Install Coolify

```bash
# Run official installer
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash

# Wait for installation (2-3 minutes)
echo "Waiting for Coolify to start..."
sleep 180

# Verify installation
docker ps | grep coolify
```

You should see containers like:
- coolify
- coolify-proxy (Traefik)
- coolify-db
- coolify-redis

## Step 5: Access Coolify UI

Open browser:
- `http://spark.jumpstartscaling.com:8000`
- Or `http://NEW_IP:8000`

Complete setup wizard:
1. Create admin account
2. Set email/password
3. Complete onboarding

## Step 6: Deploy Next.js Site

### Option A: From Local Directory

1. In Coolify UI: **+ Add Resource**
2. Select **Application** → **Docker Compose**
3. Or use **Simple Dockerfile**

We'll need to upload the code. I'll prepare a deployment script next.

### Option B: From GitHub (Recommended)

1. Push `/Users/christopheramaya/Downloads/spark/god-mode/sites/jumpstartscaling-next` to GitHub
2. In Coolify: **+ Add Resource** → **Application** → **Public Repository**
3. Configure:
   - Repository URL
   - Build Command: `npm run build`
   - Start Command: `npm start`
   - Port: 3000
   - Domain: `jumpstartscaling.com`

## Ready to Start?

1. **Go wipe the server in Oracle console**
2. **Tell me the new IP address**
3. I'll update DNS and prepare deployment scripts

Want me to prepare GitHub upload or local deployment?
