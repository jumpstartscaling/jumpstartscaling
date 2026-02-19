#!/bin/bash
# Configure JFactory app in Coolify via API
# Usage: COOLIFY_TOKEN=your_token ./configure-jfactory-coolify.sh
# Optional: COOLIFY_URL=http://your-coolify:8000 (default: http://86.48.23.38:8000)

set -e

COOLIFY_URL="${COOLIFY_URL:-http://86.48.23.38:8000}"
TOKEN="${COOLIFY_TOKEN}"

if [ -z "$TOKEN" ]; then
    echo "❌ Set COOLIFY_TOKEN first."
    echo "   Get token: Coolify → Keys & Tokens → API tokens → Create"
    echo "   Usage: COOLIFY_TOKEN=xxx ./configure-jfactory-coolify.sh"
    exit 1
fi

AUTH="Authorization: Bearer $TOKEN"

# Detect API base
for path in "/api/v1" "/api" ""; do
    code=$(curl -s -o /dev/null -w "%{http_code}" -H "$AUTH" "$COOLIFY_URL${path}/servers" 2>/dev/null || echo "000")
    if [ "$code" = "200" ]; then
        API_BASE="${path}"
        break
    fi
done

if [ -z "$API_BASE" ]; then
    echo "❌ Could not reach Coolify API at $COOLIFY_URL"
    exit 1
fi

echo ">>> Fetching applications..."
APPS=$(curl -s -H "$AUTH" "$COOLIFY_URL$API_BASE/applications" 2>/dev/null || curl -s -H "$AUTH" "$COOLIFY_URL$API_BASE/projects" 2>/dev/null || echo "[]")

# Try to find JFactory - structure may vary
JFACTORY_UUID=$(echo "$APPS" | grep -o '"uuid":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$JFACTORY_UUID" ]; then
    echo "⚠️  Could not find JFactory app via API. You may need to configure manually:"
    echo ""
    echo "  1. Coolify → JFactory → Configuration"
    echo "  2. Domains: factory.jumpstartscaling.com, www.factory.jumpstartscaling.com, chrisamaya.work, www.chrisamaya.work"
    echo "  3. Dockerfile Location: Dockerfile"
    echo "  4. Base Directory: (empty or /)"
    echo "  5. Environment Variables:"
    echo "     - GOD_MODE_API_URL = https://api.jumpstartscaling.com"
    echo "     - SITES_BASE_PATH = /app"
    echo "     - ADMIN_KEY = (openssl rand -hex 24)"
    echo "     - PUBLIC_N8N_WEBHOOK = https://n8n.jumpstartscaling.com/webhook/..."
    echo ""
    echo "  6. Custom Docker Options: (clear/remove the long SYS_ADMIN string)"
    echo "  7. Port: 8100"
    exit 0
fi

echo "   Found app: $JFACTORY_UUID"
echo ">>> Attempting to update configuration..."

# Coolify v4 API format may differ - attempt PATCH
RESULT=$(curl -s -w "\n%{http_code}" -X PATCH -H "$AUTH" -H "Content-Type: application/json" \
    -d '{
        "ports_exposes": "8100",
        "custom_docker_options": ""
    }' "$COOLIFY_URL$API_BASE/applications/$JFACTORY_UUID" 2>/dev/null || echo -e "\n000")

HTTP=$(echo "$RESULT" | tail -1)
if [ "$HTTP" = "200" ] || [ "$HTTP" = "204" ]; then
    echo "   ✅ Configuration updated"
else
    echo "   ⚠️  API update returned $HTTP. Configure manually (see JFACTORY_COOLIFY_CONFIG.md)"
fi

echo ""
echo "Done. Redeploy JFactory to apply changes."
