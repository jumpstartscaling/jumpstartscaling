#!/bin/bash
set -e

echo "🔄 Syncing files to server..."
rsync -avz --exclude 'node_modules' --exclude '.next' --exclude '.git' sites/jumpstartscaling-next/ opc@150.136.117.198:~/jumpstart-next/

echo "🔄 Switching to Next.js Site"
echo "============================"

# Stop all PM2 processes
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
echo "Stopping all PM2 processes..."
pm2 stop all
pm2 delete all

echo ""
echo "Starting Next.js on port 8100..."
cd ~/jumpstart-next
pm2 start npm --name "jumpstart-next" -- run dev
pm2 save

echo ""
echo "Current PM2 status:"
pm2 list

echo ""
echo "Testing local server..."
sleep 3
curl -s http://localhost:8100 | grep -q "next" && echo "✅ Next.js is running!" || echo "❌ Still showing old site"
EOF

echo ""
echo "Purging Cloudflare cache (3x)..."
for i in 1 2 3; do
  curl -s -X POST "https://api.cloudflare.com/client/v4/zones/f1e606b93260b3e12a939612c12c6370/purge_cache" \
    -H "Authorization: Bearer A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG" \
    -H "Content-Type: application/json" \
    --data '{"purge_everything":true}' > /dev/null
  echo "  Purge $i/3 sent"
  sleep 2
done

echo ""
echo "✅ Done! Wait 60 seconds then visit:"
echo "   https://jumpstartscaling.com"
echo ""
echo "Hard refresh: Cmd+Shift+R (Mac) or Ctrl+Shift+R (Windows)"
