#!/bin/bash
# Deploy jumpstartscaling-site and chrisamaya-site to Coolify via API
# Prerequisites:
#   1. GitHub App added in Coolify (Sources → + Add → GitHub App, org: caw-jump)
#   2. API token from Coolify (Keys & Tokens → API tokens → Create)
#
# Usage: COOLIFY_TOKEN=your_token ./deploy-to-coolify.sh

set -e

COOLIFY_URL="${COOLIFY_URL:-http://86.48.23.38:8000}"
TOKEN="${COOLIFY_TOKEN}"

if [ -z "$TOKEN" ]; then
    echo "❌ Set COOLIFY_TOKEN first."
    echo ""
    echo "Get token: $COOLIFY_URL → Keys & Tokens → API tokens → Create"
    echo ""
    echo "Usage: COOLIFY_TOKEN=xxx ./deploy-to-coolify.sh"
    exit 1
fi

AUTH="Authorization: Bearer $TOKEN"
API="$COOLIFY_URL/api/v1"

# Detect API base (Coolify v4 may use root paths)
detect_api() {
    for path in "" "/api/v1" "/api"; do
        code=$(curl -s -o /dev/null -w "%{http_code}" -H "$AUTH" "$COOLIFY_URL${path}/servers" 2>/dev/null)
        if [ "$code" = "200" ]; then
            echo "$path"
            return
        fi
    done
    echo ""  # fallback to root
}

BASE=$(detect_api)
echo "Using API: ${COOLIFY_URL}${BASE:-/}"
echo ""

# Fetch servers
echo ">>> Fetching servers..."
SERVERS=$(curl -s -H "$AUTH" "$COOLIFY_URL$BASE/servers")
SERVER_UUID=$(echo "$SERVERS" | grep -o '"uuid":"[^"]*"' | head -1 | cut -d'"' -f4)
if [ -z "$SERVER_UUID" ]; then
    echo "❌ No server found. Is the token valid? Check: $COOLIFY_URL → Keys & Tokens"
    exit 1
fi
echo "   Server: $SERVER_UUID"

# Fetch projects
echo ">>> Fetching projects..."
PROJECTS=$(curl -s -H "$AUTH" "$COOLIFY_URL$BASE/projects")
PROJECT_UUID=$(echo "$PROJECTS" | grep -o '"uuid":"[^"]*"' | head -1 | cut -d'"' -f4)
if [ -z "$PROJECT_UUID" ]; then
    echo "   No project found, creating one..."
    # Try to create project (endpoint may vary)
    CREATE=$(curl -s -X POST -H "$AUTH" -H "Content-Type: application/json" \
        -d '{"name":"Spark Sites"}' "$COOLIFY_URL$BASE/projects" 2>/dev/null || true)
    PROJECT_UUID=$(echo "$CREATE" | grep -o '"uuid":"[^"]*"' | head -1 | cut -d'"' -f4)
fi
if [ -z "$PROJECT_UUID" ]; then
    echo "❌ Need a project. Create one in Coolify: + New → Project"
    exit 1
fi
echo "   Project: $PROJECT_UUID"

# Fetch GitHub sources
echo ">>> Fetching GitHub App sources..."
SOURCES=$(curl -s -H "$AUTH" "$COOLIFY_URL$BASE/sources" 2>/dev/null || curl -s -H "$AUTH" "$COOLIFY_URL$BASE/github" 2>/dev/null || echo "[]")
GITHUB_UUID=$(echo "$SOURCES" | grep -o '"uuid":"[^"]*"' | head -1 | cut -d'"' -f4)
if [ -z "$GITHUB_UUID" ]; then
    echo "❌ No GitHub App source. Add one: Sources → + Add → GitHub App (org: caw-jump)"
    exit 1
fi
echo "   GitHub App: $GITHUB_UUID"
echo ""

# Create jumpstartscaling-site
echo ">>> Creating jumpstartscaling-site..."
JS_RESULT=$(curl -s -w "\n%{http_code}" -X POST -H "$AUTH" -H "Content-Type: application/json" \
    -d "{
        \"project_uuid\": \"$PROJECT_UUID\",
        \"server_uuid\": \"$SERVER_UUID\",
        \"github_app_uuid\": \"$GITHUB_UUID\",
        \"environment_name\": \"production\",
        \"git_repository\": \"caw-jump/jumpstartscaling-site\",
        \"git_branch\": \"main\",
        \"build_pack\": \"nixpacks\",
        \"install_command\": \"npm install\",
        \"build_command\": \"npm run build\",
        \"start_command\": \"node server.js\",
        \"ports_exposes\": \"8100\",
        \"name\": \"jumpstartscaling-site\",
        \"domains\": \"jumpstartscaling.com,www.jumpstartscaling.com\"
    }" "$COOLIFY_URL$BASE/applications/private-github-app" 2>/dev/null)
JS_HTTP=$(echo "$JS_RESULT" | tail -1)
JS_BODY=$(echo "$JS_RESULT" | sed '$d')

if [ "$JS_HTTP" = "201" ] || [ "$JS_HTTP" = "200" ]; then
    JS_UUID=$(echo "$JS_BODY" | grep -o '"uuid":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "   ✅ Created: $JS_UUID"
    echo "   Deploying..."
    curl -s -X POST -H "$AUTH" "$COOLIFY_URL$BASE/applications/$JS_UUID/deploy" >/dev/null 2>&1 || true
else
    echo "   Response ($JS_HTTP): $JS_BODY"
fi
echo ""

# Create chrisamaya-site
echo ">>> Creating chrisamaya-site..."
CA_RESULT=$(curl -s -w "\n%{http_code}" -X POST -H "$AUTH" -H "Content-Type: application/json" \
    -d "{
        \"project_uuid\": \"$PROJECT_UUID\",
        \"server_uuid\": \"$SERVER_UUID\",
        \"github_app_uuid\": \"$GITHUB_UUID\",
        \"environment_name\": \"production\",
        \"git_repository\": \"caw-jump/chrisamaya-site\",
        \"git_branch\": \"main\",
        \"build_pack\": \"nixpacks\",
        \"install_command\": \"npm install\",
        \"build_command\": \"npm run build\",
        \"start_command\": \"node server.js\",
        \"ports_exposes\": \"8101\",
        \"name\": \"chrisamaya-site\",
        \"domains\": \"chrisamaya.work,www.chrisamaya.work\"
    }" "$COOLIFY_URL$BASE/applications/private-github-app" 2>/dev/null)
CA_HTTP=$(echo "$CA_RESULT" | tail -1)
CA_BODY=$(echo "$CA_RESULT" | sed '$d')

if [ "$CA_HTTP" = "201" ] || [ "$CA_HTTP" = "200" ]; then
    CA_UUID=$(echo "$CA_BODY" | grep -o '"uuid":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "   ✅ Created: $CA_UUID"
    echo "   Deploying..."
    curl -s -X POST -H "$AUTH" "$COOLIFY_URL$BASE/applications/$CA_UUID/deploy" >/dev/null 2>&1 || true
else
    echo "   Response ($CA_HTTP): $CA_BODY"
fi

echo ""
echo "🎉 Done. Check status at $COOLIFY_URL"
echo ""
echo "If API paths differ, create the apps manually - see COOLIFY_GITHUB_SETUP.md"
