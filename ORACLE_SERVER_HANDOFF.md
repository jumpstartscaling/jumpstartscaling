# Oracle Server — Coder Handoff
**Last Updated:** February 18, 2026  
**Purpose:** Reference for a human coder to create GitHub repositories for each service and prepare them for migration to the new Coolify VPS.

---

## 🖥️ Server Access

| Field | Value |
|---|---|
| **Provider** | Oracle Cloud Infrastructure (OCI) |
| **Instance Type** | VM.Standard.A1.Flex (ARM64) |
| **OS** | Oracle Linux 10 (aarch64) |
| **Public IP** | `150.136.117.198` |
| **Primary Domain** | `jumpstartscaling.com` |
| **SSH User** | `opc` |
| **SSH Command** | `ssh opc@150.136.117.198` |
| **SSH Keys** | `~/.ssh/oracle_ubuntu` (primary), `~/.ssh/google_compute_engine` (alternate) |
| **Cockpit UI** | https://cockpit.jumpstartscaling.com |
| **Cockpit Login** | `opc` / `JumpStartAdmin2026!` |

> **Note:** SSH is key-based only (no password). You must have the `oracle_ubuntu` private key.

---

## 📁 Services to Turn Into GitHub Repos

These are the **3 services** that need to be migrated. Each should become its own **private GitHub repository**.

---

### 1. `jumpstartscaling-site` (Astro)
**Live URL:** https://jumpstartscaling.com  
**Server Path:** `/home/opc/sites/jumpstartscaling/`  
**PM2 Process:** `jumpstart-prod` (port 8100)  
**Framework:** Astro v5.x (static site generator)  
**Local Copy:** `./sites/jumpstartscaling/` (on dev machine)

**What to include in the repo:**
```
src/               ← All source code (components, pages, content, styles)
public/            ← Static assets (images, fonts, etc.)
astro.config.mjs   ← Astro configuration
package.json       ← Dependencies
tsconfig.json      ← TypeScript config
server.js          ← Production server entry point
```

**What to EXCLUDE (add to .gitignore):**
```
node_modules/
dist/
.astro/
.DS_Store
*.log
```

**Build command:** `npm run build`  
**Start command:** `node server.js` or `npm run preview`  
**Node version:** 20.x

---

### 2. `chrisamaya-site` (Astro)
**Live URL:** https://chrisamaya.work  
**Server Path:** `/home/opc/sites/chrisamaya/`  
**PM2 Process:** `chrisamaya-prod` (port 8101/8102)  
**Framework:** Astro v5.x  
**Local Copy:** `./sites/chrisamaya/` (on dev machine)

**What to include in the repo:**
```
src/               ← All source code
public/            ← Static assets
astro.config.mjs
package.json
tsconfig.json
```

**What to EXCLUDE:**
```
node_modules/
dist/
.astro/
.DS_Store
*.log
```

**Build command:** `npm run build`  
**Start command:** `node server.js` or `npm run preview`  
**Node version:** 20.x

---

### 3. `god-mode-api` (FastAPI / Python)
**Live URL:** https://api.jumpstartscaling.com  
**Server Path:** `/home/opc/universe/god-mode/` (or deploy from Coolify)  
**PM2 Process:** `god-mode-api` (port 8200)  
**Framework:** FastAPI (Python 3.12)  
**Local Copy:** `./python-api/`

**What to include in the repo:**
```
app/               ← FastAPI app (main.py, routers, db, config)
requirements.txt   ← Python dependencies
.env.example       ← Template env file (NOT the real .env)
Dockerfile         ← For Coolify deployment
README.md
```

**What to EXCLUDE:**
```
.venv/
__pycache__/
*.pyc
.env               ← NEVER commit real env file
```

**Note:** Django has been replaced by FastAPI. Source is in this repo; no need to rsync from Oracle.

---

## 🗂️ Full Server Directory Structure (Reference)

