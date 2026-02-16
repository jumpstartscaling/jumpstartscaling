#!/bin/bash
set -e

echo "🚀 Quick Deploy - Build Local, Sync Dist"
echo "========================================"

cd sites/jumpstartscaling

echo ""
echo "📦 Step 1: Building locally..."
npm run build

echo ""
echo "📤 Step 2: Syncing dist folder to server..."
rsync -avz --delete \
  dist/ \
  opc@150.136.117.198:~/sites/jumpstartscaling/dist/

echo ""
echo "🔄 Step 3: Restarting PM2..."
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 "pm2 restart jumpstartscaling"

echo ""
echo "🔥 Step 4: Purging Cloudflare cache..."
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/f1e606b93260b3e12a939612c12c6370/purge_cache" \
  -H "Authorization: Bearer nqsfbN92BBmUR1l1nxbMFUPGbImmB8nyUeNsU0u2" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}' > /dev/null

echo ""
echo "✅ DONE! Changes live in ~30 seconds at https://jumpstartscaling.com"
