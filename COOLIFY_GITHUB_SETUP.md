# Coolify — Add GitHub Repos as Sources

**Purpose:** Connect the 3 new GitHub repositories to Coolify for automatic deployments.

---

## Quick Start (Automated)

**If you have GitHub CLI (`gh`) authenticated:**

```bash
cd /Users/christopheramaya/Downloads/spark/god-mode
./deploy-repos-to-github.sh
```

**If not authenticated:** Run `gh auth login` first (opens browser), then run the script above.

**Or with a token:** `echo YOUR_GITHUB_TOKEN | gh auth login --with-token` then run the script.

**Target org:** Repos go to `caw-jump`. Override with `GITHUB_ORG=other-org ./deploy-repos-to-github.sh` if needed.

---

## 1. Create and Push the Repositories (Manual)

The 3 repo directories have been prepared at:
- `../jumpstartscaling-site/`
- `../chrisamaya-site/`
- `../god-mode-api/`

### For jumpstartscaling-site and chrisamaya-site (ready to go):

```bash
cd /Users/christopheramaya/Downloads/spark/jumpstartscaling-site
git init
git add .
git commit -m "Initial commit - Jumpstart Scaling site"
# Create private repo on GitHub, then:
git remote add origin git@github.com:YOUR_ORG/jumpstartscaling-site.git
git branch -M main
git push -u origin main
```

```bash
cd /Users/christopheramaya/Downloads/spark/chrisamaya-site
git init
git add .
git commit -m "Initial commit - Chris Amaya portfolio"
# Create private repo on GitHub, then:
git remote add origin git@github.com:YOUR_ORG/chrisamaya-site.git
git branch -M main
git push -u origin main
```

### For god-mode-api (FastAPI):

The `python-api/` folder in god-mode has the FastAPI source. **Run these steps**:

```bash
cd /Users/christopheramaya/Downloads/spark/god-mode/python-api

git init
git add .
git commit -m "Initial commit - God Mode FastAPI"
# Create private repo on GitHub, then:
git remote add origin git@github.com:YOUR_ORG/god-mode-api.git
git branch -M main
git push -u origin main
```

---

## 2a. Automated Deploy (API Script)

Once the GitHub App is set up (step 2 below) and you have an API token:

```bash
# Get token: Coolify → Keys & Tokens → API tokens → Create
COOLIFY_TOKEN=your_token_here ./deploy-to-coolify.sh
```

This creates and deploys both jumpstartscaling-site and chrisamaya-site automatically.

---

## 2. Add GitHub as a Source (One-Time)

Since your repos are **private**, Coolify needs a GitHub App to access them:

1. **Coolify** → http://86.48.23.38:8000 → **Sources** (sidebar)
2. Click **+ Add** → **GitHub App**
3. Enter org: **`caw-jump`** (or leave empty if using a personal account)
4. Name it (e.g. **Coolify Deploy**)
5. Click **Register now** → completes setup on GitHub
6. Click **Install repositories on Github** → choose **All repositories** or select the 3 repos
7. Finish

---

## 3. Create Each App (Repeat for All 3)

### Per app: jumpstartscaling-site, chrisamaya-site, god-mode-api

1. Click **+ New** (top right)
2. Pick your **Project** (or create one)
3. Choose **Private Repository (with Github App)**
4. Choose **Server** → `localhost` or your Coolify server (86.48.23.38)
5. Select your **GitHub App** (the one you added)
6. Choose **Repository** → click **Load Repository**
   - `caw-jump/jumpstartscaling-site`
   - `caw-jump/chrisamaya-site`
   - `caw-jump/god-mode-api`
7. Configure:

| App | Build Pack | Build Command | Start Command | Port |
|-----|------------|---------------|---------------|------|
| jumpstartscaling-site | Nixpacks | `npm install && npm run build` | `node server.js` | 8100 |
| chrisamaya-site | Nixpacks | `npm install && npm run build` | `node server.js` | 8101 |
| god-mode-api | Dockerfile | — | — | 8200 |

8. **Domains** (in app settings):
   - jumpstartscaling.com, www.jumpstartscaling.com
   - chrisamaya.work, www.chrisamaya.work
   - api.jumpstartscaling.com

9. Click **Deploy**

**god-mode-api env vars:** Add in Coolify app settings → Environment Variables. Copy from `.env.example` and use real values.

---

## 4. After Deployment

1. **Update Cloudflare DNS**  
   Point the 3 domains to Coolify server IP: `86.48.23.38`  
   - jumpstartscaling.com (A record)  
   - chrisamaya.work (A record)  
   - api.jumpstartscaling.com (A record)

2. **Remove Oracle Tunnel entries** (optional)  
   Edit `/etc/cloudflared/config.yml` on Oracle and remove the 3 migrated hostnames.

3. **Verify SSL**  
   Coolify/Traefik should auto-provision Let's Encrypt certs once DNS propagates.

---

## Quick Reference

| Repo | Path | Domain |
|------|------|--------|
| jumpstartscaling-site | `../jumpstartscaling-site/` | jumpstartscaling.com |
| chrisamaya-site | `../chrisamaya-site/` | chrisamaya.work |
| god-mode-api | `../god-mode-api/` | api.jumpstartscaling.com |

**Coolify Server:** 86.48.23.38  
**Coolify UI:** http://86.48.23.38:8000
