# 🚀 DEPLOYMENT INSTRUCTIONS - Option 2

## What We're Doing

1. ✅ **Updated the source code** - Added `push: true` to `payload.config.ts`
2. ✅ **Committed the change** - Git commit created
3. 🔄 **Need to redeploy** - Trigger rebuild in Coolify
4. 🔒 **SSL is already configured** - Cloudflare handles SSL automatically

---

## 📋 Steps to Complete Deployment

### Step 1: Access Coolify UI

Go to: **http://spark.jumpstartscaling.com:8000**

Or: **http://193.122.168.215:8000**

### Step 2: Find Your Payload CMS Application

1. **Log into Coolify**
2. **Go to "Applications"** or **"Resources"**
3. **Find:** `jumpstartscalingjumpstartscalingmain-ksgwgg0kg08o000s80wcgkks`
   - Or look for Application ID: `7`
   - Or search for: "Payload" or "CMS"

### Step 3: Trigger Redeploy

1. **Click on the application** to open it
2. **Look for one of these buttons:**
   - **"Redeploy"**
   - **"Deploy"**
   - **"Restart & Rebuild"**
   - **"Force Deploy"**
3. **Click the button**
4. **Wait for deployment** (usually 2-5 minutes)

### Step 4: Monitor the Deployment

Watch the deployment logs in Coolify. You should see:
- ✅ Pulling latest code from GitHub
- ✅ Installing dependencies
- ✅ Building Next.js application
- ✅ Starting container
- ✅ **Database tables being created automatically!** (this is the new part)

### Step 5: Verify SSL Certificate

In Coolify, check the **Domains** tab:
- Domain: `cms.jumpstartscaling.com`
- SSL: Should show **"Enabled"** or **"Let's Encrypt"**
- If not enabled, click **"Generate SSL Certificate"** or **"Enable HTTPS"**

---

## 🔒 SSL Configuration

**Good news:** SSL is already working via Cloudflare!

### Current Setup:
- ✅ Cloudflare proxy: **Enabled** (orange cloud)
- ✅ Cloudflare SSL mode: **Full**
- ✅ HTTPS working: `https://cms.jumpstartscaling.com`

### Optional: Server-Side SSL Certificate

If you want a Let's Encrypt certificate on the server (not required):

1. **In Coolify**, go to your application
2. **Domains tab**
3. **Click "Generate SSL Certificate"** or **"Enable Let's Encrypt"**
4. **Wait 2-3 minutes** for certificate generation

**Note:** This is optional since Cloudflare already provides SSL.

---

## ✅ After Deployment Completes

1. **Visit:** https://cms.jumpstartscaling.com
2. **You should see:** Payload CMS setup wizard (no more database errors!)
3. **Create your first admin user:**
   - Email: your@email.com
   - Password: (strong password)
4. **Create your first tenant**
5. **Start managing content!** 🎉

---

## 🔍 Verify Database Tables Were Created

After deployment, you can verify tables were created:

```bash
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# Connect to database
docker exec -it ok4gk4kc4kk0w4wgsksskswg psql -U postgres

# List tables
\dt

# You should see:
# - users
# - users_roles
# - users_sessions
# - tenants
# - pages
# - media
# - payload_preferences
# - payload_migrations

# Exit
\q
exit
```

---

## 🆘 If Deployment Fails

### Check Deployment Logs

In Coolify:
1. Go to your application
2. Click **"Deployments"** or **"Logs"**
3. Look for error messages

### Common Issues:

**Issue: Build fails with "Module not found"**
- Solution: Clear build cache in Coolify and redeploy

**Issue: Container won't start**
- Solution: Check environment variables (DATABASE_URI, PAYLOAD_SECRET)

**Issue: Still getting database errors**
- Solution: Check the logs to ensure `push: true` is being used
- Run: `ssh -i ~/.ssh/id_rsa opc@193.122.168.215 'docker logs $(docker ps --filter "name=ksgwgg0kg08o000s80wcgkks" --format "{{.ID}}") --tail 100'`

---

## 📋 Quick Checklist

- [ ] Access Coolify UI at spark.jumpstartscaling.com:8000
- [ ] Find Payload CMS application
- [ ] Click "Redeploy" or "Deploy"
- [ ] Wait for deployment to complete (2-5 minutes)
- [ ] Check SSL is enabled in Domains tab
- [ ] Visit https://cms.jumpstartscaling.com
- [ ] See Payload CMS setup wizard (no database errors!)
- [ ] Create admin user
- [ ] Create first tenant
- [ ] Start using CMS! ✅

---

## 🎯 What Changed

**Before:**
```typescript
db: postgresAdapter({
  pool: {
    connectionString: process.env.DATABASE_URI || '',
  },
}),
```

**After:**
```typescript
db: postgresAdapter({
  pool: {
    connectionString: process.env.DATABASE_URI || '',
  },
  push: true, // ← This line was added!
}),
```

**Result:** Database tables will be automatically created on startup! 🎉

---

## 🚀 Next Steps After CMS is Running

1. **Create your first tenant** (e.g., "JumpStart Scaling")
2. **Create your first page**
3. **Upload some media**
4. **Explore the Payload CMS admin interface**
5. **Connect your Next.js frontend** to fetch content from the CMS

---

**Go to Coolify now and click "Redeploy"!** 🚀
