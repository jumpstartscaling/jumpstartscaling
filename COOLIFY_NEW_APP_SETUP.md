# Coolify — New App Setup (god-mode)

After pushing to GitHub, add a new app in Coolify to deploy the pSEO factory.

---

## Option A: God-Mode Router + Sites (Dockerfile)

1. **Coolify** → **+ New Resource** → **Application**
2. **Source**: Connect GitHub → `jumpstartscaling/jumpstartscaling` (or your org)
3. **Branch**: `main`
4. **Build Pack**: Dockerfile
5. **Dockerfile Location**: `Dockerfile` (repo root)
6. **Domains**: Add `factory.jumpstartscaling.com`, `www.factory.jumpstartscaling.com`, `chrisamaya.work`, `www.chrisamaya.work`
7. **Environment Variables**:
   - `GOD_MODE_API_URL` = `https://api.jumpstartscaling.com`
   - `SITES_BASE_PATH` = `/app`
   - `ADMIN_KEY` = (generate: `openssl rand -hex 24`)
   - `PUBLIC_N8N_WEBHOOK` = `https://n8n.jumpstartscaling.com/webhook/...`
8. **Deploy**

---

## Option B: God-Mode API (FastAPI)

1. **Coolify** → **+ New Resource** → **Application**
2. **Source**: GitHub → same repo
3. **Base Directory**: `python-api`
4. **Build Pack**: Dockerfile (uses `python-api/Dockerfile`)
5. **Domain**: `api.jumpstartscaling.com`
6. **Environment Variables**:
   - `DATABASE_URL` = PostgreSQL connection string
   - `ADMIN_KEY` = (same as router)
   - `LOG_REQUESTS` = `true`
7. **Deploy**

---

## Prerequisites

- PostgreSQL database created in Coolify
- DNS A records → `86.48.23.38`

See `LAUNCH_CHECKLIST.md` for full steps.
