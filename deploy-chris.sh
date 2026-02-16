#!/bin/bash
# Quick HTML Deploy for chrisamaya.work - No Build, Just Sync

set -e

echo "🚀 Deploying Chris Amaya Pure HTML Version..."

# 1. Prepare Local Dist Folder
echo "📦 Preparing files..."
DIST_DIR="sites/chrisamaya/dist"
PUBLIC_DIR="sites/chrisamaya/public"

# Create dist if it doesn't exist
mkdir -p "$DIST_DIR"

# Clear old build artifacts
rm -rf "$DIST_DIR"/*

# Copy static assets (index.html, favicon, robots.txt, etc.)
cp -r "$PUBLIC_DIR"/* "$DIST_DIR"/

# Show what we're deploying
echo "✅ Files ready in $DIST_DIR:"
ls -lh "$DIST_DIR"

# 2. Sync to Server
echo "📤 Syncing to server..."
SERVER="opc@193.122.168.215"
REMOTE_PATH="/home/opc/sites/chrisamaya/dist"

# Ensure remote directory exists
ssh $SERVER "mkdir -p $REMOTE_PATH"

# Rsync the contents of dist to the remote folder
rsync -avz --delete "$DIST_DIR/" "$SERVER:$REMOTE_PATH/"

# 3. Restart Router (Optional but good practice to ensure cache clearing if any)
echo "🔄 Restarting Router..."
ssh $SERVER "pm2 restart multisite-router"

echo "✅ Chris Amaya HTML Deploy complete!"
echo "🌐 Live at: https://chrisamaya.work"
