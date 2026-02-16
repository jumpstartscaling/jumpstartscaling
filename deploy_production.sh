#!/bin/bash
# Deploy Production Version to JumpStart Scaling Server
# Usage: ./deploy_production.sh

set -e

SERVER="opc@150.136.117.198"
SITE_PATH="/home/opc/sites/jumpstartscaling"
LOCAL_FILE="index_production.astro"
OG_IMAGE_FILE="og-image.png.ts"

echo "🚀 JumpStart Scaling - Production Deployment"
echo "============================================"
echo ""

# Check if local files exist
if [ ! -f "$LOCAL_FILE" ]; then
    echo "❌ Error: $LOCAL_FILE not found!"
    exit 1
fi

echo "📦 Step 1: Installing Satori dependencies on server..."
ssh $SERVER "cd $SITE_PATH && npm install satori @resvg/resvg-js"

echo ""
echo "🗑️  Step 2: Backing up current index.astro..."
ssh $SERVER "cd $SITE_PATH/src/pages && cp index.astro index.astro.backup-$(date +%Y%m%d-%H%M%S)"

echo ""
echo "📤 Step 3: Uploading production index.astro..."
scp $LOCAL_FILE $SERVER:$SITE_PATH/src/pages/index.astro

echo ""
echo "📤 Step 4: Uploading OG image generator..."
# Create src/pages directory if needed
ssh $SERVER "mkdir -p $SITE_PATH/src/pages"
scp $OG_IMAGE_FILE $SERVER:$SITE_PATH/src/pages/og-image.png.ts

echo ""
echo "🔨 Step 5: Building the site..."
ssh $SERVER "cd $SITE_PATH && npm run build"

echo ""
echo "✅ Deployment Complete!"
echo ""
echo "🌐 View at: https://jumpstartscaling.com"
echo ""
echo "📊 To verify OG image: https://jumpstartscaling.com/og-image.png"
echo ""
echo "💡 Next Steps:"
echo "   1. Test with Facebook Debugger: https://developers.facebook.com/tools/debug/"
echo "   2. Test with Twitter Card Validator: https://cards-dev.twitter.com/validator"
echo "   3. Update n8n webhook URL in the form (search for YOUR_UNIQUE_ID)"
echo ""
