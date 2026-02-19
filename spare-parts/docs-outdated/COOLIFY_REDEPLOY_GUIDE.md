# 🔱 MANUAL COOLIFY REDEPLOYMENT INSTRUCTIONS

## METHOD 1: Via Coolify UI (Recommended)

1. Go to your Coolify dashboard
2. Find "God Mode" application
3. Click **"Redeploy"** or **"Force Redeploy"**
4. Wait ~5-10 minutes for completion
5. Verify completion (look for "Successfully deployed")

---

## METHOD 2: Via Coolify API

### Prerequisites:
- Coolify API Token
- Coolify URL

### Steps:

```bash
# Set environment variables
export COOLIFY_URL="https://your-coolify-url.com"
export COOLIFY_TOKEN="your-api-token-here"

# Run the redeploy script
python3 god_architect_local/coolify_redeploy.py
```

---

## METHOD 3: Manual Git Push Trigger

If Coolify is configured to auto-deploy on git push:

```bash
# Make a trivial change to trigger rebuild
echo "# Trigger deployment" >> README.md
git add README.md
git commit -m "🚀 Trigger redeployment for SQL Console"
git push
```

---

## WHAT THE REDEPLOY WILL FIX:

✅ Deploy SQL Console endpoint (`/api/sql-console`)  
✅ Deploy simplified SQL files (no array errors)  
✅ Enable immediate data injection  
✅ Sync all latest code changes  

---

## AFTER REDEPLOYMENT:

### 1. Verify SQL Console is Live:

```bash
curl "https://spark.jumpstartscaling.com/api/sql-console"
```

**Should return:**
```json
{
  "endpoint": "/api/sql-console",
  "method": "POST",
  ...
}
```

###  2. Execute Data Injection:

```bash
python3 god_architect_local/inject_via_console.py god_architect_local/schema_corrected_inject.sql
```

### 3. Verify in Directus:

- Go to https://office.jumpstartscaling.com
- Content → Avatars (should see 10 entries)
- Content → Geo Clusters (should see 10 entries)
- Content → Content Blocks (should see 3 entries)

---

## TROUBLESHOOTING:

**If deployment fails again:**
1. Check Coolify logs for errors
2. Verify git commit is correct (`c31ec95` or later)
3. Check Docker build logs
4. Ensure no resource constraints (CPU/RAM)

**If SQL Console still doesn't work:**
1. SSH into the container
2. Check if `/app/src/pages/api/sql-console.ts` exists
3. Restart the container manually

---

## 🎯 RECOMMENDATION:

**Use METHOD 1** (Coolify UI) - it's the most reliable and shows real-time logs.

**Time Estimate:** 5-10 minutes total

**Success Indicator:** Site remains online + SQL Console responds

---

**Once deployed, you're 100% done!** 🔱✨
