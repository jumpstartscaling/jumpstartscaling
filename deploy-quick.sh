#!/bin/bash
# Quick HTML Deploy - No Build, Just Sync

set -e

echo "🚀 Deploying Pure HTML Version..."

# Copy HTML files to dist (overwrite astro build)
echo "📦 Preparing files..."
rm -rf sites/jumpstartscaling/dist/*
cp -r sites/jumpstartscaling-html/* sites/jumpstartscaling/dist/

# Show what we're deploying
echo "✅ Files ready:"
ls -lh sites/jumpstartscaling/dist/

# Extract rsync command from original deploy.sh
echo "📤 Syncing to server..."
SERVER="opc@193.122.168.215"
REMOTE_PATH="/home/opc/sites"

cd sites/jumpstartscaling && \
rsync -avz --delete dist/ $SERVER:$REMOTE_PATH/jumpstartscaling/dist/

# Sync Router
echo "🔌 Syncing Router..."
cd ../..
rsync -avz router.js $SERVER:/home/opc/sites/

# Restart Router
echo "🔄 Restarting Router..."
ssh $SERVER "pm2 restart multisite-router"

echo "✅ HTML Deploy complete!"
echo "🌐 Live at: https://jumpstartscaling.com"
