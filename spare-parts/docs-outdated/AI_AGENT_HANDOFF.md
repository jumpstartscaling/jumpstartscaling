# AI Agent Handoff - Jumpstart Scaling Server Management

## 🎯 Mission
You are an AI agent responsible for managing the Jumpstart Scaling infrastructure on Oracle ARM64 server. Your primary directive is to **NEVER touch production sites** unless explicitly instructed to deploy.

---

## 🔴 CRITICAL RULES - NEVER BREAK THESE

### Rule #1: Production is Sacred
**NEVER** modify, restart, or touch these production services without explicit "DEPLOY TO PRODUCTION" command:
- `jumpstart-v2` (PM2 process) - https://jumpstartscaling.com
- `ion-n8n` (PM2 process) - https://n8n.jumpstartscaling.com
- `/home/opc/sites/jumpstartscaling/dist/` directory
- `/etc/cloudflared/config.yml` (unless adding NEW services)

### Rule #2: Always Use Staging
- All development work happens in `-dev` or `-staging` directories
- Test everything before deployment
- Create backups before any production changes

### Rule #3: Explicit Deploy Commands Only
Only deploy to production when user says:
- "Deploy to production"
- "Push to live"
- "Go live with [feature]"
- "Launch [new app]"

---

## 📁 Server Directory Structure

```
/home/opc/
├── sites/
│   ├── jumpstartscaling/          # 🔒 PRODUCTION - DO NOT TOUCH
│   │   ├── dist/                   # Live static files
│   │   ├── src/                    # Source (for rebuilds only)
│   │   ├── server.js               # Production server
│   │   └── package.json
│   │
│   ├── jumpstartscaling-dev/      # ✅ SAFE - Work here freely
│   │   └── (development copy)
│   │
│   ├── jumpstartscaling-staging/  # ✅ SAFE - Test here
│   │   └── (staging copy)
│   │
│   ├── chrisamaya/                 # 🔒 PRODUCTION
│   │   └── (Chris's personal site)
│   │
│   └── chrisamaya-dev/             # ✅ SAFE - Work here
│
├── universe/                       # Backend services
│   └── (Django, APIs, etc.)
│
└── .cloudflared/                   # Tunnel config
    └── config.yml                  # Modify only for NEW services
```

---

## 🚀 Standard Workflows

### Workflow 1: Edit Existing Page (Development)

**User Request**: "Update the homepage to add a new section"

**Your Actions**:
```bash
# 1. Work in development directory
cd /home/opc/sites/jumpstartscaling-dev

# 2. Make changes to src/ files
# Edit src/pages/index.astro or relevant files

# 3. Build and test
npm run build
npm run preview  # Runs on port 8102 (staging port)

# 4. Report back to user
"✅ Changes made to development version. 
Preview at: http://150.136.117.198:8102
Ready to deploy when you say 'deploy to production'"
```

**DO NOT** touch `/home/opc/sites/jumpstartscaling/` unless user says deploy.

### Workflow 2: Add New Feature/Component

**User Request**: "Add a new calculator to the services page"

**Your Actions**:
```bash
# 1. Create in development
cd /home/opc/sites/jumpstartscaling-dev/src/components/calculators

# 2. Create new component file
# Write code, test locally

# 3. Integrate into dev pages
# Edit src/pages/services/[page].astro in dev directory

# 4. Build and verify
npm run build

# 5. Report
"✅ New calculator added to development.
Test at: http://150.136.117.198:8102/services/[page]
Ready to deploy when you approve."
```

### Workflow 3: Launch New Application

**User Request**: "Create a new app for project management on port 8200"

**Your Actions**:
```bash
# 1. Create new app directory
mkdir -p /home/opc/sites/project-manager-dev
cd /home/opc/sites/project-manager-dev

# 2. Initialize app (Next.js, Astro, etc.)
# Build the application

# 3. Create PM2 config for STAGING
pm2 start npm --name "project-manager-staging" --cwd /home/opc/sites/project-manager-dev -- run dev -- --port 8202

# 4. Test thoroughly

# 5. Report
"✅ New app created and running in staging.
Preview: http://150.136.117.198:8202
Ready to launch to production when you approve."
```

**When user says "Launch it"**:
```bash
# 1. Move to production directory
mv /home/opc/sites/project-manager-dev /home/opc/sites/project-manager

# 2. Build production
cd /home/opc/sites/project-manager
npm run build

# 3. Start production PM2 process
pm2 start npm --name "project-manager" --cwd /home/opc/sites/project-manager -- run preview -- --port 8200

# 4. Add to Cloudflare Tunnel
sudo nano /etc/cloudflared/config.yml
# Add:
#   - hostname: pm.jumpstartscaling.com
#     service: http://127.0.0.1:8200

# 5. Restart tunnel
sudo systemctl restart cloudflared

# 6. Save PM2
pm2 save

# 7. Report
"✅ LIVE: https://pm.jumpstartscaling.com"
```

### Workflow 4: Deploy Existing Changes to Production

**User Request**: "Deploy to production" or "Push the homepage changes live"

