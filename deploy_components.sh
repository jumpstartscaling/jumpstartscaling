#!/bin/bash
# Deploy SEO Components Strategy
# This uploads separate component files and modifies index.astro minimally

set -e

SERVER="opc@150.136.117.198"
SITE_PATH="/home/opc/sites/jumpstartscaling"

echo "🚀 Deploying SEO Components (Clean Strategy)"
echo "============================================="
echo ""

echo "📤 Step 1: Uploading component files..."
ssh $SERVER "mkdir -p $SITE_PATH/src/components"
scp SEOTags.astro $SERVER:$SITE_PATH/src/components/
scp GTMTracking.astro $SERVER:$SITE_PATH/src/components/

echo ""
echo "📝 Step 2: Downloading current working index.astro..."
scp $SERVER:$SITE_PATH/src/pages/index.astro ./index_from_server.astro

echo ""
echo "✏️  Step 3: Instructions for manual edit..."
echo ""
echo "Add these TWO lines to index_from_server.astro:"
echo ""
echo "1. After line 4 (after the frontmatter ---):"
echo "   ---"
echo "   import SEOTags from '../components/SEOTags.astro';"
echo "   import GTMTracking from '../components/GTMTracking.astro';"
echo "   ---"
echo ""
echo "2. Inside <head>, after the description meta tag:"
echo "   <SEOTags title={title} description={description} />"
echo ""
echo "3. Before </body>:"
echo "   <GTMTracking />"
echo ""
echo "Would you like me to create the patched version automatically? (y/n)"

read -p "> " answer

if [ "$answer" = "y" ]; then
    echo ""
    echo "🔧 Auto-patching..."
    
    # Add imports after frontmatter
    sed -i '' '4 a\
import SEOTags from '"'"'../components/SEOTags.astro'"'"';\
import GTMTracking from '"'"'../components/GTMTracking.astro'"'"';
' ./index_from_server.astro
    
    # Add SEOTags component after description meta
    sed -i '' '/<meta name="description"/a\
    <SEOTags title={title} description={description} />
' ./index_from_server.astro
    
    # Add GTMTracking before </body>
    sed -i '' '/<\/body>/i\
    <GTMTracking />
' ./index_from_server.astro
    
    echo "✅ Patched!"
    echo ""
    echo "📤 Step 4: Uploading patched index.astro..."
    scp ./index_from_server.astro $SERVER:$SITE_PATH/src/pages/index.astro
    
    echo ""
    echo "🔨 Step 5: Building..."
    ssh $SERVER "cd $SITE_PATH && npm run build"
    
    echo ""
    echo "✅ Deployment Complete!"
    echo "🌐 Visit: https://jumpstartscaling.com"
else
    echo ""
    echo "Manual edit required. File downloaded to: ./index_from_server.astro"
fi
