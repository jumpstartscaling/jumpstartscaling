# Jumpstart Scaling Deployment Workflow
**AI Agent Reference Guide**

## Current Server Status
- **Server:** Oracle ARM64 at `150.136.117.198` (user: `opc`)
- **Site Path:** `~/sites/jumpstartscaling/`
- **Port:** 8100
- **PM2 Process Name:** `jumpstartscaling-dev` (dev mode) or `jumpstartscaling` (production)
- **Domain:** https://jumpstartscaling.com
- **Cloudflare Tunnel:** Active, proxies port 8100

## Current Mode: DEV MODE (Hot Reload Enabled)

The site is currently running in **development mode** which means:
- Changes to source files appear instantly (1-2 seconds)
- No rebuild required
- Just sync files and Astro hot-reloads automatically

---

## Standard Deployment Workflow

### Making Changes to the Site

**Step 1: Sync Source Files**
```bash
cd /Users/christopheramaya/Downloads/spark/god-mode
rsync -avz --exclude 'node_modules' --exclude 'dist' --exclude '.astro' \
  sites/jumpstartscaling/src/ \
  opc@150.136.117.198:~/sites/jumpstartscaling/src/
```

**Step 2: Purge Cloudflare Cache**
```bash
curl -X POST "https://api.cloudflare.com/client/v4/zones/f1e606b93260b3e12a939612c12c6370/purge_cache" \
  -H "Authorization: Bearer nqsfbN92BBmUR1l1nxbMFUPGbImmB8nyUeNsU0u2" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}'
```

**Step 3: Verify**
- Wait 30 seconds for cache to clear
- Visit https://jumpstartscaling.com
- Hard refresh browser: `Cmd+Shift+R` (Mac) or `Ctrl+Shift+R` (Windows)

**That's it!** Changes should be live.

---

## Alternative: Quick Deploy Script

For production builds (when you want optimized, minified code):

```bash
cd /Users/christopheramaya/Downloads/spark/god-mode
chmod +x quick_deploy.sh
./quick_deploy.sh
```

This script:
1. Builds locally (`npm run build`)
2. Syncs only the `dist/` folder
3. Restarts PM2
4. Purges Cloudflare cache

---

## Mode Switching

### Switch to Dev Mode (Current)
```bash
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
cd ~/sites/jumpstartscaling
pm2 stop jumpstartscaling || pm2 stop jumpstartscaling-dev || true
pm2 delete jumpstartscaling || pm2 delete jumpstartscaling-dev || true
pm2 start npm --name "jumpstartscaling-dev" -- run dev -- --port 8100 --host 0.0.0.0
pm2 save
EOF
```

### Switch to Production Mode
```bash
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
cd ~/sites/jumpstartscaling
npm run build
pm2 stop jumpstartscaling-dev || pm2 stop jumpstartscaling || true
pm2 delete jumpstartscaling-dev || pm2 delete jumpstartscaling || true
pm2 start npm --name "jumpstartscaling" -- run preview -- --port 8100 --host 0.0.0.0
pm2 save
EOF
```

---

## Troubleshooting

### Changes Not Appearing?

1. **Check if dev server is running:**
   ```bash
   ssh -i ~/.ssh/id_rsa opc@150.136.117.198 "pm2 list"
   ```
   Look for `jumpstartscaling-dev` or `jumpstartscaling` with status `online`

2. **Check PM2 logs for errors:**
   ```bash
   ssh -i ~/.ssh/id_rsa opc@150.136.117.198 "pm2 logs jumpstartscaling-dev --lines 50"
   ```

3. **Restart PM2:**
   ```bash
   ssh -i ~/.ssh/id_rsa opc@150.136.117.198 "pm2 restart jumpstartscaling-dev"
   ```

4. **Clear Cloudflare cache again:**
   ```bash
   curl -X POST "https://api.cloudflare.com/client/v4/zones/f1e606b93260b3e12a939612c12c6370/purge_cache" \
     -H "Authorization: Bearer nqsfbN92BBmUR1l1nxbMFUPGbImmB8nyUeNsU0u2" \
     -H "Content-Type: application/json" \
     --data '{"purge_everything":true}'
   ```

5. **Check what's actually being served:**
   ```bash
   ssh -i ~/.ssh/id_rsa opc@150.136.117.198 \
     "curl -s http://localhost:8100 | grep -c 'quick-nav-react'"
   ```
   If this returns a number > 0, menu is being served

### Build Errors?

If the build fails locally:
```bash
cd sites/jumpstartscaling
rm -rf node_modules dist .astro
npm install
npm run dev  # Test locally first at http://localhost:8100
```

---

## Important Files & Paths

### Local
- **Project Root:** `/Users/christopheramaya/Downloads/spark/god-mode`
- **Site Root:** `/Users/christopheramaya/Downloads/spark/god-mode/sites/jumpstartscaling`
- **Menu Components:**
  - `src/components/ui/SystemInterface.jsx` (main menu code)
  - `src/components/ui/GlobalInterface.astro` (wrapper)
  - `src/components/ui/CyberConsole.css` (styling)

### Server
- **Site Root:** `/home/opc/sites/jumpstartscaling/`
- **SSH Key:** `~/.ssh/id_rsa`
- **Server User:** `opc`
- **Server IP:** `150.136.117.198`

### Cloudflare
- **Zone ID:** `f1e606b93260b3e12a939612c12c6370`
- **API Token:** `nqsfbN92BBmUR1l1nxbMFUPGbImmB8nyUeNsU0u2`
- **Dashboard:** https://dash.cloudflare.com

---

## Available Scripts

All scripts are in `/Users/christopheramaya/Downloads/spark/god-mode/`:

- **`quick_deploy.sh`** - Build locally, sync dist, restart PM2, purge cache
- **`enable_dev_mode.sh`** - Switch server to dev mode
- **`sync_sites.sh`** - Basic source file sync
- **`fresh_deploy.sh`** - Full clean deployment to new folder

---

## Best Practices for AI Agents

1. **Always check current mode first** - Run `ssh opc@150.136.117.198 "pm2 list"` to see what's running
2. **In dev mode:** Just sync source files, changes are instant
3. **In production mode:** Use `quick_deploy.sh` to build and deploy
4. **Always purge Cloudflare cache** after changes
5. **Verify changes** by checking `http://localhost:8100` on server before assuming success
6. **If nothing works:** SSH in manually and check PM2 logs for actual errors

---

## Quick Reference Commands

**Sync files (dev mode):**
```bash
rsync -avz --exclude 'node_modules' --exclude 'dist' sites/jumpstartscaling/src/ opc@150.136.117.198:~/sites/jumpstartscaling/src/
```

**Purge cache:**
```bash
curl -X POST "https://api.cloudflare.com/client/v4/zones/f1e606b93260b3e12a939612c12c6370/purge_cache" -H "Authorization: Bearer nqsfbN92BBmUR1l1nxbMFUPGbImmB8nyUeNsU0u2" -H "Content-Type: application/json" --data '{"purge_everything":true}'
```

**Check PM2:**
```bash
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 "pm2 list"
```

**Restart server:**
```bash
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 "pm2 restart jumpstartscaling-dev"
```

---

**Last Updated:** 2026-01-11  
**Current Mode:** Dev Mode (Hot Reload)  
**Status:** Menu system deployed and working
