#!/bin/bash
# Build both sites and deploy to server

set -e

echo "🏗️ Building JumpStart Scaling..."
cd sites/jumpstartscaling
npm run build
cd ../..

echo "🏗️ Building Chris Amaya..."
cd sites/chrisamaya
npm run build
cd ../..

echo "📦 Syncing to server..."
SERVER="opc@193.122.168.215"
REMOTE_PATH="/home/opc/sites"

# Create remote directory structure
ssh $SERVER "mkdir -p $REMOTE_PATH/jumpstartscaling/dist $REMOTE_PATH/chrisamaya/dist"

# Upload built sites
rsync -avz --delete sites/jumpstartscaling/dist/ $SERVER:$REMOTE_PATH/jumpstartscaling/dist/
rsync -avz --delete sites/chrisamaya/dist/ $SERVER:$REMOTE_PATH/chrisamaya/dist/

# Upload router
rsync -avz router.js $SERVER:$REMOTE_PATH/

echo "🔄 Restarting router on server..."
ssh $SERVER "cd $REMOTE_PATH && pm2 delete multisite-router 2>/dev/null || true && pm2 start router.js --name multisite-router"

echo "✅ Deployment complete!"
echo "📍 Sites:"
echo "   https://jumpstartscaling.com"
echo "   https://chrisamaya.work"
