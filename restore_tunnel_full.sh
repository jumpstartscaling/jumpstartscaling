#!/bin/bash
set -e

ZONE_ID="f1e606b93260b3e12a939612c12c6370"
TOKEN="A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
TUNNEL_NAME="jumpstart-final-tunnel"
SERVER_IP="150.136.117.198"

log() { echo "👉 $1"; }

log "fetching Account ID..."
ACCOUNT_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID" \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" | grep -o '"account":{"id":"[^"]*"' | cut -d'"' -f5)

if [ -z "$ACCOUNT_ID" ]; then
    echo "❌ Failed to get Account ID"
    exit 1
fi
log "Account ID: $ACCOUNT_ID"

log "Creating/Getting Tunnel..."
SECRET=$(openssl rand -hex 32)
# Try create
RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/tunnels" \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     --data "{\"name\":\"$TUNNEL_NAME\",\"tunnel_secret\":\"$SECRET\"}")
# Extract ID
TUNNEL_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$TUNNEL_ID" ]; then
    log "Tunnel might exist, fetching ID..."
    TUNNEL_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/tunnels?name=$TUNNEL_NAME" \
         -H "Authorization: Bearer $TOKEN" \
         -H "Content-Type: application/json" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    # If existing, we don't know the secret. This is a problem if we need to reinstall.
    # But wait, 'service install' takes the token.
    # If we don't know the secret, we can't generate the token.
    # We must DELETE the old tunnel if we don't know the secret.
    log "Existing Tunnel ID: $TUNNEL_ID. Deleting to start fresh..."
    curl -s -X DELETE "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/tunnels/$TUNNEL_ID" \
         -H "Authorization: Bearer $TOKEN" \
         -H "Content-Type: application/json" > /dev/null
         
    log "Re-creating..."
    RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/tunnels" \
         -H "Authorization: Bearer $TOKEN" \
         -H "Content-Type: application/json" \
         --data "{\"name\":\"$TUNNEL_NAME\",\"tunnel_secret\":\"$SECRET\"}")
    TUNNEL_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
fi
log "Tunnel ID: $TUNNEL_ID"

log "Generating Token..."
JSON_STRING="{\"a\":\"$ACCOUNT_ID\",\"t\":\"$TUNNEL_ID\",\"s\":\"$SECRET\"}"
INSTALL_TOKEN=$(echo -n "$JSON_STRING" | base64)

log "Updating DNS CNAMEs..."
CNAME_TARGET="${TUNNEL_ID}.cfargotunnel.com"

update_cname() {
    REC_NAME=$1
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

log "SSH: Installing on Server..."
ssh -i ~/.ssh/id_rsa opc@$SERVER_IP << EOF
  echo "--- 1. Uninstalling Old ---"
  sudo systemctl stop cloudflared || true
  sudo cloudflared service uninstall || true
  sudo pkill -f cloudflared || true
  
  echo "--- 2. Installing New ---"
  sudo cloudflared service install "$INSTALL_TOKEN"
  
  echo "--- 3. Configuring Ingress ---"
  # Cloudflared config is usually at /etc/cloudflared/config.yml
  sudo tee /etc/cloudflared/config.yml > /dev/null << YAML
tunnel: $TUNNEL_ID
credentials-file: /etc/cloudflared/${TUNNEL_ID}.json

ingress:
  - hostname: jumpstartscaling.com
    service: http://localhost:8100
  - hostname: www.jumpstartscaling.com
    service: http://localhost:8100
  - hostname: n8n.jumpstartscaling.com
    service: http://localhost:5678
  - hostname: cockpit.jumpstartscaling.com
    service: http://localhost:9090
  - hostname: api.jumpstartscaling.com
    service: http://localhost:8100
  - service: http_status:404
YAML

  echo "--- 4. Restarting ---"
  sudo systemctl restart cloudflared
  sudo systemctl status cloudflared --no-pager
  
  echo "✅ TUNNEL ONLINE!"
EOF
