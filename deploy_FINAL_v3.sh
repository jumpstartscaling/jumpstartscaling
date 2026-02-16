#!/bin/bash
# Full Sync (excluding node_modules) and Build for Tenants
# Target: opc@193.122.168.215 (Correct IP)

SERVER="opc@193.122.168.215"

echo "🚀 FULL SYNC & DEPLOY to $SERVER..."

# JUMPSTART
echo "-----------------------------------"
echo "📦 Jumpstart Scaling"
echo "-----------------------------------"
echo "Syncing ALL files (src, public, config, package.json)..."
rsync -avz --exclude 'node_modules' --exclude '.git' --exclude 'dist' --exclude '.DS_Store' sites/jumpstartscaling/ $SERVER:/home/opc/sites/jumpstartscaling/

echo "Building Jumpstart..."
ssh $SERVER "cd /home/opc/sites/jumpstartscaling && npm install && npm run build"

# CHRIS AMAYA
echo "-----------------------------------"
echo "📦 Chris Amaya"
echo "-----------------------------------"
echo "Syncing ALL files..."
rsync -avz --exclude 'node_modules' --exclude '.git' --exclude 'dist' --exclude '.DS_Store' sites/chrisamaya/ $SERVER:/home/opc/sites/chrisamaya/

echo "Building Chris Amaya..."
ssh $SERVER "cd /home/opc/sites/chrisamaya && npm install && npm run build"

echo "✅ DEPLOYMENT SUCCESSFUL!"
