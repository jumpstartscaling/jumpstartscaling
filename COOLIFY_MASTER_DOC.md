# Coolify Server - Master Reference Document

**Last Updated:** 2026-01-12 16:15 UTC  
**Status:** Fresh Installation In Progress

---

## 🖥️ SERVER DETAILS

### Oracle Cloud Instance
- **Provider:** Oracle Cloud Infrastructure (OCI)
- **Instance Name:** `instance-20260112-1611`
- **Instance OCID:** `ocid1.instance.oc1.iad.anuwcljtkcgo5eicvl6ds7rsvruval5l2mcjduzjmcqosc2anuhyvqq7lugq`
- **Region:** `iad` (US East - Ashburn)
- **Availability Domain:** `AD-1`
- **Fault Domain:** `FD-1`
- **Capacity Type:** On-demand
- **Launched:** Jan 12, 2026, 21:11:57 UTC

### Network Configuration
- **Public IP Address:** `193.122.168.215`
- **Private IP Address:** `10.0.0.x` (Oracle internal)
- **Virtual Cloud Network:** `vcn-20260112-1511`
- **SSH Username:** `opc`
- **SSH Port:** `22`

### SSH Access
**Private Key Location (Local Machine):**
```
~/.ssh/id_rsa
```

**Public Key Fingerprint:**
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtdsSHvNXt14n92vNUBtnXC/4EMQPQFEUblhxekm9FHukIKGlHhITSUFPnGX4XRwkVqZYpPHaS0i1mkWq4KQ+qjBzw9ckkIbvs2mnarLFCTAd4fM37F6PoS+hX1v2Ib2OfDdfYzqoDrh8UUfZnB5hJ6nQaKQabZptPQdl0MdjosZUMjs+aWt+D7kYOLCBJCEuTNAsYhOruPXlAcm568KSfhXz3H3vQd2IckOINfmHLzwnVKhryHB5t6x5q/+G/+ux+Tt2lQUNXxlrHPEO9heNG9fflyjLHtQACHtnof9n4i6lU4Ljfka7oEurUSxxXm/m5tiYcH2mXdySpCj5DEwqJ
```

**SSH Connection Command:**
```bash
ssh -i ~/.ssh/id_rsa opc@193.122.168.215
```

---

## 🌐 DNS CONFIGURATION

### Cloudflare Account
- **Zone ID:** `f1e606b93260b3e12a939612c12c6370`
- **Domain:** `jumpstartscaling.com`
- **API Token:** `A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG`

### Current DNS Records (All A Records → 193.122.168.215)
| Domain | Type | Content | Proxied | Purpose |
|--------|------|---------|---------|---------|
| `spark.jumpstartscaling.com` | A | `193.122.168.215` | ❌ No | Coolify UI Access |
| `jumpstartscaling.com` | A | `193.122.168.215` | ✅ Yes | Main Website |
| `www.jumpstartscaling.com` | A | `193.122.168.215` | ✅ Yes | WWW Redirect |
| `n8n.jumpstartscaling.com` | A | `193.122.168.215` | ✅ Yes | Workflow Automation |
| `cockpit.jumpstartscaling.com` | A | `193.122.168.215` | ✅ Yes | Server Admin |
| `api.jumpstartscaling.com` | A | `193.122.168.215` | ✅ Yes | API Endpoint |

**SSL Mode:** Full (Cloudflare ↔ Server encrypted)

---

## 🐳 COOLIFY INSTALLATION

### Access Information
- **Coolify UI URL:** `http://spark.jumpstartscaling.com:8000`
- **Direct IP Access:** `http://193.122.168.215:8000`
- **Admin Account:** _To be created during first login_
- **Installation Method:** Official installer (`https://cdn.coollabs.io/coolify/install.sh`)

### Installation Status
- **Docker:** ✅ Installed
- **Coolify Core:** 🔄 Installing
- **Traefik Proxy:** 🔄 Installing
- **PostgreSQL:** 🔄 Installing
- **Redis:** 🔄 Installing

### Expected Coolify Containers
Once installation completes, these containers will be running:
- `coolify` - Main application
- `coolify-proxy` - Traefik reverse proxy
- `coolify-db` - PostgreSQL database
- `coolify-redis` - Redis cache
- `coolify-webhooks` - Webhook handler

### Coolify File Structure (Server)
```
/data/coolify/           # Main Coolify directory
├── source/              # Coolify source code
├── docker-compose.yml   # Container definitions
├── .env                 # Environment variables
└── data/                # Application data
    ├── databases/       # PostgreSQL data
    ├── applications/    # Deployed apps
    └── services/        # Service configurations
```

---

## 📁 SERVER FILE STRUCTURE

### Expected Directory Layout
```
/home/opc/
├── .ssh/
│   └── authorized_keys      # SSH public keys
└── [Applications will be deployed via Coolify]

/data/coolify/                # Coolify installation
/var/lib/docker/              # Docker data
/etc/docker/                  # Docker configuration
```

### Local Files (Development Machine)
```
/Users/christopheramaya/Downloads/spark/god-mode/
├── sites/
│   ├── jumpstartscaling-next/    # Next.js 16 site (PRIMARY)
│   ├── jumpstartscaling/         # Old Astro site (deprecated)
│   └── chrisamaya/               # Personal portfolio
├── scripts/
│   ├── setup_fresh_server.sh     # Server initialization
│   ├── update_dns_new_ip.py      # DNS management
│   └── [various automation scripts]
└── documentation/
    └── COOLIFY_MASTER_DOC.md     # This document
```

