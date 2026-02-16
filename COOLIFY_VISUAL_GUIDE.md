# 🎯 COOLIFY REDEPLOY - VISUAL GUIDE

## Quick Access

**Coolify URL:** http://spark.jumpstartscaling.com:8000

---

## 📸 Step-by-Step Visual Guide

### Step 1: Login to Coolify

```
┌─────────────────────────────────────────┐
│  Coolify                                │
│  ─────────────────────────────────────  │
│                                         │
│  Email:    [________________]           │
│  Password: [________________]           │
│                                         │
│  [Login]                                │
└─────────────────────────────────────────┘
```

### Step 2: Navigate to Applications

Look for the sidebar menu:

```
┌──────────────────┐
│ ☰ Menu           │
├──────────────────┤
│ 📊 Dashboard     │
│ 🚀 Applications  │ ← Click here
│ 🗄️  Databases    │
│ 🔧 Services      │
│ ⚙️  Settings     │
└──────────────────┘
```

### Step 3: Find Your Payload CMS Application

In the Applications list, look for:

```
┌─────────────────────────────────────────────────────────┐
│ Applications                                            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ 🟢 jumpstartscalingjumpstartscalingmain-ksgwgg...     │ ← This one!
│    cms.jumpstartscaling.com                            │
│    Running • Last deployed: 2 hours ago                │
│    [View] [Settings] [Logs]                            │
│                                                         │
│ 🟢 n8n-wwgg8ggw00w0s0sow0ogooww                        │
│    n8n.jumpstartscaling.com                            │
│    Running • Last deployed: 2 days ago                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Look for:**
- Domain: `cms.jumpstartscaling.com`
- Or name containing: `ksgwgg0kg08o000s80wcgkks`
- Or Application ID: `7`

### Step 4: Open Application Details

Click on the application to open it. You'll see tabs:

```
┌─────────────────────────────────────────────────────────┐
│ jumpstartscalingjumpstartscalingmain-ksgwgg...         │
├─────────────────────────────────────────────────────────┤
│ [General] [Domains] [Environment] [Deployments] [Logs] │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Status: 🟢 Running                                      │
│ Domain: cms.jumpstartscaling.com                       │
│                                                         │
│ ┌─────────────────────────────────────┐               │
│ │  [🔄 Redeploy]  [⏸️ Stop]  [🗑️ Delete] │ ← Click Redeploy!
│ └─────────────────────────────────────┘               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Step 5: Confirm Redeploy

A confirmation dialog may appear:

```
┌─────────────────────────────────────────┐
│ Confirm Redeploy                        │
├─────────────────────────────────────────┤
│                                         │
│ This will rebuild and restart your     │
│ application. Continue?                  │
│                                         │
│ [Cancel]              [Confirm] ←       │
└─────────────────────────────────────────┘
```

Click **Confirm**!

### Step 6: Watch Deployment Progress

You'll see the deployment logs in real-time:

```
┌─────────────────────────────────────────────────────────┐
│ Deployment Logs                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ [2026-01-15 19:30:00] Starting deployment...           │
│ [2026-01-15 19:30:05] Pulling source code...           │
│ [2026-01-15 19:30:10] Installing dependencies...       │
│ [2026-01-15 19:30:45] Building application...          │
│ [2026-01-15 19:32:15] Creating Docker image...         │
│ [2026-01-15 19:32:30] Starting container...            │
│ [2026-01-15 19:32:35] ✅ Deployment successful!        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Look for:**
- ✅ "Deployment successful"
- ✅ "Container started"
- ✅ "Application is running"

### Step 7: Verify SSL in Domains Tab

Click the **Domains** tab:

```
┌─────────────────────────────────────────────────────────┐
│ Domains                                                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Domain: cms.jumpstartscaling.com                       │
│ Port: 3000                                              │
│ SSL: ✅ Enabled (Cloudflare)                           │
│                                                         │
│ [Generate SSL Certificate] [Remove Domain]             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Check:**
- SSL should show: ✅ Enabled
- If not, click "Generate SSL Certificate"

---

## 🎯 Alternative: Find Application by ID

If you can't find the application by name, use the browser console:

1. **Open Coolify**
2. **Press F12** (open browser DevTools)
3. **Go to Console tab**
4. **Type:**
   ```javascript
   // Search for application ID 7
   document.body.innerText.includes('7')
   ```

Or just **search the page** (Ctrl+F / Cmd+F) for:
- `ksgwgg0kg08o000s80wcgkks`
- `cms.jumpstartscaling.com`
- `Application ID: 7`

---

## 🔍 What to Look For in Different Coolify Versions

Coolify UI varies by version. Here are common button names:

### Redeploy Button Variations:
- **"Redeploy"** ← Most common
- **"Deploy"**
- **"Restart & Rebuild"**
- **"Force Deploy"**
- **"Rebuild"**
- **"Deploy Latest"**
- **🔄 icon** (circular arrow)

### Location Variations:
1. **Top right** of application page
2. **General tab** → Actions section
3. **Deployments tab** → Deploy button
4. **Three-dot menu** (⋮) → Redeploy option

---

## ⚡ Quick Actions

### If You Can't Find the Redeploy Button:

**Option A: Use Deployments Tab**
1. Click **"Deployments"** tab
2. Look for **"New Deployment"** or **"Deploy"** button
3. Click it

**Option B: Use Settings**
1. Click **"Settings"** tab
2. Scroll to **"Deployment"** section
3. Click **"Trigger Deployment"** or **"Redeploy"**

**Option C: Restart Container**
1. Look for **"Restart"** button
2. This won't rebuild, but will restart with updated code

---

## ✅ Success Indicators

After clicking Redeploy, you'll know it worked when:

1. **Deployment logs appear** showing build progress
2. **Status changes** from "Running" to "Deploying" to "Running"
3. **Last deployed time** updates to "Just now"
4. **Visit https://cms.jumpstartscaling.com** → No more database errors!

---

## 🆘 Can't Access Coolify?

If you can't access the Coolify UI:

```bash
# Check if Coolify is running
ssh -i ~/.ssh/id_rsa opc@193.122.168.215 'docker ps | grep coolify'

# Restart Coolify if needed
ssh -i ~/.ssh/id_rsa opc@193.122.168.215 'docker restart coolify'

# Check Coolify logs
ssh -i ~/.ssh/id_rsa opc@193.122.168.215 'docker logs coolify --tail 50'
```

---

## 📱 Mobile/Tablet Access

If accessing from mobile:

1. **Landscape mode** recommended for better UI
2. **Zoom out** if buttons are cut off
3. **Swipe left/right** to see all tabs
4. **Long press** on application to see options menu

---

## 🎉 After Successful Redeploy

1. **Wait 30 seconds** for container to fully start
2. **Visit:** https://cms.jumpstartscaling.com
3. **Should see:** Payload CMS setup wizard! ✅
4. **No more errors!** Database tables created automatically

---

**Ready? Go to Coolify and click that Redeploy button!** 🚀

**URL:** http://spark.jumpstartscaling.com:8000
