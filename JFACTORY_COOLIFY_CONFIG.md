# JFactory — Coolify Configuration

Use these values to configure the JFactory app in Coolify.

**Quick configure (if you have Coolify API token):**
```bash
COOLIFY_TOKEN=your_token ./configure-jfactory-coolify.sh
```

---

## General

| Field | Value |
|-------|-------|
| **Name** | JFactory |
| **Description** | God-mode router + jumpstartscaling + chrisamaya sites |
| **Build Pack** | Dockerfile |

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
2. **DNS:** A records for the domains above → your Coolify server IP (e.g. `86.48.23.38`).

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