---

## 🚀 DEPLOYED APPLICATIONS

### Current Status: None (Fresh Install)

### Planned Deployments

#### 1. jumpstartscaling.com (Next.js 16)
- **Source:** Local directory → Will upload or connect GitHub
- **Framework:** Next.js 16 (App Router)
- **Build Command:** `npm run build`
- **Start Command:** `npm start`
- **Port:** `3000` (internal)
- **Domain:** `jumpstartscaling.com`, `www.jumpstartscaling.com`
- **Environment Variables:**
  - `DATABASE_URL` - PostgreSQL connection string
  - `NODE_ENV=production`

#### 2. n8n (Workflow Automation)
- **Type:** Docker service (n8n template)
- **Port:** `5678` (internal)
- **Domain:** `n8n.jumpstartscaling.com`
- **Data:** Persistent volume for workflows

#### 3. Database (PostgreSQL)
- **Type:** Coolify managed database
- **Version:** Latest stable
- **Purpose:** Next.js application data, leads storage

---

## 🔐 CREDENTIALS & TOKENS

### Cloudflare
- **Email:** somescreenname@gmail.com
- **API Token:** `A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG`
- **Zone ID:** `f1e606b93260b3e12a939612c12c6370`

### Oracle Cloud
- **Account Email:** somescreenname@gmail.com
- **Tenancy:** somescreenname (root)
- **Console:** https://cloud.oracle.com

### Coolify (To Be Set)
- **Admin Email:** _TBD during setup_
- **Admin Password:** _TBD during setup_
- **API Token:** _Will be generated after first login_

---

## 📊 ACTIVE SERVICES

### Current Status
```
Docker:        ✅ Running
Coolify:       🔄 Installing
Traefik:       🔄 Installing
PostgreSQL:    🔄 Installing
Redis:         🔄 Installing
```

### Ports in Use
| Port | Service | Status | Access |
|------|---------|--------|--------|
| 22 | SSH | ✅ Active | Public |
| 80 | HTTP (Traefik) | 🔄 Pending | Public |
| 443 | HTTPS (Traefik) | 🔄 Pending | Public |
| 8000 | Coolify UI | 🔄 Pending | Public (via spark.jumpstartscaling.com) |

---

## 🛠️ MAINTENANCE COMMANDS

### Server Management
```bash
# SSH Access
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# Check Coolify Status
docker ps | grep coolify

# View Coolify Logs
docker logs coolify -f

# Restart Coolify
cd /data/coolify && docker-compose restart

# System Update
sudo yum update -y
```

### DNS Management
```bash
# Update DNS (from local machine)
cd /Users/christopheramaya/Downloads/spark/god-mode
python3 update_dns_new_ip.py
```

---

## 📝 INSTALLATION LOG

### 2026-01-12 16:15 UTC
- ✅ Created fresh Oracle instance
- ✅ Assigned public IP: 193.122.168.215
- ✅ Updated Cloudflare DNS to new IP
- 🔄 Running system updates
- 🔄 Installing Docker
- 🔄 Installing Coolify

### Post-Install TODO
- [ ] Access Coolify UI at spark.jumpstartscaling.com:8000
- [ ] Complete Coolify setup wizard
- [ ] Create admin account
- [ ] Deploy Next.js application
- [ ] Set up PostgreSQL database
- [ ] Deploy n8n service
- [ ] Configure SSL certificates
- [ ] Test all domains

---

## 🆘 TROUBLESHOOTING

### Cannot Access Coolify UI
```bash
# Check if port 8000 is listening
ssh opc@193.122.168.215 'sudo netstat -tlnp | grep 8000'

# Check Coolify containers
ssh opc@193.122.168.215 'docker ps'

# View Coolify logs
ssh opc@193.122.168.215 'docker logs coolify'
```

### DNS Not Resolving
```bash
# Test DNS resolution
dig spark.jumpstartscaling.com
dig jumpstartscaling.com

# Clear local DNS cache (macOS)
sudo dscacheutil -flushcache
```

### SSH Connection Issues
```bash
# Test connection
ssh -v -i ~/.ssh/id_rsa opc@193.122.168.215

# Check if instance is running in Oracle console
# Verify security list allows port 22
```

---

## 📞 SUPPORT CONTACTS

### Oracle Cloud Support
- Console: https://cloud.oracle.com
- Documentation: https://docs.oracle.com/cloud

### Coolify Support
- Documentation: https://coolify.io/docs
- Discord: https://coolify.io/discord
- GitHub: https://github.com/coollabsio/coolify

### Cloudflare Support
- Dashboard: https://dash.cloudflare.com
- Support: https://support.cloudflare.com

---

## 🔄 DOCUMENT UPDATE HISTORY

| Date | Change | Updated By |
|------|--------|------------|
| 2026-01-12 16:15 | Initial document creation | AI Assistant |
| _Future updates will be logged here_ | | |

---

**⚠️ SECURITY NOTES**
- This document contains sensitive credentials
- Store securely and do not commit to public repositories
- Rotate API tokens regularly
- Use strong passwords for Coolify admin account
- Enable 2FA where available

---

**Next Steps:**
1. Wait for Coolify installation to complete (~5-10 minutes)
2. Access http://spark.jumpstartscaling.com:8000
3. Complete setup wizard
4. Update this document with Coolify admin credentials
5. Begin application deployments
