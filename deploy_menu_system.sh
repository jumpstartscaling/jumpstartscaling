#!/bin/bash

echo "🚀 Deploying Menu System to Oracle Server"
echo "=========================================="

SERVER="opc@150.136.117.198"
SITE_PATH="sites/jumpstartscaling"

echo ""
echo "📁 Step 1: Syncing source files..."
rsync -avz --progress \
  --exclude 'node_modules' \
  --exclude 'dist' \
  --exclude '.astro' \
  $SITE_PATH/src/ $SERVER:~/$SITE_PATH/src/

echo ""
echo "✅ Step 2: Verifying files on server..."
ssh -i ~/.ssh/id_rsa $SERVER << 'ENDSSH'
cd ~/sites/jumpstartscaling
echo "Current directory: $(pwd)"
echo ""
echo "Checking menu files:"
ls -lh src/components/ui/SystemInterface.jsx 2>/dev/null && echo "✓ SystemInterface.jsx found" || echo "✗ SystemInterface.jsx MISSING"
ls -lh src/components/ui/GlobalInterface.astro 2>/dev/null && echo "✓ GlobalInterface.astro found" || echo "✗ GlobalInterface.astro MISSING"
ls -lh src/components/ui/CyberConsole.css 2>/dev/null && echo "✓ CyberConsole.css found" || echo "✗ CyberConsole.css MISSING"
ENDSSH

echo ""
echo "🔨 Step 3: Building site on server..."
ssh -i ~/.ssh/id_rsa $SERVER << 'ENDSSH'
cd ~/sites/jumpstartscaling
echo "Running npm run build..."
npm run build 2>&1 | tail -30
echo ""
echo "Build exit code: $?"
ENDSSH

echo ""
echo "🔄 Step 4: Restarting PM2 service..."
ssh -i ~/.ssh/id_rsa $SERVER "pm2 restart jumpstartscaling && pm2 list"

echo ""
echo "🔥 Step 5: Purging Cloudflare cache..."
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/f1e606b93260b3e12a939612c12c6370/purge_cache" \
  -H "Authorization: Bearer nqsfbN92BBmUR1l1nxbMFUPGbImmB8nyUeNsU0u2" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}' | python3 -c "import sys, json; data = json.load(sys.stdin); print('✅ Cache purged!' if data.get('success') else '❌ Cache purge failed')"

echo ""
echo "✨ Deployment Complete!"
echo "Site should be live at: https://jumpstartscaling.com"
echo ""
