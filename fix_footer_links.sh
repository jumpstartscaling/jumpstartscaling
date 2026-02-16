#!/bin/bash
# Quick Fixes Script - Footer Links

echo "🔧 Fixing footer links to point to /privacy and /terms..."

ssh opc@150.136.117.198 "cd /home/opc/sites/jumpstartscaling/src/pages && sed -i 's|href=\"#\"|href=\"/privacy\"|' index.astro && sed -i '0,/href=\"\/privacy\"/! s|href=\"\/privacy\"|href=\"/terms\"|' index.astro"

echo "✅ Footer links updated!"
echo ""
echo "🔨 Rebuilding site..."
ssh opc@150.136.117.198 "cd /home/opc/sites/jumpstartscaling && npm run build"

echo ""
echo "✅ Done! Footer now links to /privacy and /terms pages"
