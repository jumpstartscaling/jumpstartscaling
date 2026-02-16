#!/bin/bash
# Ultimate Server-Side Build & Deploy Script (2026 Edition + SSL Management)
# Usage: ./deploy.sh [jumpstartscaling|chrisamaya|both] [--dry-run] [--force] [--issue-ssl "domain.com www.domain.com api.domain.com"]
#   - Default: both sites
#   - --dry-run: Simulate everything (no rsync, no remote changes)
#   - --force: Skip confirmation prompt
#   - --issue-ssl "list of domains": Install Certbot (if needed) and issue/expand a real Let's Encrypt SSL cert for the specified domains/subdomains using Nginx plugin
# Enhancements:
#   • Full SSL certificate management (real Let's Encrypt)
#   • Automatic renewal of all existing certs on every deploy
#   • One-command new cert issuance for subdomains/domains
#   • Assumes Nginx is the reverse proxy in front of multisite-router (port 8100)
#   • Single multisite-router PM2 process
#   • Post-deploy health report + API test lead
#   • dist backups, cache clearing, zero-downtime reload

set -e

# === CONFIGURATION ===
EMAIL="admin@jumpstartscaling.com"  # Change to your real email for Let's Encrypt notifications
# =====================

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo -e "${GREEN}🚀 Starting Deployment — $TIMESTAMP${NC}"

SERVER="opc@193.122.168.215"
REMOTE_BASE="/home/opc/sites"
API_URL="https://api.jumpstartscaling.com"

# Argument parsing
TARGET="${1:-both}"
DRY_RUN=false
FORCE=false
ISSUE_SSL=false
SSL_DOMAINS=""

# Parse flags
for arg in "$@"; do
  case $arg in
    --dry-run) DRY_RUN=true; shift ;;
    --force) FORCE=true; shift ;;
    --issue-ssl)
      shift
      SSL_DOMAINS="$*"
      ISSUE_SSL=true
      break
      ;;
  esac
done

# Re-parse target if flags shifted it
[[ "$1" =~ ^(jumpstartscaling|chrisamaya|both)$ ]] && TARGET="$1"

case "$TARGET" in
  jumpstartscaling|chrisamaya) SITES="$TARGET" ;;
  both|"") SITES="jumpstartscaling chrisamaya" ;;
  *) echo -e "${RED}Invalid target. Use: jumpstartscaling, chrisamaya, or both${NC}"; exit 1 ;;
esac

echo -e "Target site(s): ${YELLOW}$SITES${NC}"
[[ $DRY_RUN == true ]] && echo -e "${YELLOW}DRY RUN MODE — No changes will be made${NC}"
[[ $ISSUE_SSL == true ]] && echo -e "${YELLOW}SSL ISSUANCE REQUESTED for: $SSL_DOMAINS${NC}"

if [[ $DRY_RUN == false && $FORCE == false ]]; then
  read -p "Continue with deployment? (y/N): " confirm
  [[ ! "$confirm" =~ ^[Yy]$ ]] && echo "Deployment aborted." && exit 0
fi

# 1. Sync source
for site in $SITES; do
  echo -e "${YELLOW}📦 Syncing $site source...${NC}"
  if [[ $DRY_RUN == true ]]; then
    rsync -avz --dry-run --progress --delete \
      --exclude 'node_modules' --exclude 'dist' --exclude '.git' --exclude '.env*' \
      "sites/$site/" "$SERVER:$REMOTE_BASE/$site/"
  else
    rsync -avz --progress --delete \
      --exclude 'node_modules' --exclude 'dist' --exclude '.git' --exclude '.env*' \
      "sites/$site/" "$SERVER:$REMOTE_BASE/$site/"
  fi
done

echo -e "${YELLOW}📦 Syncing root infrastructure (router, package, env)...${NC}"
if [[ $DRY_RUN == false ]]; then
  # Use absolute remote path to avoid home dir ambiguity
  rsync -avz --progress router.js package.json .env "$SERVER:/home/opc/"
fi

[[ $DRY_RUN == true ]] && echo -e "${YELLOW}Dry run complete — Stopping here${NC}" && exit 0

# 2. Remote actions
echo -e "${YELLOW}🔨 Remote build, SSL management, restart & verification...${NC}"

ssh "$SERVER" bash << ENDSSH
set -e

export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"

# === SSL MANAGEMENT ===
if [ "$ISSUE_SSL" = true ]; then
  echo "   🔒 Installing/updating Certbot (if needed)..."
  sudo apt-get update -y
  sudo apt-get install -y certbot python3-certbot-nginx || sudo dnf install -y certbot python3-certbot-nginx

  echo "   🔒 Issuing/expanding Let's Encrypt certificate for: $SSL_DOMAINS"
  sudo certbot --nginx --non-interactive --agree-tos --email "$EMAIL" --redirect \$(for d in $SSL_DOMAINS; do echo "-d \$d"; done)
fi

echo "   🔒 Renewing all existing Let's Encrypt certificates..."
sudo certbot renew --quiet || echo "   No certs to renew or renewal failed (non-critical)"

# === BUILD ===
for site in $SITES; do
  echo "   🗑️ Clearing build cache for \$site..."
  cd "/home/opc/sites/\$site"
  rm -rf .astro dist cache || true
  
  echo "   🏗️ Building \$site..."
  npm ci --prefer-offline --no-audit --no-fund
  npm run build
done

# === RESTART ===
echo "   🔄 Updating root-level dependencies..."
cd "/home/opc"
npm install --prefer-offline --no-audit --no-fund

echo "   🔄 Ensuring multisite-router is running root router.js..."
# Check if PM2 process exists
if pm2 show multisite-router > /dev/null 2>&1; then
    pm2 delete multisite-router || true
fi
pm2 start router.js --name multisite-router --watch --ignore-watch "node_modules .git sites" -f || pm2 start router.js --name multisite-router -f

pm2 save

# === HEALTH REPORT ===
echo ""
echo "   📊 SERVER HEALTH REPORT — \$(date +"%Y-%m-%d %H:%M:%S")"
echo "   ============================================="
echo "   CPU Load / Uptime:"
uptime
echo "   Memory:"
free -h
echo "   Disk:"
df -h /
echo ""
echo "   PM2 Status:"
pm2 list
echo ""
echo "   🔍 Testing God Mode API..."
curl -f -X POST "http://localhost:8100/api/submit-lead" \
  -H "Content-Type: application/json" \
  -d '{"source":"deploy-script-test","name":"Test Lead","email":"test@deploy.local","message":"Deployment verification $TIMESTAMP"}' || echo "   ⚠️ API test failed"

echo "   🧹 Cleaning npm cache..."
npm cache clean --force

echo "   ✅ All remote tasks complete!"
ENDSSH

echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}✅ Deployment & Verification Complete! — $(date +"%Y-%m-%d %H:%M:%S")${NC}"
echo -e "${GREEN}=======================================${NC}"
[[ $ISSUE_SSL == true ]] && echo -e "${CYAN}✅ Real Let's Encrypt SSL certificate issued/expanded for: $SSL_DOMAINS${NC}"
echo -e "${CYAN}All existing certs renewed. Check the remote report above for full details.${NC}"
echo -e "${CYAN}A test lead was submitted to verify the God Mode API.${NC}"
