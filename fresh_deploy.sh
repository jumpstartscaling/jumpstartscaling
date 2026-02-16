#!/bin/bash
set -e

echo "🚀 FRESH DEPLOYMENT TO NEW FOLDER"
echo "=================================="
echo ""

SERVER="opc@150.136.117.198"
NEW_FOLDER="jumpstart-v3"
OLD_FOLDER="sites/jumpstartscaling"

echo "📁 Step 1: Create new folder on server"
ssh -i ~/.ssh/id_rsa $SERVER << EOF
echo "Creating ~/$NEW_FOLDER..."
rm -rf ~/$NEW_FOLDER
mkdir -p ~/$NEW_FOLDER
echo "✓ Folder created"
EOF

echo ""
echo "📤 Step 2: Copy entire project to new location"
rsync -avz --progress \
  --exclude 'node_modules' \
  --exclude 'dist' \
  --exclude '.astro' \
  --exclude '.git' \
  sites/jumpstartscaling/ \
  $SERVER:~/$NEW_FOLDER/

echo ""
echo "📦 Step 3: Install dependencies fresh"
ssh -i ~/.ssh/id_rsa $SERVER << EOF
cd ~/$NEW_FOLDER
echo "Current directory: \$(pwd)"
echo ""
echo "Installing dependencies..."
npm install
echo ""
echo "✓ Dependencies installed"
EOF

echo ""
echo "🔨 Step 4: Build from scratch"
ssh -i ~/.ssh/id_rsa $SERVER << EOF
cd ~/$NEW_FOLDER
echo "Building site..."
npm run build
echo ""
echo "Build complete! Checking output:"
ls -lh dist/ | head -10
echo ""
echo "Checking for SystemInterface in build:"
find dist -name "*.js" -exec grep -l "quick-nav-react" {} \; | head -3
EOF

echo ""
echo "🔄 Step 5: Update PM2 to use new folder"
ssh -i ~/.ssh/id_rsa $SERVER << EOF
echo "Stopping old PM2 process..."
pm2 stop jumpstartscaling || true
pm2 delete jumpstartscaling || true

echo ""
echo "Starting PM2 with new folder..."
cd ~/$NEW_FOLDER
pm2 start npm --name "jumpstartscaling" -- run preview -- --port 8100 --host 0.0.0.0

echo ""
echo "Saving PM2 configuration..."
pm2 save

echo ""
echo "PM2 Status:"
pm2 list
EOF

echo ""
echo "🧪 Step 6: Test the new deployment"
ssh -i ~/.ssh/id_rsa $SERVER << EOF
echo "Testing if menu system is in the served HTML..."
curl -s http://localhost:8100 | grep -q "quick-nav-react" && echo "✓ Menu system FOUND!" || echo "✗ Menu system NOT found"
curl -s http://localhost:8100 | grep -q "GlobalInterface" && echo "✓ GlobalInterface reference found" || echo "✗ GlobalInterface NOT found"
EOF

echo ""
echo "🔥 Step 7: Purge Cloudflare cache"
curl -X POST "https://api.cloudflare.com/client/v4/zones/f1e606b93260b3e12a939612c12c6370/purge_cache" \
  -H "Authorization: Bearer nqsfbN92BBmUR1l1nxbMFUPGbImmB8nyUeNsU0u2" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}' \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo "✨ FRESH DEPLOYMENT COMPLETE!"
echo ""
echo "New location: ~/$NEW_FOLDER"
echo "PM2 process: jumpstartscaling"
echo "Port: 8100"
echo ""
echo "Please wait 30 seconds, then visit: https://jumpstartscaling.com"
echo "Clear browser cache (Cmd+Shift+R) and check for the menu!"