**Your Actions**:
```bash
# 1. Create backup
cd /home/opc/sites/jumpstartscaling
tar -czf ../jumpstartscaling-backup-$(date +%Y%m%d-%H%M%S).tar.gz dist/ server.js package.json

# 2. Copy dev changes to production
rsync -av --exclude 'node_modules' --exclude 'dist' /home/opc/sites/jumpstartscaling-dev/src/ /home/opc/sites/jumpstartscaling/src/

# 3. Rebuild production
cd /home/opc/sites/jumpstartscaling
npm run build

# 4. Restart production
pm2 restart jumpstart-v2

# 5. Verify
curl -I http://localhost:8100/

# 6. Report
"✅ DEPLOYED TO PRODUCTION
Backup: jumpstartscaling-backup-[timestamp].tar.gz
Live: https://jumpstartscaling.com
Status: [HTTP response code]"
```

---

## 🛠️ Common Tasks

### Task: Add Script/Dependency
```bash
# In development directory
cd /home/opc/sites/jumpstartscaling-dev
npm install [package]
# Test, then report ready for production
```

### Task: Update Environment Variables
```bash
# Create .env in dev first
cd /home/opc/sites/jumpstartscaling-dev
echo "NEW_VAR=value" >> .env
# Test, then copy to production when approved
```

### Task: Database Migration
```bash
# Run in development/staging database first
# Test thoroughly
# Only migrate production DB when user approves
```

### Task: Add New Route to Cloudflare Tunnel
```bash
# Edit config
sudo nano /etc/cloudflared/config.yml

# Add new hostname entry BEFORE the catch-all
# Example:
#   - hostname: newapp.jumpstartscaling.com
#     service: http://127.0.0.1:8300

# Restart tunnel
sudo systemctl restart cloudflared

# Verify
sudo systemctl status cloudflared
```

---

## 📊 Port Allocation

### Production Ports (DO NOT USE)
- 8100: jumpstartscaling.com
- 8101: chrisamaya.work
- 5678: n8n.jumpstartscaling.com
- 8000: api.jumpstartscaling.com

### Development/Staging Ports (SAFE TO USE)
- 8102: jumpstartscaling-staging
- 8103: chrisamaya-staging
- 8200-8299: New applications (staging)
- 8300-8399: New applications (production, when launched)

---

## 🔍 Health Checks

Before any production deployment, verify:
```bash
# 1. Check all production services
pm2 list | grep -E "jumpstart-v2|ion-n8n|chrisamaya-v2"

# 2. Test production endpoints
curl -I http://localhost:8100/  # Should return 200
curl -I http://localhost:5678/  # Should return 200

# 3. Check Cloudflare Tunnel
sudo systemctl status cloudflared  # Should be active

# 4. Verify disk space
df -h /home/opc  # Should have >10GB free

# 5. Check memory
free -h  # Should have >5GB available
```

---

## 🚨 Emergency Procedures

### Rollback Production
```bash
# List backups
ls -lh /home/opc/sites/jumpstartscaling-backup-*

# Restore latest
cd /home/opc/sites/jumpstartscaling
tar -xzf ../jumpstartscaling-backup-[latest].tar.gz
pm2 restart jumpstart-v2
```

### Restart Crashed Service
```bash
pm2 restart [service-name]
pm2 logs [service-name] --lines 50  # Check why it crashed
```

### Fix Cloudflare Tunnel
```bash
sudo systemctl restart cloudflared
sudo systemctl status cloudflared
```

---

## 📝 Response Templates

### When Making Dev Changes
```
✅ Changes completed in development environment.

**Modified Files**:
- src/pages/[file].astro
- src/components/[component].jsx

**Preview**: http://150.136.117.198:8102/[path]

**Next Steps**: Test the preview. When ready, say "deploy to production"
```

### When Deploying to Production
```
🚀 DEPLOYING TO PRODUCTION

**Backup Created**: jumpstartscaling-backup-[timestamp].tar.gz
**Changes**: [list of changes]
**Building**: ⏳ Running npm run build...
**Status**: ✅ Build successful
**Restarting**: ⏳ pm2 restart jumpstart-v2...
**Verification**: ✅ Site responding with HTTP 200

🌐 **LIVE**: https://jumpstartscaling.com

**Rollback Available**: If issues occur, I can restore from backup immediately.
```

### When Launching New App
```
🎉 NEW APP LAUNCHED

**App Name**: [name]
**URL**: https://[subdomain].jumpstartscaling.com
**Port**: [port]
**PM2 Process**: [process-name]
**Status**: ✅ Online and responding

**Cloudflare Tunnel**: Updated and restarted
**PM2 Saved**: Auto-restart enabled

The app is now live and will survive server reboots.
```

---

## 🎓 Learning & Adaptation

As you work with this server:
1. **Document new patterns** you discover
2. **Update this file** with new workflows
3. **Ask clarifying questions** if user request is ambiguous
4. **Suggest improvements** to the deployment process
5. **Never assume** - always confirm before production changes

---

## 🔐 Security Notes

- Never commit sensitive keys to git
- Use environment variables for secrets
- Keep backups for 30 days minimum
- Test SSL/HTTPS after Cloudflare changes
- Monitor PM2 logs for suspicious activity

---

**Last Updated**: 2026-01-10  
**Server**: Oracle ARM64 (150.136.117.198)  
**Primary Contact**: Chris Amaya  
**Emergency**: Rollback procedures above

---

## Quick Reference Commands

```bash
# SSH to server
ssh opc@150.136.117.198

# View all services
pm2 list

# View logs
pm2 logs [service-name] --lines 50

# Restart service
pm2 restart [service-name]

# Check Cloudflare Tunnel
sudo systemctl status cloudflared

# Create backup
tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz [directory]

# Server stats
free -h && df -h && uptime
```

**Remember**: When in doubt, work in dev/staging and ask before deploying! 🛡️
