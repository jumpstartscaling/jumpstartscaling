#!/bin/bash
ZONE_ID="f1e606b93260b3e12a939612c12c6370"
TOKEN="A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
IP="150.136.117.198"

# Function to update record
update_record() {
    NAME=$1
    echo "Updating $NAME to $IP..."
    
    # 1. Get Record ID
    REC_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$NAME" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
        
    if [ -z "$REC_ID" ]; then
        echo "  Record not found. Creating..."
        # Create
        curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"A\",\"name\":\"$NAME\",\"content\":\"$IP\",\"ttl\":1,\"proxied\":true}" > /dev/null
    else
        echo "  Updating Record ID: $REC_ID"
        # Update
        curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$REC_ID" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"A\",\"name\":\"$NAME\",\"content\":\"$IP\",\"ttl\":1,\"proxied\":true}" > /dev/null
    fi
}

update_record "jumpstartscaling.com"
update_record "www.jumpstartscaling.com"
update_record "api.jumpstartscaling.com"
update_record "n8n.jumpstartscaling.com"
update_record "cockpit.jumpstartscaling.com"

echo "✅ All critical DNS records forced to $IP"
