# 🚀 Fix Deployment Guide

## What Was Fixed

**Problem**: God Mode showed "❌ No site found" and "Failed to fetch site for domain: 401"

**Root Cause**: Middleware was querying Directus at `office.jumpstartscaling.com` instead of God Mode's own PostgreSQL database

**Solution**: Updated middleware to query PostgreSQL directly using the existing connection pool

---

## Changes Made

### ✅ [src/middleware.ts](file:///Users/christopheramaya/Downloads/spark/god-mode/src/middleware.ts)

**Before:**
- ❌ Queried external Directus API (`https://office.jumpstartscaling.com/items/sites`)
- ❌ Required `GOD_MODE_TOKEN` for authentication
- ❌ Failed with 401 errors

**After:**
- ✅ Queries local PostgreSQL database directly
- ✅ Uses existing `pool` from `src/lib/db.ts`
- ✅ No external API dependencies
- ✅ No authentication needed (internal DB query)

**Key Changes:**
```diff
- import { GOD_MODE_TOKEN } from 'astro:env/server';
- const DIRECTUS_URL = 'https://office.jumpstartscaling.com';
+ import { pool } from '../lib/db';

- const response = await fetch(
-     `${DIRECTUS_URL}/items/sites?filter[domain][_eq]=${domain}`,
-     { headers: { 'Authorization': `Bearer ${GOD_MODE_TOKEN}` } }
- );
- const data = await response.json();
- const site = data.data?.[0] || null;
+ const result = await pool.query(
+     'SELECT id, domain, name, type, theme, status, config FROM sites WHERE domain = $1 AND status = $2',
+     [domain, 'active']
+ );
+ const site = result.rows[0] || null;
```

---

## Deployment Steps

### 1. Verify Environment Variable

**In Coolify**, ensure `DATABASE_URL` is set:

1. Go to your God Mode deployment
2. Navigate to **Environment Variables**
3. Verify `DATABASE_URL` exists and looks like:
   ```
   postgresql://user:password@host:5432/database?sslmode=require
   ```
4. If missing, add it (should already be there from initial setup)

### 2. Commit and Push Changes

```bash
cd /Users/christopheramaya/Downloads/spark/god-mode

# Check what changed
git status
git diff src/middleware.ts

# Commit the fix
git add src/middleware.ts
git commit -m "Fix: Middleware now queries PostgreSQL directly instead of Directus

- Removed external Directus API dependency
- Query sites table directly using pool from src/lib/db.ts
- Eliminates 401 authentication errors
- Fixes 'No site found' error for spark.jumpstartscaling.com"

# Push to repository
git push origin main
```

### 3. Deploy to Coolify

**Option A: Auto-Deploy** (if enabled)
- Coolify will automatically pick up the git push and redeploy

**Option B: Manual Deploy**
1. Go to Coolify dashboard
2. Find your God Mode deployment
3. Click **"Redeploy"**
4. Wait for build and deployment to complete

### 4. Verify Deployment

**Check Logs:**
1. In Coolify, go to deployment logs
2. Look for these SUCCESS indicators:
   ```
   ✅ Python Bridge started (PID: 8)
   ✅ [@astrojs/node] Server listening on http://localhost:4321
   ✅ Site loaded: Spark Platform Admin (spark.jumpstartscaling.com)
   ```

3. Should **NOT** see:
   ```
   ❌ No site found for: /
   Failed to fetch site for domain: 401
   ```

**Test the Domain:**
1. Visit: https://spark.jumpstartscaling.com
2. Should load successfully (not redirect to admin or show 503)

---

## What Happens After Deployment

### Request Flow (Fixed)

```
1. User visits spark.jumpstartscaling.com
2. Middleware extracts domain: "spark.jumpstartscaling.com"
3. Check cache (empty on first request)
4. Query PostgreSQL:
   SELECT * FROM sites WHERE domain = 'spark.jumpstartscaling.com' AND status = 'active'
5. Site found! (created by migration 01_init_complete.sql)
6. Cache result for 5 minutes
7. Inject site context into request
8. Continue to route handler
✅ Page loads successfully
```

### Logs You'll See

**On startup:**
```
🔱 God Mode - Starting Dual Services...
📡 Starting Python Bridge (FastAPI) on port 8505...
✅ Python Bridge started (PID: 8)
🚀 Starting Astro SSR Server on port 4321...
[@astrojs/node] Server listening on http://localhost:4321
```

**On first request:**
```
🌐 Custom domain mode: spark.jumpstartscaling.com/
✅ Site loaded: Spark Platform Admin (spark.jumpstartscaling.com)
```

**On subsequent requests (cached):**
```
🌐 Custom domain mode: spark.jumpstartscaling.com/about
✅ Site loaded: Spark Platform Admin (spark.jumpstartscaling.com)
```

---

## Rollback Plan (If Needed)

If something goes wrong:

```bash
# Revert the commit
git revert HEAD
git push origin main

# Or checkout previous version
git checkout HEAD~1 src/middleware.ts
git commit -m "Rollback: Revert middleware changes"
git push origin main
```

Then redeploy in Coolify.

---

## Testing Checklist

After deployment, verify:

- [ ] Coolify logs show "✅ Site loaded: Spark Platform Admin"
- [ ] No "401" errors in logs
- [ ] https://spark.jumpstartscaling.com loads successfully
- [ ] Admin routes still work (e.g., /admin/sites)
- [ ] API endpoints still work (e.g., /api/god/db-status)

---

## Why This Works

1. **Site Record Exists**: Migration `01_init_complete.sql` already created the site record for `spark.jumpstartscaling.com`
2. **Database Connection Exists**: God Mode already has a working PostgreSQL pool at `src/lib/db.ts`
3. **No External Dependencies**: No longer relies on Directus being available
4. **Faster**: Direct database query is faster than HTTP API call
5. **Cached**: Results are cached for 5 minutes to minimize database load

---

## Environment Variables Status

### ✅ Required (Already Set in Coolify)
- `DATABASE_URL` - PostgreSQL connection string

### ❌ No Longer Required for Middleware
- `GOD_MODE_TOKEN` - Still used by API endpoints, but NOT by middleware anymore

### ❌ Not Used Anywhere
- `DIRECTUS_PUBLIC_URL` - Can be removed if not used elsewhere

---

## Next Steps

1. **Immediate**: Deploy the fix to Coolify
2. **Verification**: Check logs and test the domain
3. **Cleanup**: Consider removing unused DIRECTUS-related environment variables
4. **Documentation**: Update any internal docs that mention Directus dependency

---

**Ready to deploy?** Follow steps 2-4 above to push the fix to Coolify! 🚀
