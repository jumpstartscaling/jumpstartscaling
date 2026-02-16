# Oracle Cloud Server Documentation

**Last Updated:** January 31, 2026  
**Server Type:** Oracle Cloud ARM64 (OCI VM.Standard.A1.Flex)  
**IP Address:** 150.136.117.198  
**Primary Domain:** jumpstartscaling.com  
**Admin User:** opc

---

## 🖥️ System Information

### Hardware Specifications
- **Provider:** Oracle Cloud Infrastructure (OCI)
- **Instance Type:** VM.Standard.A1.Flex (ARM64)
- **Architecture:** aarch64 (ARM 64-bit)
- **OS:** Oracle Linux 10 (ARM64)
- **Kernel:** Linux (Oracle Linux distribution)

### Server Access
```bash
# SSH Connection
ssh opc@150.136.117.198
# Or via domain
ssh opc@jumpstartscaling.com

# SSH Keys Used
~/.ssh/oracle_ubuntu (primary)
~/.ssh/google_compute_engine (alternate)
```

---

## 🌐 Network & Infrastructure

### Domain Configuration
- **Primary Domain:** jumpstartscaling.com
- **DNS Provider:** Cloudflare
- **Tunnel Provider:** Cloudflare Tunneled (`cloudflared`)
- **SSL/TLS:** Managed by Cloudflare (Auto HTTPS)

### Network Topology
```
Internet → Cloudflare CDN → Cloudflare Tunnel (QUIC) → Oracle Server → Local Services
```

### Security
- **Firewall:** firewalld (Oracle Linux default)
- **SELinux:** Enabled (Oracle Linux hardening)
- **DDoS Protection:** Cloudflare
- **Authentication:** SSH key-based only (no password)

---

## 🚀 Running Services & Applications

### Process Manager: PM2
All Node.js services are managed via PM2 with auto-restart on system reboot.

**PM2 Ecosystem Configuration:** `/home/opc/ecosystem.config.js`

### Production Services

| Service Name | Port | Type | Purpose | URL |
|-------------|------|------|---------|-----|
| **jumpstart-prod** | 8100 | Astro (Static) | Main product site | https://jumpstartscaling.com |
| **chrisamaya-prod** | 8101 | Astro (Dev Mode) | Personal portfolio | https://chrisamaya.work |
| **ion-n8n** | 5678 | n8n Workflow | Automation engine | https://n8n.jumpstartscaling.com |
| **god-mode-api** | 8200 | Django CMS | Backend API/CMS | https://api.jumpstartscaling.com |
| **ion-brain** | 8001 | FastAPI | AI Processing | Internal |
| **ion-console** | 3000 | Next.js | Admin dashboard | https://console.jumpstartscaling.com |
| **payload-cms** | 4000 | Payload CMS | Headless CMS | https://cms.jumpstartscaling.com |
| **server-health** | 8088 | FastAPI | Health monitoring | Internal diagnostic |
| **cockpit** | 9090 | Cockpit | System management | https://cockpit.jumpstartscaling.com |
| **stream-rec** | 15275/12555 | Docker | Stream recording | https://rec.jumpstartscaling.com |

### Development/Staging Services

| Service Name | Port | Purpose | Access |
|-------------|------|---------|--------|
| **jumpstart-staging** | 8102 | Staging environment | http://150.136.117.198:8102 |
| **chrisamaya-staging** | 8103 | Staging for personal site | http://150.136.117.198:8103 |
| **Available Range** | 8200-8299 | New app staging | - |
| **Available Range** | 8300-8399 | New app production | - |

---

## 💻 Development Environment

### Node.js Setup
- **Version Manager:** NVM (Node Version Manager)
- **Node.js Version:** v20.19.6 (locked in ecosystem.config.js)
- **Package Manager:** npm
- **Absolute NVM Path:** Used in PM2 to prevent version conflicts

### Python Setup
- **Python Version:** 3.11
- **Virtual Environments:** `.venv` in project directories
- **Django:** Installed (for god-mode-api)
- **FastAPI:** Installed (for ion-brain, server-health)

### Installed Frameworks & Tools
**Frontend:**
- Astro (v5.x - primary SSG)
- Next.js (for ion-console)
- React (UI components)
- Tailwind CSS (styling)

