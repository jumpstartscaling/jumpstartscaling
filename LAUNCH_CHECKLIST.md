# pSEO Factory — Launch Checklist

Use this checklist when deploying god-mode to Coolify (86.48.23.38).

---

## Prerequisites

- [ ] Coolify server running
- [ ] DNS access for jumpstartscaling.com, chrisamaya.work

---

## 1. PostgreSQL

- [ ] Coolify → **+ Add Resource** → **Database** → **PostgreSQL**
- [ ] Name: `god-mode-db` (or similar)
- [ ] Create database `god_mode` (or use default); Coolify creates DB when adding resource
- [ ] Copy **internal** connection string (host = Coolify container name/UUID in same project)
- [ ] Format: `postgresql://USER:PASSWORD@COOLIFY_DB_CONTAINER:5432/god_mode`
- [ ] god-mode-api and Postgres must be in same Coolify network (same project)

---

## 2. God Mode API (FastAPI)

- [ ] Coolify → **+ New Resource** → **Docker Compose** or **Dockerfile**
- [ ] Build from `python-api/` or use existing god-mode-api app
- [ ] **Environment Variables**:
  - `DATABASE_URL` = PostgreSQL connection string
  - `ADMIN_KEY` = secure random (e.g. `openssl rand -hex 24`)
  - `LOG_REQUESTS` = `true`
- [ ] Domain: `api.jumpstartscaling.com`
- [ ] Verify: `curl https://api.jumpstartscaling.com/` → health JSON

---

## 3. God Mode Router + Sites

- [ ] Coolify → **+ New Resource** → **Dockerfile** → select god-mode root
- [ ] Build from `Dockerfile` at repo root
- [ ] **Environment Variables**:
  - `GOD_MODE_API_URL` = `https://api.jumpstartscaling.com`
  - `SITES_BASE_PATH` = `/app`
  - `ADMIN_KEY` = same as god-mode-api
  - `PUBLIC_N8N_WEBHOOK` = `https://n8n.jumpstartscaling.com/webhook/d282e622-9c83-4936-9d93-05c37eaa7b68` (or your webhook)
- [ ] **Domains**: `factory.jumpstartscaling.com`, `www.factory.jumpstartscaling.com`, `chrisamaya.work`, `www.chrisamaya.work`
- [ ] **Build args** (optional): `PUBLIC_GOD_MODE_API_URL` for pSEO pre-render

---

## 4. DNS (A Records → 86.48.23.38)

| Domain                         | Type | Target      |
|--------------------------------|------|-------------|
| factory.jumpstartscaling.com   | A    | 86.48.23.38 |
| www.factory.jumpstartscaling.com | A  | 86.48.23.38 |
| chrisamaya.work                | A    | 86.48.23.38 |
| www.chrisamaya.work            | A    | 86.48.23.38 |
| api.jumpstartscaling.com       | A    | 86.48.23.38 |

---

## 5. Verify

- [ ] **API**: `curl https://api.jumpstartscaling.com/` → `{"status":"active",...}`
- [ ] **Router**: `https://factory.jumpstartscaling.com` → JumpStart Scaling site
- [ ] **Router**: `https://chrisamaya.work` → Chris Amaya site
- [ ] **Leads**: Submit contact form → check PostgreSQL
- [ ] **Admin**: `https://api.jumpstartscaling.com/admin/?key=YOUR_ADMIN_KEY` → Admin index with Leads, Locations, Services, Content Matrix

---

## 6. Seed pSEO Data (Optional)

```bash
cd python-api
# Set DATABASE_URL in .env
python scripts/seed_from_exports.py
# Or with custom exports: python scripts/seed_from_exports.py --exports-dir /path/to/spark/exports
```

- [ ] Verify: `curl https://api.jumpstartscaling.com/api/matrix/permutations` → list of slugs
- [ ] Rebuild god-mode sites with `PUBLIC_GOD_MODE_API_URL` set to pre-render pSEO pages

---

## 7. Security

- [ ] No hardcoded secrets in repo (check `factory_fix.sh`, `test-db-connection.mjs`)
- [ ] `ADMIN_KEY` is strong and not default `spark`
- [ ] Coolify SSL enabled for all domains

---

## References

- Implementation plan: `PSEO_FACTORY_IMPLEMENTATION_PLAN.md`
- Env template: `.env.example`
- Security audit: `SECURITY_AND_ARCHITECTURE_AUDIT.md`
