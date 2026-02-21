#!/bin/bash
# God Mode — Full Spark Factory. Double-click or: ./god-mode.command
cd "$(dirname "$0")" || exit 1

BASE="$(pwd)"
API_BASE="https://api.jumpstartscaling.com"
ROUTER_BASE="https://factory.jumpstartscaling.com"

get_admin_key() {
  [[ -f "$BASE/.env.local" ]] && grep -E '^ADMIN_KEY=' "$BASE/.env.local" 2>/dev/null | cut -d'=' -f2- | tr -d '"' | tr -d "'" | head -1
}

# Quick DB check — Seed/Launch need SSH tunnel (localhost:5433) if using .env.local
check_db() {
  if nc -z 127.0.0.1 5433 2>/dev/null; then
    return 0
  fi
  if nc -z 127.0.0.1 5432 2>/dev/null; then
    return 0
  fi
  return 1
}

show_menu() {
  echo ""
  echo "═══════════════════════════════════════════════════════════"
  echo "  God Mode — Full Spark Factory"
  echo "═══════════════════════════════════════════════════════════"
  echo ""
  echo "  SETUP"
  echo "  ───────────────────────────────────────────────────────"
  echo "   1) Setup          Schema + configure Coolify (no deploy)"
  echo "   2) Schema         Run schema via API"
  echo "   3) Configure      Coolify env, base dir, domains"
  echo ""
  echo "  COOLIFY"
  echo "  ───────────────────────────────────────────────────────"
  echo "   4) Deploy         Configure + redeploy both apps"
  echo "   5) Monitor        Deploy status (one-shot)"
  echo "   6) Watch          Deploy (poll until done)"
  echo "   7) Debug          Coolify apps + quick endpoints"
  echo ""
  echo "  SEED TREE (needs DB: SSH tunnel localhost:5433)"
  echo "  ───────────────────────────────────────────────────────"
  echo "   8) Seed L1        Base chrisamaya"
  echo "   9) Seed L2        v4 full factory (1750 matrix)"
  echo "  10) Seed Full      Layer 1 + Layer 2"
  echo ""
  echo "  SEED VIA API (no DB/SSH required)"
  echo "  ───────────────────────────────────────────────────────"
  echo "  19) Seed via API   chrisamaya v4 via API"
  echo "  20) Seed+Launch    Seed via API + launch campaign"
  echo ""
  echo "  ACTIVATE"
  echo "  ───────────────────────────────────────────────────────"
  echo "  11) Activate       Seed full + Launch + handshake"
  echo "  12) Launch (DB)    Create job via DB (needs tunnel)"
  echo "  13) Launch (API)   Create job via API (no DB)"
  echo ""
  echo "  MONITOR"
  echo "  ───────────────────────────────────────────────────────"
  echo "  14) Stats          API counts"
  echo "  15) Jobs           Generation jobs"
  echo "  16) Handshake      API health, resolve, posts"
  echo "  17) Endpoints      ALL admin pages + API endpoints (60+)"
  echo ""
  echo "  GIT"
  echo "  ───────────────────────────────────────────────────────"
  echo "  18) Git status"
  echo ""
  echo "   0) Exit"
  echo ""
  echo "  Choose [0-20]"
  echo ""
}

do_jobs() {
  echo ">>> Generation jobs"
  key="$(get_admin_key)"
  if [[ -z "$key" ]]; then
    echo "  Set ADMIN_KEY in .env.local"
    return
  fi
  curl -s -H "X-Admin-Key: $key" "$API_BASE/api/generation-jobs" 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    jobs = data if isinstance(data, list) else []
    for j in jobs[:10]:
        print(f\"  {j.get('id','')[:8]}... status={j.get('status','?')} target={j.get('target_quantity','?')} progress={j.get('progress','?')}\")
    if not jobs:
        print('  (no jobs)')
except Exception as e:
    print('  Error:', e)
" 2>/dev/null || echo "  Failed"
}

run_choice() {
  case "$1" in
    1)  node scripts/run-schema-via-api.mjs 2>/dev/null || true
        node scripts/configure-coolify-via-api.mjs
        ;;
    2)  node scripts/run-schema-via-api.mjs ;;
    3)  node scripts/configure-coolify-via-api.mjs ;;
    4)  node scripts/configure-coolify-via-api.mjs --deploy ;;
    5)  node scripts/monitor-coolify-deploy.mjs ;;
    6)  node scripts/monitor-coolify-deploy.mjs --watch ;;
    7)  node scripts/debug-coolify-api.mjs
        echo ""
        for url in "$API_BASE/health" "$API_BASE/api/counts" "$ROUTER_BASE/health" "$ROUTER_BASE/jumpstart/admin/" "$API_BASE/api/sites/resolve?domain=chrisamaya.work"; do
          code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "ERR")
          echo "  $code  $url"
        done
        ;;
    8)  if ! check_db; then echo ">>> ⚠️  Start SSH tunnel: ssh -L 5433:localhost:5432 user@host"; fi
        cd "$BASE" && python3 python-api/scripts/seed_chrisamaya.py
        ;;
    9)  if ! check_db; then echo ">>> ⚠️  Start SSH tunnel: ssh -L 5433:localhost:5432 user@host"; fi
        cd "$BASE" && python3 python-api/scripts/seed_chrisamaya_v4.py
        ;;
    10) if ! check_db; then echo ">>> ⚠️  Start SSH tunnel: ssh -L 5433:localhost:5432 user@host"; fi
        cd "$BASE" && python3 python-api/scripts/seed_chrisamaya.py && python3 python-api/scripts/seed_chrisamaya_v4.py
        ;;
    11) if ! check_db; then echo ">>> ⚠️  Start SSH tunnel first"; fi
        echo ">>> Activate full factory"
        cd "$BASE" && python3 python-api/scripts/seed_chrisamaya.py && python3 python-api/scripts/seed_chrisamaya_v4.py
        echo ""
        cd "$BASE" && python3 python-api/scripts/launch_chrisamaya_campaign.py --quantity=2000
        echo ""
        API_URL="$API_BASE" node scripts/verify-handshake.mjs
        ;;
    12) if ! check_db; then echo ">>> ⚠️  Start SSH tunnel first"; fi
        cd "$BASE" && python3 python-api/scripts/launch_chrisamaya_campaign.py --quantity=2000
        ;;
    13) node scripts/launch-chrisamaya-campaign.mjs --quantity=2000
        ;;
    19) API_URL="$API_BASE" node scripts/seed-chrisamaya-via-api.mjs
        ;;
    20) API_URL="$API_BASE" node scripts/seed-chrisamaya-via-api.mjs --launch
        ;;
    14) curl -s "$API_BASE/api/counts" | python3 -m json.tool 2>/dev/null || curl -s "$API_BASE/api/counts"
        ;;
    15) do_jobs
        ;;
    16) API_URL="$API_BASE" node scripts/verify-handshake.mjs
        ;;
    17) API_URL="$API_BASE" ROUTER_URL="$ROUTER_BASE" node scripts/endpoints-full.mjs
        ;;
    18) git add -A && git status
        ;;
    0)  exit 0
        ;;
    *)  echo "Invalid choice"
        ;;
  esac
}

while true; do
  show_menu
  read -p "Choose [0-20]: " choice
  run_choice "$choice"
  echo ""
  read -p "Press Enter to continue..."
done
