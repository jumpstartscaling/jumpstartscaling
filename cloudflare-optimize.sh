#!/bin/bash

# Cloudflare Optimization & Recovery Script
# This script configures optimal Cloudflare settings to prevent downtime

# API Configuration
export CLOUDFLARE_API_TOKEN="nqsfbN92BBmUR1l1nxbMFUPGbImmB8nyUeNsU0u2"
export CLOUDFLARE_ACCOUNT_ID="6f1e3d2fbdfc035a50b00145d690f65c"
export JUMPSTART_ZONE_ID="f1e606b93260b3e12a939612c12c6370"

echo "🔧 Cloudflare Optimization Script"
echo "=================================="

# Function to make API calls
cf_api() {
    local method=$1
    local endpoint=$2
    local data=$3
    
    if [ -n "$data" ]; then
        curl -s -X "$method" "https://api.cloudflare.com/client/v4$endpoint" \
            -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
            -H "Content-Type: application/json" \
            --data "$data"
    else
        curl -s -X "$method" "https://api.cloudflare.com/client/v4$endpoint" \
            -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN"
    fi
}

# Check tunnel health on server
echo "📡 Checking Cloudflare Tunnel Status..."
ssh opc@150.136.117.198 "sudo systemctl is-active cloudflared && pm2 list | grep -E 'jumpstartscaling|chrisamaya'"

# Test domain accessibility
echo -e "\n🌐 Testing Domain Accessibility..."
for domain in jumpstartscaling.com www.jumpstartscaling.com api.jumpstartscaling.com; do
    status=$(curl -s -o /dev/null -w "%{http_code}" https://$domain)
    if [ "$status" = "200" ]; then
        echo "✅ $domain - HTTP $status"
    else
        echo "❌ $domain - HTTP $status"
    fi
done

# List all zones
echo -e "\n📋 Available Zones in this Account:"
cf_api GET "/zones" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if data['success']:
        for zone in data['result']:
            print(f\"  - {zone['name']} (ID: {zone['id']}) - Status: {zone['status']}\")
    else:
        print('  Error:', data.get('errors', 'Unknown'))
except:
    print('  Failed to parse response')
"

echo -e "\n💡 To add chrisamaya.work to this Cloudflare account:"
echo "   1. Log into Cloudflare at https://dash.cloudflare.com"
echo "   2. Click 'Add Site' and enter 'chrisamaya.work'"
echo "   3. Update nameservers at your domain registrar"
echo "   4. Add CNAME: chrisamaya.work -> 54f5301e-76b0-48ff-8660-030accf4cfa8.cfargotunnel.com"

echo -e "\n✅ Optimization script complete!"
