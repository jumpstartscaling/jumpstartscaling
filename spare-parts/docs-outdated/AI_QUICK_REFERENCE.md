# 🎯 Quick Reference - AI Agent Instructions

## When You Want to Make Changes

### ✅ Safe Commands (Use Anytime)
```
"Add a new section to the homepage in development"
"Create a new calculator component in dev"
"Update the styling for the services page in staging"
"Install a new npm package in development"
"Test the new feature on port 8102"
```

### 🚀 Deploy Commands (Use When Ready)
```
"Deploy to production"
"Push to live"
"Go live with the homepage changes"
"Launch the new app"
"Make it live"
```

### 🔴 Never Say (Unless Emergency)
```
"Restart jumpstart-v2" (without "in dev")
"Delete the dist folder" (in production)
"Modify /home/opc/sites/jumpstartscaling" (without "dev")
```

---

## Current Environment

### 🔒 Production (LIVE - Don't Touch)
- **jumpstartscaling.com** - Port 8100 (PM2: `jumpstart-v2`)
- **n8n.jumpstartscaling.com** - Port 5678 (PM2: `ion-n8n`)

### ✅ Development (Safe to Edit)
- **Dev Server** - Port 8102 (PM2: `jumpstart-dev`)
- **Preview URL**: http://150.136.117.198:8102
- **Directory**: `/home/opc/sites/jumpstartscaling-dev`

---

## Common Requests & AI Responses

### Request: "Update the homepage"
**AI Should**:
1. Edit `/home/opc/sites/jumpstartscaling-dev/src/pages/index.astro`
2. Run `npm run build` in dev directory
3. Report: "✅ Changes in dev. Preview at port 8102. Say 'deploy' when ready."

**AI Should NOT**:
- Touch `/home/opc/sites/jumpstartscaling/` (production)
- Restart `jumpstart-v2` process
- Modify production dist folder

---

### Request: "Add a new page"
**AI Should**:
1. Create in `/home/opc/sites/jumpstartscaling-dev/src/pages/`
2. Build and test
3. Report preview URL

---

### Request: "Deploy to production"
**AI Should**:
1. Create backup of production
2. Copy dev changes to production
3. Build production
4. Restart `jumpstart-v2`
5. Verify site is up
6. Report success with backup location

---

### Request: "Create a new app"
**AI Should**:
1. Create in `/home/opc/sites/[appname]-dev`
2. Use port 8200+ for staging
3. Test thoroughly
4. Report staging URL
5. Wait for "launch" command before going live

---

## Port Map

| Port | Service | Status | URL |
|------|---------|--------|-----|
| 8100 | Jumpstart Production | 🔒 LIVE | jumpstartscaling.com |
| 8101 | Chris Amaya Production | 🔒 LIVE | chrisamaya.work |
| 8102 | Jumpstart Development | ✅ SAFE | http://150.136.117.198:8102 |
| 5678 | n8n Production | 🔒 LIVE | n8n.jumpstartscaling.com |
| 8000 | API Production | 🔒 LIVE | api.jumpstartscaling.com |
| 8200+ | New Apps (Staging) | ✅ SAFE | Available for new projects |

---

## Emergency Commands

### Rollback Production
```bash
ssh opc@150.136.117.198 "cd /home/opc/sites/jumpstartscaling && tar -xzf ../jumpstartscaling-backup-[timestamp].tar.gz && pm2 restart jumpstart-v2"
```

### Check Production Status
```bash
ssh opc@150.136.117.198 "pm2 list | grep -E 'jumpstart-v2|ion-n8n' && curl -I http://localhost:8100/"
```

### View Logs
```bash
ssh opc@150.136.117.198 "pm2 logs jumpstart-v2 --lines 50"
```

---

## Files to Reference

1. **AI_AGENT_HANDOFF.md** - Complete AI agent guide (read this first!)
2. **DEPLOYMENT.md** - Detailed deployment procedures
3. **README.md** - Project overview
4. **deploy.sh** - Automated deployment script

---

## Key Principles

1. **Development First**: Always work in `-dev` directories
2. **Test Before Deploy**: Use port 8102 for previews
3. **Explicit Deploy**: Only push to production when told
4. **Backup Everything**: Create backups before production changes
5. **Verify Always**: Check site is up after deployment

---

**Remember**: The AI should treat production like a museum - look but don't touch unless you have explicit permission! 🏛️

**Full Documentation**: See `AI_AGENT_HANDOFF.md` for complete workflows and rules.
