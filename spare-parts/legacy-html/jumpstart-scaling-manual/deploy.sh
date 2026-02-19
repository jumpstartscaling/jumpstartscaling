#!/bin/bash
# ========================================================
# MANUAL DEPLOYMENT SCRIPT - JUMPSTART SCALING
# ========================================================
# Usage: ./deploy.sh
# 
# This script will take ALL files in this current folder 
# and OVERWRITE the live site at https://jumpstartscaling.com.
# No build step required—what you see is what you get.

echo "🚀 Starting Deployment..."

# 1. Sync Files (excludes this script itself and any git files)
#    -a: Archive mode (preserves permissions/times)
#    -v: Verbose (show progress)
#    -z: Compress during transfer
#    --delete: Remove files on server that don't exist locally (clean sync)

rsync -avz --exclude 'deploy.sh' \
    --exclude '.DS_Store' \
    --exclude '.git' \
    ./ opc@193.122.168.215:/home/opc/sites/jumpstartscaling/dist/

# 2. Restart Router (Optional Cache Clear)
echo "🔄 Refreshing Server Router..."
ssh opc@193.122.168.215 "pm2 restart multisite-router"

echo "✅ SUCCESS! Site is live at https://jumpstartscaling.com"
