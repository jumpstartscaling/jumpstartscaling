# God Mode — Security & Architecture Audit

**Date:** February 2026  
**Scope:** Hardcoded secrets, DB schema alignment (Harris matrix), API endpoints, host-specific code, unused/missing code.

---

## 1. Hardcoded Secrets → Coolify Env Vars

### Critical (must move to env)

| Location | What | Env Var (Coolify) |
|----------|------|-------------------|
| `router.js` L18 | `ADMIN_PASS = 'spark'` | `ADMIN_KEY` |
| `update_dns_new_ip.py` | `TOKEN`, `ZONE_ID`, `NEW_IP` | `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ZONE_ID`, `NEW_SERVER_IP` |
| `force_cf_settings.py` | `TOKEN`, `ZONE_ID` | `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ZONE_ID` |
| `emergency_tunnel_gen.py` | `API_TOKEN`, `ZONE_ID` | `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ZONE_ID` |
| `factory_fix.sh` | `DATABASE_URL` (RDS password), `GOD_MODE_TOKEN` | `DATABASE_URL`, `GOD_MODE_TOKEN` |
| `test-db-connection.mjs` L3 | Fallback `postgres://...` with password | Remove fallback; require `DATABASE_URL` |
| `src/lib/payload.ts` L16 | `PAYLOAD_URL = 'https://cms.jumpstartscaling.com'` | `PUBLIC_PAYLOAD_URL` or `PAYLOAD_CMS_URL` |

### Already in .env (never commit)

- `.env` is in `.gitignore` — ensure it is never committed.
- If `.env` was ever committed, rotate all secrets (DB, Cloudflare, tokens).

### Docs with credentials (move to password manager)

| File | Content |
|------|---------|
| `CONFIRMATION_GUIDE.md` | Cockpit password |
| `COOLIFY_SERVER_SETUP.md` | Root/admin passwords, Coolify internal secrets |
| `ORACLE_SERVER_HANDOFF.md` | SSH / Cockpit credentials |

---

## 2. DB Schema vs Harris Matrix

### Current schema (implemented)

| Table | Purpose |
|-------|---------|
| `leads` | Contact forms, audit survey, n8n form |
| `scaling_survey_submissions` | Moat Audit / detailed survey |
| `api_logs` | Request logging |

### Harris matrix (Service + Location for pSEO)

The Authority Engine content describes a **Service × Location** matrix for programmatic SEO:

- **Variables:** City, Neighborhood, Zip Code, Service Type, Material, Problem Symptom  
- **URLs:** `/services/commercial-solar-austin-tx`, `/services/residential-shingle-repair-dallas-tx`  
- **Source:** `jumpstart-scaling-manual/services/authority-engine.html` L375–386

### Schema gap

There are no tables for the content matrix. Recommended additions:

