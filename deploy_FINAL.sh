#!/bin/bash
# Sync local sites to Remote Server (193.122.168.215) and Build

SERVER="opc@193.122.168.215"
SITE_PATH_JS="/home/opc/sites/jumpstartscaling"
SITE_PATH_CA="/home/opc/sites/chrisamaya"

echo "🚀 Deploying to $SERVER..."

echo "-----------------------------------"
echo "📦 Jumpstart Scaling Deployment"
echo "-----------------------------------"
echo "Syncing src..."
scp -r sites/jumpstartscaling/src $SERVER:$SITE_PATH_JS/
echo "Syncing public..."
scp -r sites/jumpstartscaling/public $SERVER:$SITE_PATH_JS/
echo "Syncing config..."
scp sites/jumpstartscaling/astro.config.mjs $SERVER:$SITE_PATH_JS/
echo "Building..."
ssh $SERVER "cd $SITE_PATH_JS && npm install && npm run build"

echo "-----------------------------------"
echo "📦 Chris Amaya Deployment"
echo "-----------------------------------"
echo "Syncing src..."
scp -r sites/chrisamaya/src $SERVER:$SITE_PATH_CA/
echo "Syncing public..."
scp -r sites/chrisamaya/public $SERVER:$SITE_PATH_CA/
echo "Building..."
ssh $SERVER "cd $SITE_PATH_CA && npm install && npm run build"

echo "✅ ALL DONE!"
