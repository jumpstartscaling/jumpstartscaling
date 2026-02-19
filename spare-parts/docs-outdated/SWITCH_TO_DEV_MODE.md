# 🔧 SWITCH TO DEVELOPMENT MODE

## Current Issue

The error you're seeing is still the database tables issue, but it's hidden in production mode.

**Error:** `relation "users" does not exist`

This confirms the container is running the OLD code (without `push: true`).

---

## 🎯 Solution: Update Environment & Redeploy

We need to:
1. Set `NODE_ENV=development` in Coolify
2. Trigger redeploy to use updated code with `push: true`
3. Database tables will be created automatically

---

## 📋 Steps to Switch to Development Mode

### Step 1: Access Coolify

Go to: **http://spark.jumpstartscaling.com:8000**

### Step 2: Find Your Application

Search for:
- `cms.jumpstartscaling.com`
- OR `ksgwgg0kg08o000s80wcgkks`

### Step 3: Update Environment Variables

1. **Click on your application**
2. **Go to "Environment Variables" tab** (or "Environment" or "Env")
3. **Find or add:** `NODE_ENV`
4. **Change value from:** `production`
5. **To:** `development`
6. **Click "Save"**

### Step 4: Redeploy

1. **Click "Redeploy"** or **"Deploy"** button
2. **Wait 2-5 minutes**
3. **This will:**
   - Pull updated code (with `push: true`)
   - Build in development mode
   - Auto-create database tables
   - Show detailed error messages

### Step 5: Visit Site

Go to: **https://cms.jumpstartscaling.com**

You should now see:
- ✅ Detailed error messages (if any)
- ✅ OR Payload CMS setup wizard (if tables created successfully)

---

## 🚀 Alternative: Quick Command Line Method

If you prefer command line:

```bash
# SSH to server
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# Stop current container
docker stop ksgwgg0kg08o000s80wcgkks-191538437129

# Update environment in Coolify
# (This needs to be done via Coolify UI)

# Or manually run in development mode:
cd /home/opc/payload-multitenant
NODE_ENV=development npm run dev
```

**Note:** Manual method won't persist. Use Coolify UI for permanent change.

---

## 🔍 What Development Mode Shows

### Production Mode (Current):
```
Error: An error occurred in the Server Components render.
The specific message is omitted in production builds...
```

### Development Mode (After Change):
```
Error: Failed query: relation "users" does not exist
Code: 42P01
File: parse_relation.c
Line: 1449

This is because database tables haven't been created yet.
```

**Much more helpful!** 🎯

---

## ✅ Expected Outcome

After switching to development mode and redeploying:

1. **Container starts** with updated code (`push: true`)
2. **Payload CMS detects** empty database
3. **Automatically creates tables:**
   - users
   - users_roles
   - users_sessions
   - tenants
   - pages
   - media
4. **Application starts successfully**
5. **You see:** Payload CMS setup wizard! ✅

---

## 🆘 If Tables Still Don't Create

If after redeploy you still get database errors:

### Check if push: true is active:

```bash
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# Check source code
cat /home/opc/payload-multitenant/src/payload.config.ts | grep "push:"
# Should show: push: true,

# Check running container
docker exec ksgwgg0kg08o000s80wcgkks-191538437129 cat src/payload.config.ts | grep "push:"
# Should show: push: true,
```

### Manually create tables:

If auto-push still doesn't work, use the SQL from `IMMEDIATE_ACTION.md`:

```bash
ssh -i ~/.ssh/id_rsa opc@193.122.168.215
docker exec -it ok4gk4kc4kk0w4wgsksskswg psql -U postgres

# Run the CREATE TABLE commands from IMMEDIATE_ACTION.md
```

---

## 📋 Quick Checklist

- [ ] Open Coolify UI
- [ ] Find Payload CMS application
- [ ] Go to Environment Variables tab
- [ ] Change `NODE_ENV` to `development`
- [ ] Save changes
- [ ] Click "Redeploy"
- [ ] Wait for deployment (2-5 min)
- [ ] Visit https://cms.jumpstartscaling.com
- [ ] See detailed errors OR setup wizard ✅

---

## 🎯 Why This Matters

**Development mode:**
- ✅ Shows full error messages
- ✅ Better debugging
- ✅ Hot reload (if using `npm run dev`)
- ✅ Source maps
- ✅ Detailed stack traces

**Production mode:**
- ❌ Hides error details
- ❌ Harder to debug
- ✅ Faster performance
- ✅ Optimized bundles

**For now:** Use development mode to debug, then switch back to production when working.

---

**Go to Coolify → Environment Variables → Set NODE_ENV=development → Redeploy!** 🚀
