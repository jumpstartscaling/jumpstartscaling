# 🔱 FINAL STEPS - DATA INJECTION

## ⚠️ CRITICAL: Server Needs Restart!

The local God Mode server is **NOT loading the `.env` file**, so `DATABASE_URL` is undefined!

## ✅ SOLUTION:

### Step 1: Restart the Server

In the terminal running `npm run dev`:

1. Press **`Ctrl+C`** to stop it
2. Run **`npm run dev`** again
3. Wait for it to start (should be on port 4324)

### Step 2: Verify DB Connection

```bash
curl http://localhost:4324/api/test-db | python3 -m json.tool
```

**Should show:**
```json
{
  "success": true,
  "database_url_exists": true,  ← Must be TRUE!
  "query_result": {...}
}
```

### Step 3: Inject Data

Once DB connection works:

```bash
# Update the API to support "core" option first, OR:
# Manually execute via Directus API
python3 god_architect_local/inject_via_api.py avatars
```

---

## 🎯 ALTERNATIVE: Use Directus API Directly

Since the local database connection isn't working, inject via Directus API:

```bash
python3 -c "
import requests
import json

DIRECTUS_URL = 'https://office.jumpstartscaling.com'
TOKEN = 'NbGrYlTL0t_AjaFhAH6D0q5biUHAMOkz'

headers = {'Authorization': f'Bearer {TOKEN}'}

# Create one avatar as test
avatar = {
    'name': 'The Tech Titan',
    'persona_type': 'scaling_founder',
    'industry': 'SaaS/Tech',
    'pain_point': 'Infrastructure breaks as you scale',
    'tone': 'Direct, technical',
    'config': {'avatar_id': 1, 'wealth_cluster': 'Tech-Native'}
}

r = requests.post(f'{DIRECTUS_URL}/items/avatars', headers=headers, json=avatar)
print(f'Status: {r.status_code}')
print(r.json())
"
```

---

## 📊 WHY THIS IS HAPPENING:

1. **Local Env Not Loaded**: The `.env` file exists but isn't being read by Astro
2. **Database Unreachable**: The AWS RDS host can't be resolved from your local network
3. **Server Must Restart**: Changes to `.env` require server restart

---

## 🚀 RECOMMENDED APPROACH:

**Use the PRODUCTION deployment to inject data**, not local!

The deployed God Mode on Coolify has:
- ✅ Direct database access
- ✅ Environment variables configured
- ✅ Network connectivity to RDS

**Wait for the deployment to rebuild with the schema fixes, then inject there!**

---

**TL;DR: Restart server OR wait for production deployment to inject data.** 🔱✨
