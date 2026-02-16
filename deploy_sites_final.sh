#!/bin/bash
echo "🚀 Building Jumpstart Scaling..."
cd sites/jumpstartscaling
npm install
npm run build
cd ../..

echo "🚀 Building Chris Amaya..."
cd sites/chrisamaya
npm install
npm run build
cd ../..

echo "📦 Syncing to Server..."
rsync -avz --exclude 'node_modules' --exclude '.git' sites/jumpstartscaling/dist/ opc@193.122.168.215:/home/opc/sites/jumpstartscaling/dist/
rsync -avz --exclude 'node_modules' --exclude '.git' sites/chrisamaya/dist/ opc@193.122.168.215:/home/opc/sites/chrisamaya/dist/

echo "✅ Deployment Complete!"
