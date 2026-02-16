#!/bin/bash
set -e

echo "🔥 NUCLEAR OPTION - Force Complete Refresh"
echo "=========================================="

# Step 1: Build locally
echo ""
echo "Step 1: Building locally..."
cd sites/jumpstartscaling
rm -rf dist .astro
npm run build
cd ../..

# Step 2: Stop everything on server
echo ""
echo "Step 2: Stopping all PM2 processes..."
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
pm2 stop all || true
pm2 delete all || true
pm2 flush
EOF

# Step 3: Sync EVERYTHING
echo ""
echo "Step 3: Syncing entire site..."
rsync -avz --delete \
  --exclude 'node_modules' \
  --exclude '.git' \
  sites/jumpstartscaling/ \
  opc@150.136.117.198:~/sites/jumpstartscaling-fresh/

# Step 4: Fresh start on server
echo ""
echo "Step 4: Starting fresh PM2 with production build..."
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
cd ~/sites/jumpstartscaling-fresh
pm2 start npm --name "jumpstartscaling" -- run preview -- --port 8100 --host 0.0.0.0
pm2 save
pm2 list
echo ""
echo "Testing served content..."
curl -s http://localhost:8100 | grep -c "quick-nav-react" || echo "0"
EOF

# Step 5: Purge Cloudflare multiple times
echo ""
echo "Step 5: Purging Cloudflare cache (3x)..."
for i in 1 2 3; do
  curl -X POST "https://api.cloudflare.com/client/v4/zones/f1e606b93260b3e12a939612c12c6370/purge_cache" \
    -H "Authorization: Bearer nqsfbN92BBmUR1l1nxbMFUPGbImmB8nyUeNsU0u2" \
    -H "Content-Type: application/json" \
    --data '{"purge_everything":true}' > /dev/null
  echo "  Purge $i/3 sent"
  sleep 2
done

echo ""
echo "✅ DONE!"
echo ""
echo "Wait 60 seconds, then:"
echo "1. Close all browser tabs for jumpstartscaling.com"
echo "2. Clear browser cache completely"
echo "3. Open https://jumpstartscaling.com in private/incognito window"
echo ""
echo "The menu MUST be there. If not, there's a Cloudflare Tunnel config issue."