**Backend:**
- Django (god-mode-api)
- FastAPI (AI services, health monitoring)
- n8n (workflow automation)
- Payload CMS (headless CMS)

**Databases:**
- PostgreSQL 15 (port 5432, localhost only)
- Redis (port 6379, needs binding to 127.0.0.1)
- SQLite (some services, migration to PostgreSQL planned)

**AI/ML:**
- Ollama (port 11434, bound to 0.0.0.0 for internal AI networking)

---

## 📁 Directory Structure

```
/home/opc/
├── sites/
│   ├── jumpstartscaling/              # 🔒 PRODUCTION - Main site
│   │   ├── dist/                      # Built static files
│   │   ├── src/                       # Astro source code
│   │   ├── server.js                  # Production server
│   │   ├── package.json
│   │   └── ecosystem.config.js
│   │
│   ├── jumpstartscaling-dev/          # ✅ Development copy
│   ├── jumpstartscaling-staging/      # ✅ Staging environment
│   │
│   ├── chrisamaya/                     # 🔒 PRODUCTION - Personal site
│   ├── chrisamaya-dev/                 # ✅ Development copy
│   └── chrisamaya-staging/             # ✅ Staging copy
│
├── universe/                           # Backend services collection
│   ├── god-mode/                       # Django CMS backend
│   ├── ion-brain/                      # FastAPI AI services
│   ├── ion/
│   │   └── console/                    # Next.js admin dashboard
│   └── health-api/                     # Server health monitoring
│
├── payload-cms/                        # Payload CMS instance
│
├── ecosystem.config.js                 # PM2 master configuration
│
├── .cloudflared/                       # Cloudflare Tunnel config
│   └── config.yml
│
└── backups/                            # Deployment backups
    └── jumpstartscaling-backup-*.tar.gz
```

---

## 🔧 Scripting Languages & Modules

### Available Languages

#### ✅ Node.js v20.19.6
**Global Packages:**
- `npm` (package manager)
- `pm2` (process manager)
- `n8n` (workflow automation)

**Project Dependencies (Astro Sites):**
- `astro` ^5.x
- `react`, `react-dom`
- `tailwindcss`
- `@astrojs/mdx`
- `framer-motion`
- `three` (3D graphics)

**Next.js Dependencies:**
- `next`
- `react`
- Various UI libraries

#### ✅ Python 3.11
**Framework Packages:**
- `django` (Web framework)
- `fastapi` (Async web framework)
- `uvicorn` (ASGI server)
- `pydantic` (Data validation)

**Database & ORM:**
- `psycopg2` / `psycopg2-binary` (PostgreSQL adapter)
- `redis-py` (Redis client)
- `sqlalchemy` (SQL toolkit - if used)

**AI/ML Tools:**
- Ollama integration libraries
- Various AI model libraries

**Utilities:**
- `python-dotenv` (Environment variables)
- `requests` (HTTP library)
- `celery` (Task queue - if used)

#### ✅ Shell Scripting
- **Shell:** bash/zsh
- **System Tools:** systemctl, pm2, curl, wget, rsync, tar

---

## ☁️ Cloud & Deployment

### Cloudflare Tunnel Configuration
**Config File:** `/etc/cloudflared/config.yml`

**Tunnel Routing (Ingress Rules):**
```yaml
ingress:
  - hostname: jumpstartscaling.com
    service: http://127.0.0.1:8100
  
  - hostname: chrisamaya.work
    service: http://127.0.0.1:8101
  
  - hostname: n8n.jumpstartscaling.com
    service: http://127.0.0.1:5678
  
  - hostname: api.jumpstartscaling.com
    service: http://127.0.0.1:8200
  
  - hostname: console.jumpstartscaling.com
    service: http://127.0.0.1:3000
  
  - hostname: cms.jumpstartscaling.com
    service: http://127.0.0.1:4000
  
  - hostname: cockpit.jumpstartscaling.com
    service: http://127.0.0.1:9090
  
  - hostname: rec.jumpstartscaling.com
    service: http://127.0.0.1:15275
  
  - service: http_status:404
```

