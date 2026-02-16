# 🔱 SQL INJECTION VIA GOD MODE API - EXECUTION GUIDE

## ✅ READY TO EXECUTE!

I've created an API endpoint that will execute the SQL injection directly using God Mode's database connection.

---

## 🚀 STEP-BY-STEP EXECUTION:

### Step 1: Start God Mode

```bash
cd /Users/christopheramaya/Downloads/spark/god-mode
npm run dev
```

Wait for the server to start on `http://localhost:4321`

---

### Step 2: Execute SQL Injection

**Option A: Run everything at once (Recommended)**

```bash
python3 god_architect_local/inject_via_api.py all
```

**Option B: Run specific injections**

```bash
# Just avatars and geo clusters
python3 god_architect_local/inject_via_api.py avatars

# Just content blocks
python3 god_architect_local/inject_via_api.py content_blocks

# Just 1,000 pSEO pages
python3 god_architect_local/inject_via_api.py pseo_pages
```

**Option C: Use cURL directly**

```bash
# Check current status
curl http://localhost:4321/api/inject-data

# Execute all injections
curl -X POST http://localhost:4321/api/inject-data \
  -H "Content-Type: application/json" \
  -d '{"sql_file":"all","execute":true}'
```

---

## 📊 WHAT GETS INJECTED:

### When you run `all`:

1. **Avatars (10)** - `comprehensive_inject.sql`
   - 10 avatar definitions with pronoun variants
   - Geo clusters for each avatar
   - Offer blocks
   - Cross-site links

2. **Content Blocks (27)** - `content_blocks_inject.sql`
   - 9 blocks for Jumpstart Scaling
   - 9 blocks for Christopher Amaya
   - 9 blocks for Masta Codes
   - All with spintax templates

3. **pSEO Pages (1,000)** - `bulk_pseo_insert.sql`
   - 1,000 localized SEO pages
   - Distributed across 3 sites
   - Service × Location combinations

---

## ✅ VERIFICATION:

After injection, the API will return counts:

```json
{
  "success": true,
  "verification": {
    "avatars": 10,
    "geo_clusters": 10,
    "content_blocks": 27,
    "offer_blocks": 6,
    "cross_links": 3,
    "posts": 1000
  }
}
```

---

## 🔧 TROUBLESHOOTING:

### Error: "Could not connect to API"
**Solution:** Make sure God Mode is running
```bash
npm run dev
```

### Error: "Cannot find module 'db'"
**Solution:** Check that `src/lib/db.ts` exists with your database connection

### Error: "SQL file not found"
**Solution:** Make sure you're in the god-mode directory when running

---

## 📁 FILES INVOLVED:

```
src/pages/api/inject-data.ts          ← API endpoint
god_architect_local/
├── inject_via_api.py                 ← Python client
├── comprehensive_inject.sql          ← Avatars, geo, offers
├── content_blocks_inject.sql         ← 27 content blocks
└── bulk_pseo_insert.sql              ← 1,000 pages
```

---

## 🎯 COMPLETE INJECTION COMMAND:

```bash
# 1. Start server
npm run dev

# 2. In another terminal, inject all data
python3 god_architect_local/inject_via_api.py all
```

**That's it!** The API will:
1. Read all 3 SQL files
2. Execute them on your database
3. Return verification counts
4. Show success/error for each file

---

## 📊 EXPECTED OUTPUT:

```
================================================================================
🔱 TRIGGERING SQL INJECTION VIA GOD MODE API
================================================================================

📊 Checking current database status...

✅ Current counts:
   avatars: 0
   geo_clusters: 0
   content_blocks: 0
   offer_blocks: 0
   cross_links: 0
   posts: 0

💉 Executing SQL injection: all
   This may take a moment...

✅ INJECTION COMPLETE!

📋 Results:
   ✅ comprehensive_inject.sql: Executed successfully
   ✅ content_blocks_inject.sql: Executed successfully
   ✅ bulk_pseo_insert.sql: Executed successfully

📊 Final counts:
   avatars: 10
   geo_clusters: 10
   content_blocks: 27
   offer_blocks: 6
   cross_links: 3
   posts: 1000

================================================================================
🎉 ALL DATA INJECTED SUCCESSFULLY!
================================================================================
```

---

**Ready to execute! Just start God Mode and run the injection script.** 🔱✨
