# ⚡ SIMPLE FIX - 2 MINUTES

## The Problem

Coolify deploys from GitHub, but GitHub doesn't have your `push: true` change.

## The Solution

**Edit the file directly on GitHub:**

### Step 1: Edit on GitHub

1. **Open:** https://github.com/jumpstartscaling/jumpstartscaling/blob/main/src/payload.config.ts

2. **Click:** Edit button (pencil icon in top right)

3. **Find line 30-33** (around line 30):
   ```typescript
   db: postgresAdapter({
     pool: {
       connectionString: process.env.DATABASE_URI || '',
     },
   }),
   ```

4. **Change to:**
   ```typescript
   db: postgresAdapter({
     pool: {
       connectionString: process.env.DATABASE_URI || '',
     },
     push: true, // Auto-create database tables
   }),
   ```

5. **Scroll down** → Add commit message: "Enable auto-push for database tables"

6. **Click:** "Commit changes"

### Step 2: Redeploy in Coolify

1. **Open:** http://spark.jumpstartscaling.com:8000
2. **Find:** Your Payload CMS application
3. **Click:** "Redeploy"
4. **Wait:** 3-5 minutes

### Step 3: Visit Site

**Open:** https://cms.jumpstartscaling.com

**You'll see:** Payload CMS setup wizard! ✅

---

## That's It!

Just edit one line on GitHub, redeploy, and you're done! 🚀

**Start here:** https://github.com/jumpstartscaling/jumpstartscaling/blob/main/src/payload.config.ts