```sql
-- Locations (for pSEO matrix)
CREATE TABLE IF NOT EXISTS locations (
    id SERIAL PRIMARY KEY,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip TEXT,
    neighborhood TEXT,
    slug TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Services (for pSEO matrix)
CREATE TABLE IF NOT EXISTS pseo_services (
    id SERIAL PRIMARY KEY,
    service_type TEXT NOT NULL,
    sub_niche TEXT,
    slug TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Harris matrix: Service × Location permutations
CREATE TABLE IF NOT EXISTS content_matrix (
    id SERIAL PRIMARY KEY,
    location_id INT REFERENCES locations(id),
    service_id INT REFERENCES pseo_services(id),
    slug TEXT UNIQUE,  -- e.g. commercial-solar-austin-tx
    title TEXT,
    meta_description TEXT,
    content_json JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 3. API Endpoints — Data Handling

### Implemented endpoints

| Endpoint | Method | Receives | DB Table | Status |
|----------|--------|----------|----------|--------|
| `/api/submit-lead` | POST | JSON or form-urlencoded | `leads` | OK |
| `/api/submit-scaling-survey` | POST | JSON | `scaling_survey_submissions` | OK |
| `/admin/leads` | GET | `?key=...` | reads `leads` | OK |
| `/admin/leads/json` | GET | `?key=...` | reads `leads` | OK |
| `/` | GET | — | — | Health |

### Field mapping (submit-lead)

| Frontend field | API/store | DB column |
|----------------|-----------|-----------|
| `name`, `email`, `phone` | ✓ | `name`, `email`, `phone` |
| `message` | ✓ (in `data_json`) | — |
| `website`, `revenue`, `budget`, `problem` | ✓ | Direct columns |
| `formType`, `source` | ✓ | `form_type`, `source` |
| `industry`, `team`, `bottleneck` | ✓ | `data_json` |
| `utm_*`, `page_url`, `submittedAt`, `userAgent` | ✓ | `data_json` |

### Field mapping (submit-scaling-survey)

| Frontend field | API/store | DB column |
|----------------|-----------|-----------|
| `name`, `email` | ✓ | Direct |
| `company`, `role` | ✓ | Direct |
| `currentRevenue`, `targetRevenue`, `teamSize` | ✓ | `current_revenue`, etc. |
| `industry`, `biggestGoal` | ✓ | Direct |
| `challenges`, `channels` | ✓ | JSONB |
| `marketingSpend` | ✓ | `marketing_spend` |
| Full payload | ✓ | `raw_data` JSONB |

### god-mode-sdk.js endpoints

`public/js/god-mode-sdk.js` calls legacy God Mode routes that are not implemented in FastAPI:

- `/api/god/sql`, `/api/god/pool/stats`, `/api/god/db-status`, `/api/god/tables`, etc.
- These expect a previous backend (Django/other) and will 404 until implemented in FastAPI or removed.

---

## 4. Host-Specific / Path-Specific Code

| Location | Issue | Action |
|----------|-------|--------|
| `router.js` DOMAIN_MAP | `/home/opc/sites/...` | Use `SITES_BASE_PATH` env (e.g. `/home/opc/sites`) |
| `deploy.sh` | `SERVER="opc@193.122.168.215"` | Use `DEPLOY_SERVER` env |
| `ecosystem.config.js` | `cwd: "/home/opc/sites/jumpstartscaling"` | Use env or relative paths |
| `configure_directus_previews.py` | `DIRECTUS_URL`, `spark.jumpstartscaling.com` | Use env vars |
| Tunnel/DNS scripts | Oracle IP, tunnel config paths | Use env vars for IPs and paths |

---

## 5. Unused / Orphaned Scripts

### Unused (candidates for removal or archive)

- `api/leads.js` — Express/SQLite; router uses Postgres or FastAPI instead.
- `jumpstart-survey-update.js` — Survey question definitions; may be superseded by components.
- Duplicate deploy scripts: `deploy_FINAL.sh`, `deploy_FINAL_v3.sh`, `deploy_full_jumpstart.sh`, `deploy_sites_final.sh`, `deploy_production.sh`, `deploy_components.sh`, etc. — Consolidate or archive.
- `fix_dns_final.js`, `update_dns.js` — Overlap with Python DNS scripts.

### Host-specific (Oracle / Cloudflare)

These assume Oracle or Cloudflare setup and are not Coolify-centric:

- `create_tunnel_local.py`, `emergency_tunnel_gen.py`, `auto_install_tunnel.py`
- `restore_tunnel_full.sh`, `install_emergency_tunnel.sh`, `complete_tunnel_setup.sh`
- `nuclear_reset.sh`, `nuclear_deploy.sh`, `switch_to_pure_tunnel.sh`
- `update_dns_new_ip.py`, `update_cf_dns.py`, `force_cf_settings.py`, `fix_config_enforce.py`

Move to something like `scripts/oracle/` or `scripts/cloudflare/` and add a short README.

---

## 6. Missing Code

| Item | Status |
|------|--------|
| Admin pages in `project_manifest.json` | Only `admin.astro` exists; other admin routes not implemented |
| Admin components | Listed in manifest but many not found under `src/components/admin/` |
| Harris matrix API | No endpoints for `locations`, `pseo_services`, or `content_matrix` |
| god-mode-sdk routes | `/api/god/*` not implemented in FastAPI |
| `god_architect_local/` | Referenced in docs; directory and scripts missing. Content lives in `spark/exports/` |

### Content data location: spark/exports/

Directus exports (2025-12-13) at `spark/exports/` contain the canonical content for DB seeding:

- **geo_intelligence_*.json** → `locations`
- **generation_jobs_*.json** → `pseo_services` (extract niches) + `content_matrix` (slug, title, content_json)
- **content_fragments_*.json** → reusable blocks (optional)

Seed script: `python-api/scripts/seed_from_exports.py`. Run after Harris matrix schema (Phase 2).

---

## 7. Coolify Environment Variables (Recommended)

Set these in Coolify per application:

### Router (multisite)

```
PORT=8100
DATABASE_URL=postgresql://...
GOD_MODE_API_URL=https://api.jumpstartscaling.com
ADMIN_KEY=<secure-random>
SITES_BASE_PATH=/path/to/sites
```

### God Mode API (FastAPI)

```
PORT=8200
DATABASE_URL=postgresql://...
ADMIN_KEY=<secure-random>
LOG_REQUESTS=true
```

### Sites (jumpstartscaling, chrisamaya)

```
PUBLIC_API_URL=https://jumpstartscaling.com
PUBLIC_PAYLOAD_URL=https://cms.jumpstartscaling.com
```

### Scripts (Cloudflare/DNS)

```
CLOUDFLARE_API_TOKEN=...
CLOUDFLARE_ZONE_ID=...
NEW_SERVER_IP=...
```

---

## 8. Summary Checklist

- [ ] Replace `ADMIN_PASS` in `router.js` with `ADMIN_KEY` env
- [ ] Remove hardcoded Cloudflare tokens/zone IDs; use env vars
- [ ] Remove hardcoded DB URLs from `factory_fix.sh`, `test-db-connection.mjs`
- [ ] Add Harris matrix tables (`locations`, `pseo_services`, `content_matrix`) if pSEO is in scope
- [ ] Add `PUBLIC_PAYLOAD_URL` (or equivalent) for `src/lib/payload.ts`
- [ ] Archive or remove unused deploy/DNS scripts; consolidate where possible
- [ ] Move credentials in docs to a password manager; keep only references in repo
