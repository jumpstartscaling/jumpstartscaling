# Project Handoff: Coolify on Oracle Cloud with Cloudflare

**Prepared:** 2026-01-12  
**Status:** Fresh Installation - In Progress

---

## 🎯 EXECUTIVE SUMMARY

This document provides complete access and operational details for the jumpstartscaling.com infrastructure running on Oracle Cloud with Coolify PaaS and Cloudflare DNS/CDN.

**Current State:**
- Fresh Oracle Cloud instance created
- DNS configured via Cloudflare
- Coolify installation initiated
- Applications pending deployment

---

## 🔑 ACCESS CREDENTIALS

### 1. Oracle Cloud Infrastructure

**Console Access:**
- URL: https://cloud.oracle.com
- Email: somescreenname@gmail.com
- Password: [User's Oracle password]

**Server SSH:**
```bash
# Connection command
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# Private key location
~/.ssh/id_rsa

# Public key (for adding to new instances)
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtdsSHvNXt14n92vNUBtnXC/4EMQPQFEUblhxekm9FHukIKGlHhITSUFPnGX4XRwkVqZYpPHaS0i1mkWq4KQ+qjBzw9ckkIbvs2mnarLFCTAd4fM37F6PoS+hX1v2Ib2OfDdfYzqoDrh8UUfZnB5hJ6nQaKQabZptPQdl0MdjosZUMjs+aWt+D7kYOLCBJCEuTNAsYhOruPXlAcm568KSfhXz3H3vQd2IckOINfmHLzwnVKhryHB5t6x5q/+G/+ux+Tt2lQUNXxlrHPEO9heNG9fflyjLHtQACHtnof9n4i6lU4Ljfka7oEurUSxxXm/m5tiYcH2mXdySpCj5DEwqJ
```

**Instance Details:**
- Public IP: `193.122.168.215`
- Instance OCID: `ocid1.instance.oc1.iad.anuwcljtkcgo5eicvl6ds7rsvruval5l2mcjduzjmcqosc2anuhyvqq7lugq`
- Region: `iad` (US East - Ashburn)
- Username: `opc`

### 2. Cloudflare

**Dashboard Access:**
- URL: https://dash.cloudflare.com
- Email: somescreenname@gmail.com
- Password: [User's Cloudflare password]

**API Credentials:**
```bash
# Zone ID
ZONE_ID="f1e606b93260b3e12a939612c12c6370"

# API Token (Full Access)
CF_TOKEN="A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
```

**API Usage Example:**
```bash
# List DNS records
curl -X GET "https://api.cloudflare.com/client/v4/zones/f1e606b93260b3e12a939612c12c6370/dns_records" \
  -H "Authorization: Bearer A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"

# Update DNS record
curl -X PUT "https://api.cloudflare.com/client/v4/zones/f1e606b93260b3e12a939612c12c6370/dns_records/{record_id}" \
  -H "Authorization: Bearer A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG" \
  -H "Content-Type: application/json" \
  --data '{"type":"A","name":"example.jumpstartscaling.com","content":"193.122.168.215","proxied":true}'
```

### 3. Coolify (Once Set Up)

**UI Access:**
- URL: http://spark.jumpstartscaling.com:8000
- Direct IP: http://193.122.168.215:8000
- Admin Email: [To be set during wizard]
- Admin Password: [To be set during wizard]

---

## 🌐 CURRENT DNS CONFIGURATION

All records point to: `193.122.168.215`

| Domain | Type | Proxied | Purpose |
|--------|------|---------|---------|
| spark.jumpstartscaling.com | A | No | Coolify UI |
| jumpstartscaling.com | A | Yes | Main site |
| www.jumpstartscaling.com | A | Yes | WWW redirect |
| n8n.jumpstartscaling.com | A | Yes | Automation |
| cockpit.jumpstartscaling.com | A | Yes | Admin panel |
| api.jumpstartscaling.com | A | Yes | API endpoint |

**Cloudflare Settings:**
- SSL/TLS Mode: Full
- Always Use HTTPS: On
- Automatic HTTPS Rewrites: On

---

## 📦 INSTALLATION PROCEDURES

### Initial Server Setup (If Starting Fresh)

```bash
# 1. SSH to server
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# 2. Update system
sudo yum update -y

# 3. Install Docker
curl -fsSL https://get.docker.com | bash
sudo usermod -aG docker opc
sudo systemctl enable docker
sudo systemctl start docker

# 4. Logout and login for docker group
exit
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# 5. Install Coolify
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash

# 6. Wait 5 minutes, then access UI
# http://193.122.168.215:8000
```

### Verify Installation

```bash
# Check Docker
docker --version
docker ps

# Check Coolify containers
docker ps | grep coolify

# Check port 8000
sudo netstat -tlnp | grep 8000

# View Coolify logs
docker logs coolify -f
```

---

## 🚀 APPLICATION DEPLOYMENT

### Next.js Site (jumpstartscaling.com)

**Local Source:**
`/Users/christopheramaya/Downloads/spark/god-mode/sites/jumpstartscaling-next/`

**Deploy via Coolify:**

1. Access Coolify UI
2. **+ Add Resource** → **Application**
3. Choose deployment method:

**Option A: Upload Directory**
```bash
# From local machine
cd /Users/christopheramaya/Downloads/spark/god-mode/sites/jumpstartscaling-next
tar -czf site.tar.gz .
scp -i ~/.ssh/id_rsa site.tar.gz opc@193.122.168.215:/tmp/

# On server, add to Coolify via UI
```

**Option B: GitHub (Recommended)**
1. Push to GitHub repository
2. In Coolify: Connect public repo
3. Configure:
   - Build: `npm run build`
   - Start: `npm start`
   - Port: 3000
   - Domains: `jumpstartscaling.com`, `www.jumpstartscaling.com`

**Environment Variables:**
```env
NODE_ENV=production
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
```

### n8n Workflow Automation

1. In Coolify: **+ Add Resource** → **Service**
2. Search: `n8n`
3. Configure:
   - Domain: `n8n.jumpstartscaling.com`
   - Port: 5678
4. Deploy

---

## 🛠️ COMMON OPERATIONS

### DNS Management

**Update DNS Record:**
```python
import requests

ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

# Get all DNS records
resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records", headers=HEADERS)
records = resp.json()['result']

# Create new A record
requests.post(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records", headers=HEADERS, json={
    "type": "A",
    "name": "subdomain.jumpstartscaling.com",
    "content": "193.122.168.215",
    "proxied": True,
    "ttl": 1
})
```

**Quick DNS Update Script:**
```bash
# Save as update_dns.sh
python3 << 'PY'
import requests
import sys

ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

domain = sys.argv[1] if len(sys.argv) > 1 else "jumpstartscaling.com"
new_ip = sys.argv[2] if len(sys.argv) > 2 else "193.122.168.215"

# Delete old
resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?name={domain}", headers=HEADERS)
for r in resp.json().get('result', []):
    requests.delete(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records/{r['id']}", headers=HEADERS)

# Create new
requests.post(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records", headers=HEADERS, json={
    "type": "A", "name": domain, "content": new_ip, "proxied": True, "ttl": 1
})
print(f"✓ {domain} → {new_ip}")
PY

# Usage: ./update_dns.sh subdomain.jumpstartscaling.com 193.122.168.215
```

### Server Maintenance

**Restart Coolify:**
```bash
ssh opc@193.122.168.215
cd /data/coolify
docker-compose restart
```

**View Coolify Logs:**
```bash
ssh opc@193.122.168.215
docker logs coolify -f
```

**Backup Coolify Data:**
```bash
ssh opc@193.122.168.215
sudo tar -czf coolify-backup-$(date +%Y%m%d).tar.gz /data/coolify
# Download backup
# scp opc@193.122.168.215:~/coolify-backup-*.tar.gz ./
```

**Update Server:**
```bash
ssh opc@193.122.168.215
sudo yum update -y
sudo reboot  # if kernel updated
```

---

## 🔍 TROUBLESHOOTING

### Coolify Not Accessible

```bash
# SSH to server
ssh opc@193.122.168.215

# Check if containers are running
docker ps | grep coolify

# If not running, start them
cd /data/coolif && docker-compose up -d

# Check port 8000
sudo netstat -tlnp | grep 8000

# View logs
docker logs coolify -f
```

### Site Not Loading

1. **Check DNS:**
```bash
dig jumpstartscaling.com
# Should return 193.122.168.215
```

2. **Check Cloudflare:**
- Login to dash.cloudflare.com
- Verify SSL mode is "Full"
- Check if proxy is enabled (orange cloud)

3. **Check Coolify:**
- Access UI: http://193.122.168.215:8000
- Verify application is running
- Check logs in Coolify UI

### SSH Connection Failed

1. **Verify instance is running:**
- Login to Oracle Cloud console
- Check instance status

2. **Check Security List:**
- Oracle Console → Networking → VCN
- Verify ingress rule for port 22 exists

3. **Test connection:**
```bash
ssh -v -i ~/.ssh/id_rsa opc@193.122.168.215
# -v flag shows verbose output
```

---

## 📁 FILE STRUCTURE

### Local Machine
```
/Users/christopheramaya/Downloads/spark/god-mode/
├── COOLIFY_MASTER_DOC.md          # Master reference
├── HANDOFF_SCRIPT.md              # This document
├── sites/
│   ├── jumpstartscaling-next/     # Next.js 16 site
│   ├── chrisamaya/                # Personal site
│   └── jumpstartscaling/          # Old Astro (deprecated)
└── scripts/
    ├── setup_fresh_server.sh
    ├── update_dns_new_ip.py
    └── check_coolify_status.sh
```

### Server (193.122.168.215)
```
/home/opc/
├── .ssh/authorized_keys           # SSH keys

/data/coolify/                      # Coolify installation
├── source/                         # Coolify code
├── docker-compose.yml              # Container definitions
├── .env                           # Environment
└── data/
    ├── applications/               # Deployed apps
    ├── databases/                  # PostgreSQL data
    └── services/                   # Service configs

/var/lib/docker/                    # Docker data
```

---

## 📞 SUPPORT RESOURCES

### Documentation
- Coolify: https://coolify.io/docs
- Oracle Cloud: https://docs.oracle.com/cloud
- Cloudflare: https://developers.cloudflare.com

### Support Channels
- Coolify Discord: https://coolify.io/discord
- Oracle Support: https://cloud.oracle.com/support
- Cloudflare Support: https://support.cloudflare.com

---

## ✅ NEXT STEPS CHECKLIST

### Immediate (< 1 Hour)
- [ ] Access Coolify UI at http://193.122.168.215:8000
- [ ] Complete Coolify setup wizard
- [ ] Create admin account (save credentials!)
- [ ] Configure server settings

### Short Term (1-3 Hours)
- [ ] Deploy Next.js application
- [ ] Set up PostgreSQL database
- [ ] Deploy n8n service
- [ ] Configure domains in Coolify
- [ ] Test SSL certificates

### Ongoing
- [ ] Monitor application health
- [ ] Set up automated backups
- [ ] Configure monitoring/alerts
- [ ] Document any custom configurations
- [ ] Update this handoff document

---

## 🔒 SECURITY NOTES

**⚠️ IMPORTANT:**
- This document contains sensitive credentials
- Store in secure location (password manager, encrypted storage)
- DO NOT commit to public repositories
- Rotate API tokens regularly
- Enable 2FA on all accounts where available
- Use strong, unique passwords

**Recommended Actions:**
1. After handoff, rotate Cloudflare API token
2. Change Coolify admin password
3. Set up SSH key authentication only (disable password auth)
4. Configure firewall rules in Oracle Cloud
5. Enable automatic security updates on server

---

## 📝 HANDOFF CONFIRMATION

**Prepared by:** AI Assistant  
**Date:** 2026-01-12  
**Verified:** Pending  

**Handoff Recipient:** _____________  
**Date Received:** _____________  
**Signature:** _____________  

---

**Questions? Issues?**  
Contact original administrator: somescreenname@gmail.com

**Document Version:** 1.0  
**Last Updated:** 2026-01-12 17:33 UTC
