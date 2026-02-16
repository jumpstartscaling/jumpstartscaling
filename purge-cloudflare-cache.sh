#!/bin/bash
# Cloudflare Cache Purge Script
# 
# This script purges the Cloudflare cache for jumpstartscaling.com
# 
# REQUIREMENTS:
# 1. Cloudflare API Token with "Cache Purge" permissions
# 2. Zone ID for jumpstartscaling.com
#
# To get these:
# 1. Log into Cloudflare Dashboard
# 2. Select jumpstartscaling.com domain
# 3. Zone ID is on the right sidebar under "API"
# 4. Create API Token: My Profile > API Tokens > Create Token > "Edit zone DNS" template

set -e

# Configuration (FILL THESE IN)
CLOUDFLARE_ZONE_ID="${CLOUDFLARE_ZONE_ID:-YOUR_ZONE_ID_HERE}"
CLOUDFLARE_API_TOKEN="${CLOUDFLARE_API_TOKEN:-YOUR_API_TOKEN_HERE}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔥 Cloudflare Cache Purge Tool"
echo "==============================="
echo ""

# Validate credentials
if [ "$CLOUDFLARE_ZONE_ID" == "YOUR_ZONE_ID_HERE" ] || [ "$CLOUDFLARE_API_TOKEN" == "YOUR_API_TOKEN_HERE" ]; then
    echo -e "${RED}ERROR: Please set CLOUDFLARE_ZONE_ID and CLOUDFLARE_API_TOKEN${NC}"
    echo ""
    echo "You can set them as environment variables:"
    echo "  export CLOUDFLARE_ZONE_ID='your-zone-id'"
    echo "  export CLOUDFLARE_API_TOKEN='your-api-token'"
    echo ""
    echo "Or edit this script directly."
    echo ""
    echo -e "${YELLOW}MANUAL ALTERNATIVE:${NC}"
    echo "1. Go to: https://dash.cloudflare.com"
    echo "2. Select 'jumpstartscaling.com'"
    echo "3. Go to 'Caching' > 'Configuration'"
    echo "4. Click 'Purge Everything'"
    exit 1
fi

echo "Zone ID: $CLOUDFLARE_ZONE_ID"
echo "Purging all cache..."
echo ""

# Purge all cache
RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/purge_cache" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}')

# Check if successful
SUCCESS=$(echo $RESPONSE | grep -o '"success":true' || echo "")

if [ -n "$SUCCESS" ]; then
    echo -e "${GREEN}✅ Cache purged successfully!${NC}"
    echo ""
    echo "Changes should be visible within 30 seconds."
    echo "Try: https://jumpstartscaling.com/services/paid-acquisition"
else
    echo -e "${RED}❌ Cache purge failed${NC}"
    echo "Response: $RESPONSE"
    exit 1
fi
