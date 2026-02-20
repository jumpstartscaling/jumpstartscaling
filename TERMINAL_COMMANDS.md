# God Mode — Terminal Commands

Run these from the **spark repo root** (`/path/to/spark` or `~/Downloads/spark`). Use `cd god-mode` first so you're in the right folder.

---

## Push & Deploy

```bash
# 1. Push to GitHub
cd god-mode && git add -A && git status
cd god-mode && git commit -m "Your message" && git push origin main

# 2. Trigger Coolify redeploy for both apps (JFactory + god-mode-api)
cd god-mode && node scripts/configure-coolify-via-api.mjs --deploy
```
Requires `COOLIFY_TOKEN` in god-mode/.env.local.

---

## Seed & Campaign

```bash
# Seed chrisamaya.work v4 (50 locs × 35 svcs = 1,750 matrix)
cd god-mode/python-api && python3 scripts/seed_chrisamaya_v4.py

# Launch first campaign (target_quantity=2000)
cd god-mode/python-api && python3 scripts/launch_chrisamaya_campaign.py --quantity=2000

# Or via API (uses ADMIN_KEY from .env.local)
cd god-mode && node scripts/launch-chrisamaya-campaign.mjs --quantity=2000
```
Requires `DATABASE_URL` and `ADMIN_KEY` in god-mode/.env.local.

---

## Verify

```bash
# Check API counts
curl -s https://api.jumpstartscaling.com/api/counts | jq

# Handshake check
cd god-mode && API_URL=https://api.jumpstartscaling.com node scripts/verify-handshake.mjs
```
