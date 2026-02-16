#!/bin/bash

# Configuration
SERVER="opc@150.136.117.198"
REMOTE_BASE="/home/opc/sites"
LOCAL_BASE="sites"

echo "🔄 Syncing sites to $SERVER..."

# Sync Jumpstart Scaling
echo "👉 Syncing Jumpstart Scaling..."
rsync -avz --exclude "node_modules" --exclude ".git" "$LOCAL_BASE/jumpstartscaling/" "$SERVER:$REMOTE_BASE/jumpstartscaling/"

# Sync Chris Amaya
echo "👉 Syncing Chris Amaya..."
rsync -avz --exclude "node_modules" --exclude ".git" "$LOCAL_BASE/chrisamaya/" "$SERVER:$REMOTE_BASE/chrisamaya/"

echo "✅ Sync Complete! Changes should be live immediately (dev mode)."

