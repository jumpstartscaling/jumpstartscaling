#!/bin/bash
# Sync local Jumpstart source to Remote and Build
# Target Server: 150.136.117.198 (From FILE_VERIFICATION.md)

SERVER="opc@150.136.117.198"
SITE_PATH="/home/opc/sites/jumpstartscaling"

echo "🚀 Starting Full Deployment for Jumpstart Scaling..."

echo "📂 Syncing src directory..."
rsync -avz --exclude 'node_modules' --exclude '.git' --exclude '.DS_Store' sites/jumpstartscaling/src/ $SERVER:$SITE_PATH/src/

echo "📂 Syncing public directory..."
rsync -avz --exclude 'node_modules' --exclude '.git' --exclude '.DS_Store' sites/jumpstartscaling/public/ $SERVER:$SITE_PATH/public/

echo "📄 Syncing configuration..."
scp sites/jumpstartscaling/astro.config.mjs $SERVER:$SITE_PATH/

echo "🏗️  Building and Restarting on Server..."
ssh $SERVER "cd $SITE_PATH && npm install && npm run build && pm2 restart jumpstart-v2"

echo "✅ Full Deployment Complete!"
echo "👉 Please clear Cloudflare Cache if changes are not visible."