```
/home/opc/
├── sites/
│   ├── jumpstartscaling/        ← REPO 1 (production)
│   ├── jumpstartscaling-dev/    ← dev copy (ignore)
│   ├── jumpstartscaling-staging/← staging copy (ignore)
│   ├── chrisamaya/              ← REPO 2 (production)
│   ├── chrisamaya-dev/          ← dev copy (ignore)
│   └── chrisamaya-staging/      ← staging copy (ignore)
│
├── universe/
│   ├── god-mode/                ← REPO 3 (FastAPI — or deploy from Coolify)
│   ├── ion-brain/               ← NOT migrating (FastAPI AI)
│   └── ion/console/             ← NOT migrating (Next.js admin)
│
├── payload-cms/                 ← NOT migrating
├── ecosystem.config.js          ← PM2 config (reference only)
└── .cloudflared/config.yml      ← Cloudflare tunnel config (reference only)
```

---

## 🔧 PM2 Services Currently Running (Reference)

| PM2 Name | Port | Status | Notes |
|---|---|---|---|
| `jumpstart-prod` | 8100 | ✅ Running | → Moving to Coolify |
| `chrisamaya-prod` | 8101/8102 | ✅ Running | → Moving to Coolify |
| `god-mode-api` | 8200 | ✅ Running | → Moving to Coolify |
| `ion-n8n` | 5678 | Running | Staying on Oracle |
| `ion-brain` | 8001 | Running | Staying on Oracle |
| `ion-console` | 3000 | Running | Staying on Oracle |
| `payload-cms` | 4000 | Running | Staying on Oracle |
| `server-health` | 8088 | Running | Staying on Oracle |

---

## 🌐 Cloudflare Tunnel Config (Current Routing)

All traffic routes through Cloudflare Tunnel — no direct port exposure.

```yaml
# /etc/cloudflared/config.yml on Oracle server
ingress:
  - hostname: jumpstartscaling.com
    service: http://127.0.0.1:8100
  - hostname: chrisamaya.work
    service: http://127.0.0.1:8101
  - hostname: api.jumpstartscaling.com
    service: http://127.0.0.1:8200
  - hostname: n8n.jumpstartscaling.com
    service: http://127.0.0.1:5678
  - hostname: console.jumpstartscaling.com
    service: http://127.0.0.1:3000
  - hostname: cms.jumpstartscaling.com
    service: http://127.0.0.1:4000
  - hostname: cockpit.jumpstartscaling.com
    service: http://127.0.0.1:9090
  - service: http_status:404
```

**After migration:** Update Cloudflare DNS A records for the 3 migrated domains to point to the new Coolify server IP (`86.48.23.38`). The Cloudflare Tunnel entries for those 3 can be removed.

---

## 📦 File Sizes (What Actually Gets Committed to GitHub)

| Repo | Source Code Size | node_modules (NOT committed) |
|---|---|---|
| `jumpstartscaling-site` | ~832 KB | ~558 MB (reinstalled on server) |
| `chrisamaya-site` | ~476 KB | ~522 MB (reinstalled on server) |
| `god-mode-api` | ~50–100 MB | N/A (Python venv not committed) |

---

## 🐍 Dockerfile for god-mode-api (FastAPI)

A `Dockerfile` is included in `python-api/`. Coolify uses it to build and deploy:

```bash
cd python-api && docker build -t god-mode-api .
# Run with: -e DATABASE_URL=postgresql://...
```

---

## ✅ GitHub Repo Checklist (Per Repo)

- [ ] `git init` in the source directory
- [ ] Create `.gitignore` (see exclusions above)
- [ ] `git add .` and `git commit -m "Initial commit"`
- [ ] Create private repo on GitHub Enterprise
- [ ] `git remote add origin <repo-url>`
- [ ] `git push -u origin main`
- [ ] Verify repo is private
- [ ] Add `Dockerfile` to `god-mode-api` repo

---

## 🔗 After GitHub Repos Are Created

The repos will be connected to Coolify as deployment sources. Coolify will:
1. Pull code from GitHub on every push to `main`
2. Build the Docker image (or use Nixpacks for Astro)
3. Deploy automatically with zero downtime

**New Coolify Server:** `86.48.23.38` — see `COOLIFY_SERVER_SETUP.md` for full details.
