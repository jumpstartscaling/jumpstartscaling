#!/bin/bash
# Configure JFactory app in Coolify via API
# Usage: COOLIFY_TOKEN=your_token ./configure-jfactory-coolify.sh
# Optional: COOLIFY_URL=http://your-coolify:8000 (default: http://86.48.23.38:8000)

set -e

# Load from .env or .env.local if present
[ -f .env ] && set -a && . .env && set +a
[ -f .env.local ] && set -a && . .env.local && set +a

COOLIFY_URL="${COOLIFY_URL:-http://spark.jumpstartscaling.com:8000}"
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
APPS=$(curl -s -H "$AUTH" "$COOLIFY_URL$API_BASE/applications" 2>/dev/null || echo "[]")

# Find JFactory by name
JFACTORY_UUID=$(echo "$APPS" | python3 -c "
import sys,json
try:
    apps=json.load(sys.stdin)
    for a in apps:
        if a.get('name')=='JFactory':
            print(a['uuid'])
            break
except: pass
" 2>/dev/null)

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
echo ">>> Updating JFactory configuration..."

# 1. Port + clear custom docker options
curl -s -o /dev/null -X PATCH -H "$AUTH" -H "Content-Type: application/json" \
    -d '{"ports_exposes":"8100","custom_docker_run_options":""}' \
    "$COOLIFY_URL$API_BASE/applications/$JFACTORY_UUID"
echo "   ✅ Port 8100, docker options cleared"

# 2. Domains
curl -s -o /dev/null -X PATCH -H "$AUTH" -H "Content-Type: application/json" \
    -d '{"domains":"https://factory.jumpstartscaling.com,https://www.factory.jumpstartscaling.com,https://chrisamaya.work,https://www.chrisamaya.work"}' \
    "$COOLIFY_URL$API_BASE/applications/$JFACTORY_UUID"
echo "   ✅ Domains set"

# 3. Environment variables (bulk)
ADMIN_KEY="${ADMIN_KEY:-$(openssl rand -hex 24 2>/dev/null || echo 'spark')}"
curl -s -o /dev/null -X PATCH -H "$AUTH" -H "Content-Type: application/json" \
    -d "{\"data\":[{\"key\":\"GOD_MODE_API_URL\",\"value\":\"https://api.jumpstartscaling.com\"},{\"key\":\"SITES_BASE_PATH\",\"value\":\"/app\"},{\"key\":\"ADMIN_KEY\",\"value\":\"$ADMIN_KEY\"},{\"key\":\"PUBLIC_N8N_WEBHOOK\",\"value\":\"https://n8n.jumpstartscaling.com/webhook/d282e622-9c83-4936-9d93-05c37eaa7b68\"}]}" \
    "$COOLIFY_URL$API_BASE/applications/$JFACTORY_UUID/envs/bulk"
echo "   ✅ Env vars set (GOD_MODE_API_URL, SITES_BASE_PATH, ADMIN_KEY, PUBLIC_N8N_WEBHOOK)"

echo ""
echo "Done! Deploy via: curl -X POST -H \"Authorization: Bearer \$COOLIFY_TOKEN\" -H \"Content-Type: application/json\" -d '{\"uuid\":\"$JFACTORY_UUID\"}' \"$COOLIFY_URL$API_BASE/deploy\""