**Tunnel Management:**
```bash
# Restart tunnel
sudo systemctl restart cloudflared

# Check status
sudo systemctl status cloudflared

# View logs
sudo journalctl -u cloudflared -f
```

### Oracle Cloud Firewall
**Required Open Ports:**
- **22** - SSH access
- **80** - HTTP (for Let's Encrypt challenges)
- **443** - HTTPS (Cloudflare Tunnel)
- **9090** - Cockpit (if accessed directly)

**Note:** Most services run behind Cloudflare Tunnel, so only outbound HTTPS (443) is needed.

---

## 🗄️ Database Configuration

### PostgreSQL 15
- **Port:** 5432
- **Binding:** 127.0.0.1 (localhost only - secure)
- **Purpose:** User authentication, application data
- **Access:** Local services only

### Redis
- **Port:** 6379
- **Binding:** Need to verify (recommend 127.0.0.1)
- **Purpose:** Caching, session storage, task queues
- **Security Note:** Should be bound to localhost only

### SQLite
- **Location:** Various project directories
- **Purpose:** Lightweight data storage
- **Migration Plan:** Moving to PostgreSQL for scalability

---

## 🚀 Deployment Workflows

### "Nuclear" Deployment (Astro Sites)
Astro generates cache-busted hashes. Full rebuild required:

```bash
# 1. Sync source files
rsync -av --exclude 'node_modules' --exclude 'dist' \
  ./sites/jumpstartscaling/ opc@150.136.117.198:/home/opc/sites/jumpstartscaling/

# 2. SSH to server
ssh opc@150.136.117.198

# 3. Navigate to production
cd /home/opc/sites/jumpstartscaling

# 4. Create backup
tar -czf ~/backups/jumpstart-backup-$(date +%Y%m%d-%H%M%S).tar.gz dist/

# 5. Purge old build
rm -rf dist

# 6. Install dependencies (if package.json changed)
npm install

# 7. Build fresh
npm run build

# 8. Reload PM2 (zero-downtime)
pm2 reload jumpstart-prod

# 9. Verify
curl -I http://localhost:8100/
```

### Standard Backend Deployment
```bash
# Django/FastAPI services
cd /home/opc/universe/god-mode
git pull  # or rsync files
pip install -r requirements.txt
pm2 restart god-mode-api
```

### PM2 Management Commands
```bash
# List all services
pm2 list

# Logs for specific service
pm2 logs jumpstart-prod --lines 50

# Restart service
pm2 restart <service-name>

# Reload all from config
pm2 reload ecosystem.config.js --update-env

# Save current state
pm2 save

# Monitor in real-time
pm2 monit
```

---

## 🛡️ Security Architecture

### Identity-First Networking
- **No public ingress ports** except SSH
- All HTTP/HTTPS traffic goes through Cloudflare Tunnel
- Cloudflare provides DDoS protection and WAF

### System Hardening
1. **SELinux:** Enforcing mode (Oracle Linux default)
2. **firewalld:** Active and configured
3. **SSH:** Key-based authentication only (no passwords)
4. **Services:** Bound to localhost where possible

### Port Security Checklist
- ✅ PostgreSQL (5432) - Localhost only
- ⚠️ Redis (6379) - Verify localhost binding
- ⚠️ Ollama (11434) - Bound to 0.0.0.0 (internal use, block external)

---

## 📊 Monitoring & Health Checks

### Cockpit System Management
- **URL:** https://cockpit.jumpstartscaling.com
- **Username:** opc
- **Password:** JumpStartAdmin2026!
- **Features:**
  - Real-time system monitoring
  - Service management
  - File browser (terminal-free editing)
  - Log viewer
  - Performance metrics

### Health API
**Internal Endpoint:** http://localhost:8088/health

**Capabilities:**
- PM2 process status
- Cloudflare Tunnel health
- System resource monitoring
- Automated alerts (planned)

### Pre-Deployment Health Checks
```bash
# 1. Check all production services
pm2 list | grep -E "jumpstart-prod|ion-n8n|chrisamaya-prod"

# 2. Test production endpoints
curl -I http://localhost:8100/  # Should return 200
curl -I http://localhost:5678/  # Should return 200

# 3. Check Cloudflare Tunnel
sudo systemctl status cloudflared  # Should be active

# 4. Verify disk space
df -h /home/opc  # Should have >10GB free

# 5. Check memory
free -h  # Should have >5GB available

# 6. View system health
curl localhost:8088/health | jq
```

---

## 🔐 Authentication & Credentials

### System Access
- **SSH User:** opc
- **SSH Keys:** `~/.ssh/oracle_ubuntu`, `~/.ssh/google_compute_engine`
- **Sudo:** Available for opc user

### Cockpit Access
- **Username:** opc
- **Password:** JumpStartAdmin2026!
- **URL:** https://cockpit.jumpstartscaling.com

### Oracle Cloud Console
- **URL:** https://cloud.oracle.com
- **Account:** [User's Oracle account]

### Cloudflare
- **DNS/CDN Management**
- **Tunnel Configuration**
- **Security Settings**

---

## 🚨 Emergency Procedures

### Rollback Production
```bash
# List available backups
ls -lh /home/opc/backups/jumpstart-backup-*

# Restore from backup
cd /home/opc/sites/jumpstartscaling
tar -xzf ~/backups/jumpstart-backup-[TIMESTAMP].tar.gz
pm2 restart jumpstart-prod

# Verify
curl -I http://localhost:8100/
```

### Restart Crashed Service
```bash
# Restart specific service
pm2 restart <service-name>

# View recent logs
pm2 logs <service-name> --lines 100

# Check error logs
pm2 logs <service-name> --err --lines 50
```

### Fix Cloudflare Tunnel
```bash
# Restart tunnel
sudo systemctl restart cloudflared

# Check status
sudo systemctl status cloudflared

# View live logs
sudo journalctl -u cloudflared -f
```

### System Recovery
```bash
# Restart all services
pm2 restart all

# Or reload from config
pm2 reload ecosystem.config.js

# Reboot server (last resort)
sudo reboot
```

---

## 📝 Best Practices & Rules

### 🔴 Production Safety Rules
1. **NEVER** modify production directly - always use dev/staging
2. **ALWAYS** create backups before deployment
3. **TEST** in staging before deploying to production
4. **VERIFY** health checks after deployment

### Development Workflow
```
Development → Build & Test → Staging → Verify → Production → Monitor
     ↓              ↓            ↓          ↓          ↓          ↓
   -dev/        npm build    -staging/   preview   DEPLOY    pm2 logs
```

### Backup Strategy
- Create backup before every production deployment
- Keep backups for 30 days minimum
- Name backups with timestamps
- Store in `/home/opc/backups/`

---

## 🎯 Future Roadmap

### Planned Improvements
1. **Log Management:** Implement `pm2-logrotate` to prevent disk saturation
2. **Database Migration:** Move all services from SQLite to PostgreSQL
3. **CI/CD Pipeline:** GitHub Actions integration for automated deployments
4. **Monitoring:** Enhanced alerting via Health API
5. **Redis Security:** Ensure binding to 127.0.0.1

---

## 📖 Quick Reference

### Essential Commands
```bash
# SSH to server
ssh opc@150.136.117.198

# View all services
pm2 list

# View specific logs
pm2 logs <service-name> --lines 50

# Restart service
pm2 restart <service-name>

# Check tunnel
sudo systemctl status cloudflared

# Create backup
tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz <directory>

# System stats
free -h && df -h && uptime

# Check specific port
curl -I http://localhost:<port>/
```

### Service URLs
- **Main Site:** https://jumpstartscaling.com
- **Personal Site:** https://chrisamaya.work
- **N8N:** https://n8n.jumpstartscaling.com
- **API:** https://api.jumpstartscaling.com
- **Console:** https://console.jumpstartscaling.com
- **CMS:** https://cms.jumpstartscaling.com
- **Cockpit:** https://cockpit.jumpstartscaling.com
- **Stream-Rec:** https://rec.jumpstartscaling.com

---

**Server:** Oracle Cloud ARM64 (150.136.117.198)  
**Contact:** Chris Amaya  
**Emergency:** See rollback procedures above  
**Last Verified:** January 31, 2026

---

**End of Documentation**
