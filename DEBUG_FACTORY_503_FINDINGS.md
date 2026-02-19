# Debug: Factory /admin/ 503

## Root cause (confirmed via Coolify API)

**god-mode-api** container is in a **restart loop** (`status=restarting:unknown`).

- JFactory: ✅ `running:healthy` (port 8100)
- god-mode-api: ❌ `restarting:unknown` (port 8200)
- factory.jumpstartscaling.com/health: 200 ✅
- factory.jumpstartscaling.com/admin/: 503 (proxies to API)
- api.jumpstartscaling.com/health: 503 (Traefik "No available server")

## Run debug without SSH

```bash
# Requires COOLIFY_TOKEN in .env.local (Coolify → Keys & Tokens)
node scripts/debug-coolify-api.mjs
```

## Run debug on server (SSH)

```bash
ssh root@86.48.23.38
bash < /path/to/scripts/debug-coolify-server.sh
# Or paste the script contents
```

Or copy script first:
```bash
scp scripts/debug-coolify-server.sh root@86.48.23.38:/tmp/
ssh root@86.48.23.38 'bash /tmp/debug-coolify-server.sh'
```

## Fixes applied (python-api)

1. **connection.py**: Added `timeout=8` to asyncpg pool (avoid hang on unreachable DB)
2. **config.py**: `LOG_REQUESTS` default `false` (avoids DB access when not configured)
3. **main.py**: Middleware only calls `get_db()` when `DATABASE_URL` is set

## Next steps

1. Ensure god-mode-api Coolify app builds from this repo's `python-api/` (or merge these changes into its source)
2. Add `DATABASE_URL` in Coolify → god-mode-api → Environment (Postgres from Coolify)
3. Or deploy without DB—app starts; DB routes return 503
4. Disable health check for god-mode-api in Coolify if needed
5. Redeploy god-mode-api, restart proxy
