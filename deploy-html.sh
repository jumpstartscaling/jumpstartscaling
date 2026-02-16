#!/bin/bash

# Simple HTML Deploy - No Build Required!
# Just sync the HTML folder to the server

set -e

echo "🚀 Deploying Static HTML to jumpstartscaling.com..."

# Sync HTML files directly
rsync -avz --delete \
    sites/jumpstartscaling-html/ \
    opc@158.101.173.152:/home/opc/sites/jumpstartscaling/

echo "✅ Deploy complete! Site is live at https://jumpstartscaling.com"
echo ""
echo "💡 To update the site:"
echo "   1. Edit sites/jumpstartscaling-html/index.html"
echo "   2. Run: ./deploy-html.sh"
echo "   3. Done! (No build step needed)"
