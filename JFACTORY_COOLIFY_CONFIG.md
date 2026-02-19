# JFactory — Coolify Configuration

Use these values to configure the JFactory app in Coolify.

**Quick configure (if you have Coolify API token):**
```bash
COOLIFY_TOKEN=2|gbikFhtojz9EmoVqiLAWZd5X7veh4mTwakTeZitO6c7a06ad ./configure-jfactory-coolify.sh
```

---

## General

| Field | Value |
|-------|-------|
| **Name** | JFactory |
| **Description** | God-mode router + jumpstartscaling + chrisamaya sites |
| **Build Pack** | Dockerfile |

**Routing:** `factory.jumpstartscaling.com/` redirects to `/admin/` (God Mode admin). Marketing site: `jumpstartscaling.com`.

---

## Domains

Replace `https://coolify.io` with your actual domains:

| Domain |
|--------|
| `factory.jumpstartscaling.com` |
| `www.factory.jumpstartscaling.com` |
| `chrisamaya.work` |
| `www.chrisamaya.work` |

**Direction:** Allow www & non-www.

---

## Build

| Field | Value |
|-------|-------|
| **Base Directory** | (leave empty or `/`) |
| **Dockerfile Location** | `Dockerfile` |
| **Docker Build Stage Target** | (leave empty) |
| **Custom Docker Options** | (leave empty — remove the long SYS_ADMIN/fuse string; our app doesn't need it) |

---

## Git Source

- **Repository:** `jumpstartscaling/jumpstartscaling` (or your GitHub org/repo)
- **Branch:** `main`

---

## Environment Variables

Add these (replace placeholders with real values):

| Variable | Value |
|----------|-------|
| `GOD_MODE_API_URL` | `https://api.jumpstartscaling.com` |
| `SITES_BASE_PATH` | `/app` |
| `ADMIN_KEY` | Generate: `openssl rand -hex 24` |
| `PUBLIC_N8N_WEBHOOK` | `https://n8n.jumpstartscaling.com/webhook/d282e622-9c83-4936-9d93-05c37eaa7b68` |

---

## Prerequisites

1. **God-mode API** must be deployed first at `api.jumpstartscaling.com` (separate Coolify app).
2. **DNS (manual):** jumpstartscaling.com uses Namecheap DNS. In Namecheap → Domain List → Manage → Advanced DNS, add A records: `factory` and `www.factory` (or `*.factory`) → your Coolify server IP (e.g. `86.48.23.38`). For chrisamaya.work, add records in its DNS provider.

---

## Manual configuration steps (Coolify UI)

1. **Configuration → General**
   - Build Pack: `Dockerfile`
   - Base Directory: leave **empty** or `/`
   - Dockerfile Location: `Dockerfile`
   - Custom Docker Options: **clear completely** (delete the SYS_ADMIN/fuse string)

2. **Configuration → Domains**
   - Remove `https://coolify.io`
   - Add: `factory.jumpstartscaling.com`
   - Add: `www.factory.jumpstartscaling.com`
   - Add: `chrisamaya.work`
   - Add: `www.chrisamaya.work`
   - Direction: Allow www & non-www

3. **Configuration → Environment Variables**
   - Add `GOD_MODE_API_URL` = `https://api.jumpstartscaling.com`
   - Add `SITES_BASE_PATH` = `/app`
   - Add `ADMIN_KEY` = (run `openssl rand -hex 24` locally, paste result)
   - Add `PUBLIC_N8N_WEBHOOK` = `https://n8n.jumpstartscaling.com/webhook/d282e622-9c83-4936-9d93-05c37eaa7b68`

4. **Configuration → Advanced** (if present)
   - Port: `8100`

5. **Save** → **Deploy**

---

## Deploy

Click **Deploy** after saving. The first build may take several minutes (builds both Astro sites).

---

## Troubleshooting: 404 on /admin/

If `https://factory.jumpstartscaling.com/admin/` returns 404:

1. **`GOD_MODE_API_URL` not set** — Add `GOD_MODE_API_URL=https://api.jumpstartscaling.com` in JFactory env vars, save, and redeploy. After the change, hitting `/admin/` without it will show a 503 with setup instructions instead of 404.
2. **God-mode API not deployed** — Deploy the `god-mode-api` app first at `api.jumpstartscaling.com`. Test: `curl -I https://api.jumpstartscaling.com/health` should return 200.
3. **Admin key** — Access with `?key=...` (same value as `ADMIN_KEY` in Coolify). View the key in Coolify → JFactory → Environment Variables. If auto-configured via `configure-jfactory-coolify.sh`, a random key was generated; copy it from Coolify.

---

## Troubleshooting: "No Available Server" (503)

Traefik can't find healthy containers. This affects both **JFactory** (factory.jumpstartscaling.com) and **god-mode-api** (api.jumpstartscaling.com).

### For JFactory (factory pages):

1. **Port must be 8100** — Coolify → JFactory → Configuration → Advanced → Port: `8100`
2. **Disable health check** — Coolify → JFactory → Configuration → Health Check → turn **Off**. Traefik excludes "unhealthy" containers; health checks often fail and cause "No available server" even when the app works.
3. **Restart proxy** — Coolify → Servers → [Your Server] → Proxy → Restart Proxy (often fixes 503 after a fresh deploy)
4. **Verify locally** — `docker run -p 8100:8100 <image>` then `curl http://localhost:8100/health` should return `{"status":"ok","service":"jfactory-router"}`

### For god-mode-api:

**Common cause:** god-mode-api crash-looping (container status "restarting") usually due to `DATABASE_URL` pointing to unreachable Postgres.

**Fix (applied in code):** god-mode-api now starts even when DB connection fails; `/` and `/admin/` work, DB-dependent routes return 503 until `DATABASE_URL` is corrected.

**Steps:**
1. **Push and redeploy** — Push the `connection.py` change, then Coolify → god-mode-api → Deploy
2. **Fix DATABASE_URL** — Create a PostgreSQL database in Coolify (Add Resource → Database → PostgreSQL). Name it `god-mode-db`. Copy the internal connection string (host = container name in same project). Use DB name `god_mode`. Format: `postgresql://USER:PASSWORD@COOLIFY_DB_CONTAINER:5432/god_mode`. Set `DATABASE_URL` in god-mode-api env
3. **Restart proxy** — Coolify → Servers → [Your Server] → Proxy → Restart Proxy (if still 503 after deploy)
4. **Port match** — JFactory: 8100, god-mode-api: 8200
