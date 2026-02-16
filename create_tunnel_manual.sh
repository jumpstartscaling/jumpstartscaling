#!/bin/bash
set -e

ZONE_ID="f1e606b93260b3e12a939612c12c6370"
TOKEN="A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
TUNNEL_NAME="jumpstart-pro-v4"

echo "--- 1. GET ACCOUNT ID ---"
# Get Zone details to find Account ID
ACCOUNT_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID" \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" | grep -o '"account":{"id":"[^"]*"' | cut -d'"' -f5)

echo "Account ID: $ACCOUNT_ID"

if [ -z "$ACCOUNT_ID" ]; then
    echo "❌ Failed to get Account ID"
    exit 1
fi

echo "--- 2. CREATE TUNNEL ---"
# Create Tunnel
# Generate 32 char random secret
SECRET=$(openssl rand -hex 32)
# Base64 encode it for the payload? No, documentation says plain string. 
# Wait, for the install token it needs to be part of the json.
# Let's just use the output.

RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/tunnels" \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     --data "{\"name\":\"$TUNNEL_NAME\",\"tunnel_secret\":\"$SECRET\"}")

TUNNEL_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$TUNNEL_ID" ]; then
    echo "❌ Failed to create tunnel (or it exists). Response:"
    echo "$RESPONSE"
    # Try to find existing
    TUNNEL_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/tunnels?name=$TUNNEL_NAME" \
         -H "Authorization: Bearer $TOKEN" \
         -H "Content-Type: application/json" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Found Existing: $TUNNEL_ID"
fi

echo "Tunnel ID: $TUNNEL_ID"

echo "--- 3. GENERATE TOKEN ---"
# Token = base64( {"a": account, "t": tunnel, "s": secret} )
# We need to construct the JSON carefully
JSON_STRING="{\"a\":\"$ACCOUNT_ID\",\"t\":\"$TUNNEL_ID\",\"s\":\"$SECRET\"}"
echo "Raw JSON: $JSON_STRING"

TOKEN_B64=$(echo -n "$JSON_STRING" | base64)
echo "::TOKEN::$TOKEN_B64::ENDTOKEN::"

echo "--- 4. UPDATE DNS ---"
CNAME_TARGET="${TUNNEL_ID}.cfargotunnel.com"

update_cname() {
    REC_NAME=$1
    echo "Updating $REC_NAME to $CNAME_TARGET"
    
    # Check/Delete existing
    REC_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$REC_NAME" \
         -H "Authorization: Bearer $TOKEN" \
         -H "Content-Type: application/json" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
         
    if [ -n "$REC_ID" ]; then
        curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$REC_ID" \
             -H "Authorization: Bearer $TOKEN" \
             -H "Content-Type: application/json" > /dev/null
    fi
    
    # Create CNAME
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
         -H "Authorization: Bearer $TOKEN" \
         -H "Content-Type: application/json" \
         --data "{\"type\":\"CNAME\",\"name\":\"$REC_NAME\",\"content\":\"$CNAME_TARGET\",\"proxied\":true,\"ttl\":1}" > /dev/null
}

update_cname "jumpstartscaling.com"
update_cname "www.jumpstartscaling.com"
update_cname "n8n.jumpstartscaling.com"
update_cname "cockpit.jumpstartscaling.com"
update_cname "api.jumpstartscaling.com"

echo "✅ DNS Updated."
