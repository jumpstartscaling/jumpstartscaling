# pSEO Factory — Complete Implementation Plan

**Version:** 1.0  
**Last Updated:** February 2026  
**Purpose:** All-inclusive plan to turn god-mode into a production-ready pSEO factory: PostgreSQL, FastAPI, Harris matrix, client sites, admin dashboard, and Coolify deployment.

---

## Executive Summary

The pSEO factory consists of:

1. **PostgreSQL** — Single source of truth for leads, surveys, locations, services, content_matrix
2. **FastAPI (god-mode-api)** — Backend API: lead capture, Harris matrix CRUD, admin endpoints
3. **Router** — Multi-domain routing: factory.jumpstartscaling.com, chrisamaya.work
4. **Client sites** — Astro sites: jumpstartscaling (factory), chrisamaya (tenant)
5. **Admin** — Leads dashboard (FastAPI), Harris matrix management UI (to build)
6. **pSEO pages** — Dynamic service×location pages from `content_matrix` (to build)
7. **Coolify** — Deployment via domain settings only (no Cloudflare tunnel)

---

## Architecture

```mermaid
flowchart TB
    subgraph dns [DNS - A Records to 86.48.23.38]
        A1[factory.jumpstartscaling.com]
        A2[chrisamaya.work]
        A3[api.jumpstartscaling.com]
    end

    subgraph coolify [Coolify Server]
        Traefik[Traefik 80/443]
        Router[God-Mode Router]
        API[god-mode-api FastAPI]
        DB[(PostgreSQL)]
        Dist1[jumpstartscaling dist]
        Dist2[chrisamaya dist]
    end

    subgraph data [Data Flow]
        Forms[Contact Forms / Surveys]
        API -->|submit-lead| DB
        API -->|submit-scaling-survey| DB
        API -->|Harris CRUD| DB
        API -->|seed| DB
    end

    A1 --> Traefik
    A2 --> Traefik
    A3 --> Traefik
    Traefik --> Router
    Traefik --> API
    API -->|DATABASE_URL| DB
    Router -->|factory| Dist1
    Router -->|chrisamaya| Dist2
    Router -->|/api/* /admin/* proxy| API
    Forms -->|POST| Router
```

---

## Domain Mapping

| Domain | Serves | Source |
|--------|--------|--------|
| **factory.jumpstartscaling.com** | JumpStart Scaling (factory) | `sites/jumpstartscaling/dist` |
| **chrisamaya.work** | Chris Amaya (tenant) | `sites/chrisamaya/dist` |
| **api.jumpstartscaling.com** | FastAPI backend | god-mode-api container |

---

## Phase 0: PostgreSQL Database Setup

**Prerequisite:** Coolify server running (86.48.23.38)

### 0.1 Create PostgreSQL in Coolify

- [ ] Coolify → **+ Add Resource** → **Database** → **PostgreSQL**
- [ ] Name: `god-mode-db`
- [ ] Note connection string from Coolify UI

### 0.2 Connection string format

```
postgresql://USER:PASSWORD@HOST:5432/DATABASE
```

### 0.3 Wire to god-mode-api

- [ ] god-mode-api app → Environment Variables → `DATABASE_URL` = connection string

### 0.4 Verify

- [ ] god-mode-api starts; `curl https://api.jumpstartscaling.com/` returns health
- [ ] Tables: `leads`, `scaling_survey_submissions`, `api_logs` (auto-created on first request)

---

## Phase 1: Security Fixes (Secrets to Env)

**Goal:** No hardcoded API keys, tokens, or passwords. All via Coolify env vars.

### 1.1 Router (`router.js`)

- [ ] Replace `ADMIN_PASS = 'spark'` with `process.env.ADMIN_KEY || 'spark'`
- [ ] Use `process.env.SITES_BASE_PATH` for domain paths (not `/home/opc/sites/`)
- [ ] Coolify env: `ADMIN_KEY`, `SITES_BASE_PATH`

### 1.2 Hardcoded secrets to remove/fix

| File | Action |
|------|--------|
| `update_dns_new_ip.py` | Delete or archive |
| `force_cf_settings.py` | Delete or archive |
| `emergency_tunnel_gen.py` | Delete or archive |
| `factory_fix.sh` | Remove hardcoded `DATABASE_URL`, `GOD_MODE_TOKEN` |
| `test-db-connection.mjs` | Remove fallback connection string |
| `src/lib/payload.ts` | Use `import.meta.env.PUBLIC_PAYLOAD_URL` |

### 1.3 Coolify env vars (god-mode router)

```
GOD_MODE_API_URL=https://api.jumpstartscaling.com
SITES_BASE_PATH=/app
ADMIN_KEY=<secure-random>
PUBLIC_N8N_WEBHOOK=https://n8n.jumpstartscaling.com/webhook/d282e622-9c83-4936-9d93-05c37eaa7b68
```

### 1.4 Coolify env vars (god-mode-api)

```
DATABASE_URL=postgresql://...
ADMIN_KEY=<secure-random>
LOG_REQUESTS=true
```

