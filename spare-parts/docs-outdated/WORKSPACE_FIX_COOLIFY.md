# Fix Workspace: Connect to Coolify, Not Oracle

## The Problem

Your workspace/deployment is pointing at **Oracle** (150.136.117.198) instead of **Coolify** (86.48.23.38).

---

## Two Different Repos

| Repo | Purpose | Coolify-Ready? |
|------|---------|----------------|
| **caw-jump/jumpstartscaling-site** | Standalone site for Coolify | ✅ Yes |
| **jumpstartscaling/jumpstartscaling** | Old monorepo (god-mode) | ❌ No — Oracle setup |

**Use `caw-jump/jumpstartscaling-site` for Coolify.** It has the API proxy, fixed forms, no Oracle dependencies.

---

## Fix in Coolify

1. **Open Coolify:** http://86.48.23.38:8000

2. **Edit your Application** (jumpstartscaling-site):
   - Open the app
   - Go to **Configuration** or **General**

3. **Source (GitHub):**
   - Repository: `caw-jump/jumpstartscaling-site`
   - Branch: `main`
   - If you see `jumpstartscaling/jumpstartscaling` or any Oracle path, change it to `caw-jump/jumpstartscaling-site`

4. **Server (Deployment Target):**
   - Must be the **Coolify server** (localhost / 86.48.23.38)
   - Must **NOT** be Oracle (150.136.117.198) or any SSH to opc@...
   - Coolify deploys to its own Docker host

5. **Redeploy** after changing source/server

---

## Fix in GitHub Enterprise Workspace

If the workspace is in GitHub (not Coolify):

- The workspace may have a **Deploy** or **Actions** workflow pointing at Oracle
- Check **Settings → Secrets/Actions** for `SERVER_HOST`, `DEPLOY_SERVER`, or SSH keys
- Update any Oracle IPs (150.136.117.198) to Coolify (86.48.23.38)
- Or remove the Oracle deploy and use Coolify's native GitHub integration instead

---

## Verify Correct Code on GitHub

```bash
# Clone and check
git clone https://github.com/caw-jump/jumpstartscaling-site.git --depth 1
cd jumpstartscaling-site
# Should see: server.js with /api/submit-lead handler
grep -l "proxyToWebhook" server.js && echo "✅ Coolify code present"
```

---

## Quick Reference

| What | Oracle (OLD) | Coolify (NEW) |
|------|--------------|---------------|
| Server IP | 150.136.117.198 | 86.48.23.38 |
| GitHub Repo | jumpstartscaling/jumpstartscaling | caw-jump/jumpstartscaling-site |
| Deploy Method | PM2, deploy.sh | Coolify builds & runs Docker |
