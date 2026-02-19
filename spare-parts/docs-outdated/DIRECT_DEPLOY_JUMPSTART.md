# Direct Deployment Instructions for Jumpstart Scaling

## Problem
The menu system files are not appearing on the live site despite multiple deployment attempts.

## Root Cause Analysis
The deployment scripts aren't showing output, suggesting one of these issues:
1. PM2 is serving from a cached/wrong location
2. The build is silently failing
3. The Cloudflare tunnel is pointing to the wrong service

## Manual Deployment Steps

### Step 1: SSH into server
```bash
ssh -i ~/.ssh/id_rsa opc@150.136.117.198
```

### Step 2: Check current PM2 status
```bash
pm2 list
pm2 describe jumpstartscaling
```

### Step 3: Navigate to site directory
```bash
cd ~/sites/jumpstartscaling
pwd  # Confirm you're in the right place
```

### Step 4: Verify files exist
```bash
ls -lh src/components/ui/SystemInterface.jsx
ls -lh src/components/ui/GlobalInterface.astro
ls -lh src/components/ui/CyberConsole.css
grep "GlobalInterface" src/pages/index.astro
```

### Step 5: Check dependencies
```bash
npm list framer-motion lucide-react
```

### Step 6: Clean build
```bash
rm -rf dist .astro node_modules/.vite
npm run build
```

### Step 7: Check build output
```bash
ls -lh dist/
find dist -name "*.js" | head -10
```

### Step 8: Stop PM2 and restart
```bash
pm2 stop jumpstartscaling
pm2 delete jumpstartscaling
pm2 start npm --name "jumpstartscaling" -- run preview -- --port 8100 --host 0.0.0.0
pm2 save
```

### Step 9: Test locally on server
```bash
curl http://localhost:8100 | grep -i "quick-nav-react"
```

### Step 10: Check Cloudflare tunnel
```bash
sudo systemctl status cloudflared
sudo cat /etc/cloudflared/config.yml | grep -A 5 jumpstart
```

## Alternative: Use Dev Mode

If build is failing, try dev mode:

```bash
pm2 stop jumpstartscaling
pm2 delete jumpstartscaling  
pm2 start npm --name "jumpstartscaling" -- run dev -- --port 8100 --host 0.0.0.0
pm2 save
```

## Files to Sync from Local

If files are missing on server, run from LOCAL machine:

```bash
cd /Users/christopheramaya/Downloads/spark/god-mode

# Full sync of src directory
rsync -avz --delete \
  --exclude 'node_modules' \
  --exclude 'dist' \
  --exclude '.astro' \
  sites/jumpstartscaling/src/ \
  opc@150.136.117.198:~/sites/jumpstartscaling/src/

# Sync package.json in case dependencies changed
scp -i ~/.ssh/id_rsa \
  sites/jumpstartscaling/package.json \
  opc@150.136.117.198:~/sites/jumpstartscaling/package.json
```

Then SSH back in and:
```bash
cd ~/sites/jumpstartscaling
npm install  # Install any missing dependencies
npm run build
pm2 restart jumpstartscaling
```

## Expected Behavior

After deployment, visiting https://jumpstartscaling.com should show:
- Bottom navigation bar with Menu/Audit/Charts/Tools buttons
- Clicking "Menu" opens full-screen cyberpunk console
- Console has 3 tabs: PROTOCOLS, INTEL, SYSTEM

## Troubleshooting

**If menu still doesn't appear:**

1. Check if React is hydrating:
   - Open browser console
   - Look for React warnings/errors
   
2. Check if files are in build:
   ```bash
   find dist -type f -exec grep -l "SystemInterface" {} \;
   ```

3. Check PM2 logs:
   ```bash
   pm2 logs jumpstartscaling --lines 50
   ```

4. Try accessing directly by port:
   - http://150.136.117.198:8100

5. Check if Astro is in production mode:
   ```bash
   pm2 env jumpstartscaling | grep NODE_ENV
   ```