---

## Phase 2: Harris Matrix Schema + API + Seed

**Goal:** Full pSEO data layer: locations, pseo_services, content_matrix.

### 2.1 Add Harris schema to `python-api/app/db/connection.py`

- [ ] Add to `_SCHEMA_SQL`:

```sql
CREATE TABLE IF NOT EXISTS locations (
    id SERIAL PRIMARY KEY,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip TEXT,
    neighborhood TEXT,
    slug TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pseo_services (
    id SERIAL PRIMARY KEY,
    service_type TEXT NOT NULL,
    sub_niche TEXT,
    slug TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS content_matrix (
    id SERIAL PRIMARY KEY,
    location_id INT REFERENCES locations(id),
    service_id INT REFERENCES pseo_services(id),
    slug TEXT UNIQUE,
    title TEXT,
    meta_description TEXT,
    content_json JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2.2 Create FastAPI routers

- [ ] `python-api/app/routers/locations.py` — CRUD for locations
- [ ] `python-api/app/routers/pseo_services.py` — CRUD for pseo_services
- [ ] `python-api/app/routers/content_matrix.py` — CRUD + `GET /matrix/permutations`
- [ ] Add Pydantic models in `app/models.py` or `app/schemas/matrix.py`
- [ ] Register routers in `app/main.py`

### 2.3 Seed from spark/exports

- [ ] Run: `cd python-api && python scripts/seed_from_exports.py`
- [ ] Source: `spark/exports/` (geo_intelligence, generation_jobs)
- [ ] Verify: `locations`, `pseo_services`, `content_matrix` populated

---

## Phase 3: Router, Sites, Dockerfile, Admin, pSEO Pages

### 3.1 Router DOMAIN_MAP

- [ ] Update `router.js`:

```js
const BASE = process.env.SITES_BASE_PATH || '/app';
const DOMAIN_MAP = {
  'factory.jumpstartscaling.com': path.join(BASE, 'sites/jumpstartscaling/dist'),
  'www.factory.jumpstartscaling.com': path.join(BASE, 'sites/jumpstartscaling/dist'),
  'chrisamaya.work': path.join(BASE, 'sites/chrisamaya/dist'),
  'www.chrisamaya.work': path.join(BASE, 'sites/chrisamaya/dist'),
  'localhost': path.join(BASE, 'sites/jumpstartscaling/dist')
};
```

### 3.2 Site-to-API connectivity

- [ ] `sites/chrisamaya/public/index.html`: use `'/api/submit-lead'` (relative)
- [ ] All forms/surveys: relative `/api/submit-lead`, `/api/submit-scaling-survey`
- [ ] n8n webhook: `import.meta.env.PUBLIC_N8N_WEBHOOK` or env var

### 3.3 Site config (Astro)

- [ ] `sites/jumpstartscaling/astro.config.mjs`: `site: 'https://factory.jumpstartscaling.com'`
- [ ] `sites/chrisamaya/astro.config.mjs`: `site: 'https://chrisamaya.work'`

### 3.4 God-mode Dockerfile

- [ ] Create `Dockerfile` at god-mode root:
  - Install deps, build both sites, run router
  - `SITES_BASE_PATH=/app`
  - Coolify: build from Dockerfile, run as single app

### 3.5 Admin dashboard (Harris matrix)

- [ ] Add `sites/jumpstartscaling/src/pages/admin/` (or shared admin route)
- [ ] Admin index: links to Leads (proxy to FastAPI), Locations, Services, Content Matrix
- [ ] Locations CRUD page: fetch/post to `api.jumpstartscaling.com/locations` (proxy)
- [ ] Services CRUD page: fetch/post to `api.jumpstartscaling.com/pseo-services`
- [ ] Content Matrix CRUD page: fetch/post to `api.jumpstartscaling.com/content-matrix`
- [ ] Protect with `?key=...` or basic auth (align with FastAPI ADMIN_KEY)
- [ ] Router must proxy `/admin/*` to FastAPI when under api subdomain, or serve from site when under factory

**Note:** FastAPI already has `/admin/leads` and `/admin/leads/json`. Admin UI can live at `factory.jumpstartscaling.com/admin` and call API, or at `api.jumpstartscaling.com/admin` (proxied to FastAPI).

### 3.6 pSEO dynamic page routes

- [ ] Add route: `sites/jumpstartscaling/src/pages/services/pseo/[slug].astro`
- [ ] `getStaticPaths`: fetch slugs from `GET /matrix/permutations` at build time, or use SSR
- [ ] For static build: add build step that calls API, generates paths
- [ ] For SSR: use `getStaticPaths` with `fetch` to API (requires Astro SSR or adapter)
- [ ] Page template: render `title`, `meta_description`, `content_json` from content_matrix

**Simpler option:** Keep existing `services/[...slug].astro` from content collection for manual service pages; add separate `pseo/[slug].astro` that fetches from API. Use `output: 'server'` or prerender with API at build.

---

## Phase 4: Coolify Domain Setup (No Tunnel)

### 4.1 DNS (domain provider)

Add A records pointing to `86.48.23.38`:

| Domain | Type | Target |
|--------|------|--------|
| factory.jumpstartscaling.com | A | 86.48.23.38 |
| www.factory.jumpstartscaling.com | A or CNAME | 86.48.23.38 |
| chrisamaya.work | A | 86.48.23.38 |
| www.chrisamaya.work | A or CNAME | 86.48.23.38 |
| api.jumpstartscaling.com | A | 86.48.23.38 |

### 4.2 Coolify app configuration

- [ ] **God-mode app**: Domains = factory.jumpstartscaling.com, www.factory.jumpstartscaling.com, chrisamaya.work, www.chrisamaya.work
- [ ] **god-mode-api app**: Domain = api.jumpstartscaling.com

### 4.3 SSL

- [ ] Coolify/Traefik handles Let's Encrypt
- [ ] If using Cloudflare proxy: SSL mode = Full

---

## Phase 5: Documentation + Checklist

### 5.1 Create LAUNCH_CHECKLIST.md

- [ ] PostgreSQL setup steps
- [ ] Security verification (no hardcoded secrets)
- [ ] DOMAIN_MAP, site config, Dockerfile
- [ ] DNS records, Coolify domains
- [ ] Env vars per app
- [ ] Form/survey test flow
- [ ] Admin leads: `https://api.jumpstartscaling.com/admin/leads?key=...`

### 5.2 Update SECURITY_AND_ARCHITECTURE_AUDIT.md

- [ ] Add "Launch Prep" summary
- [ ] Document content data: `spark/exports/`, seed script
- [ ] Note: factory + chrisamaya = god-mode; no tunnel

### 5.3 Root .env.example

- [ ] `GOD_MODE_API_URL`, `SITES_BASE_PATH`, `ADMIN_KEY`, `PUBLIC_N8N_WEBHOOK`

---

## Phase 6: Optional Cleanup

- [ ] Archive: `update_dns_new_ip.py`, `force_cf_settings.py`, `emergency_tunnel_gen.py`
- [ ] Archive: `api/leads.js` (Express/SQLite)
- [ ] `scripts/archive/README.md`: "Oracle/Cloudflare scripts — not used for Coolify"

---

## File-Level Todo Summary

| Action | Files |
|--------|-------|
| **Edit** | `router.js`, `python-api/app/db/connection.py`, `sites/chrisamaya/public/index.html`, `sites/jumpstartscaling/astro.config.mjs`, `sites/chrisamaya/astro.config.mjs`, `src/lib/payload.ts`, `test-db-connection.mjs`, `factory_fix.sh` |
| **Create** | `python-api/app/routers/locations.py`, `pseo_services.py`, `content_matrix.py`, `python-api/app/schemas/matrix.py`, `Dockerfile`, `LAUNCH_CHECKLIST.md`, `.env.example`, `sites/jumpstartscaling/src/pages/admin/*.astro`, `sites/jumpstartscaling/src/pages/services/pseo/[slug].astro` (if pSEO pages) |
| **Delete/Archive** | `update_dns_new_ip.py`, `force_cf_settings.py`, `emergency_tunnel_gen.py`, tunnel scripts |
| **Update** | `SECURITY_AND_ARCHITECTURE_AUDIT.md`, `python-api/README.md` |

---

## Execution Order

```
0. Phase 0: PostgreSQL in Coolify, DATABASE_URL to god-mode-api
1. Phase 1: Security fixes (router, remove hardcoded secrets)
2. Phase 2: Harris schema + FastAPI routers + seed from spark/exports
3. Phase 3: Router DOMAIN_MAP, site config, Dockerfile, admin UI, pSEO routes
4. Phase 4: DNS + Coolify domains (manual)
5. Phase 5: Docs + LAUNCH_CHECKLIST
6. Phase 6: Archive unused (optional)
```

---

## Cursor Todo List (for tracking)

| ID | Phase | Description |
|----|-------|--------------|
| p1 | 0 | PostgreSQL setup in Coolify + DATABASE_URL |
| p2a | 1 | Security - move all secrets to env vars |
| p2b | 2 | Harris schema + FastAPI routers |
| p2c | 2 | Seed from spark/exports |
| p3a | 3 | Router DOMAIN_MAP + site-to-API + Dockerfile |
| p3b | 3 | Admin UI for Harris matrix |
| p3c | 3 | pSEO dynamic page routes |
| p4 | 4 | DNS + Coolify domains + env vars |
| p5 | 5 | Docs + LAUNCH_CHECKLIST |

---

## References

- Launch Prep plan: `.cursor/plans/launch_prep_security_harris_af639ec0.plan.md`
- Spark Exports plan: `.cursor/plans/spark_exports_to_postgresql_eef87284.plan.md`
- Security audit: `SECURITY_AND_ARCHITECTURE_AUDIT.md`
- Content data: `spark/exports/`
- Seed script: `python-api/scripts/seed_from_exports.py`
- Coolify server: 86.48.23.38
