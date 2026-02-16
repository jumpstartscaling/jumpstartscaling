#!/bin/bash
# Helper script executed by deploy.cmd on the server
# Handles unpacking, building, SSL, and restarting

set -e

# Arguments passed from deploy.cmd
TARGET="$1"
ISSUE_SSL="$2"
SSL_DOMAINS="$3"
EMAIL="$4"

# Configuration
REMOTE_BASE="/home/opc/sites"

# Ensure NVM is loaded
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "   🚀 [Remote] Starting deployment tasks for: $TARGET"

# 1. Unpack Source Code
echo "   📦 [Remote] Unpacking source code..."
# We assume deployment.tar.gz is in the home dir
tar -xzf deployment.tar.gz -C "$REMOTE_BASE"
rm deployment.tar.gz

# 2. SSL Management
if [ "$ISSUE_SSL" = "true" ]; then
  echo "   🔒 [Remote] Installing/updating Certbot..."
  if command -v dnf &> /dev/null; then
      sudo dnf install -y certbot python3-certbot-nginx
  elif command -v apt-get &> /dev/null; then
      sudo apt-get update -y && sudo apt-get install -y certbot python3-certbot-nginx
  fi

  echo "   🔒 [Remote] Issuing/expanding SSL cert for: $SSL_DOMAINS"
  # We use --redirect to force HTTPS
  sudo certbot --nginx --non-interactive --agree-tos --email "$EMAIL" --redirect $(for d in $SSL_DOMAINS; do echo "-d $d"; done)
else
  echo "   🔒 [Remote] Renewing existing certificates..."
  sudo certbot renew --quiet || echo "   SSL renewal skipped or not needed."
fi

# 3. Build & Install
# Define valid sites based on target
if [ "$TARGET" = "both" ]; then
    SITES="jumpstartscaling chrisamaya"
else
    SITES="$TARGET"
fi

for site in $SITES; do
    SITE_DIR="$REMOTE_BASE/$site"
    echo "   🏗️  [Remote] Building $site..."
    
    if [ -d "$SITE_DIR" ]; then
        cd "$SITE_DIR"
        # Safe install
        npm ci --prefer-offline --no-audit --no-fund --quiet
        npm run build
    else
        echo "   ⚠️ Directory $SITE_DIR not found, skipping..."
    fi
done

# 4. Restart Services (PM2)
echo "   🔄 [Remote] Reloading router..."
pm2 reload multisite-router || pm2 restart multisite-router
pm2 save

# 5. Health Check
echo ""
echo "   📊 [Remote] Server Health:"
uptime
free -h | grep Mem | awk '{print "   Memory: " $3 " / " $2}'

echo ""
echo "   🔍 [Remote] Testing API..."
curl -f -X POST "https://api.jumpstartscaling.com/submit-lead" \
  -H "Content-Type: application/json" \
  -d '{"source":"deploy-cmd-test","name":"Windows Deploy","email":"win@deploy.local","message":"Verification"}' \
  && echo "   ✅ API Test Passed" || echo "   ⚠️ API Test Failed"

echo "   🧹 [Remote] Cleaning up..."
npm cache clean --force

echo "   ✅ [Remote] All tasks complete."
