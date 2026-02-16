#!/bin/bash
echo "🚀 APPLYING USER TROUBLESHOOTING GUIDE..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  set -e
  
  # 1. ATTEMPT TO GET COMPARTMENT ID (For OCI Script)
  echo "--- FETCHING COMPARTMENT ID ---"
  # Try Instance Metadata Service v2
  COMPARTMENT_ID=$(curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/compartmentId)
  
  if [ -n "$COMPARTMENT_ID" ] && [[ "$COMPARTMENT_ID" != *"404"* ]]; then
      echo "✅ FOUND ID: $COMPARTMENT_ID"
      
      # Now try to run the OCI Script
      if command -v oci &> /dev/null; then
          echo "Running OCI Security List Update..."
          # Get Sec List
          SEC_LIST_ID=$(oci network security-list list --compartment-id $COMPARTMENT_ID --query "data[0].id" --raw-output 2>/dev/null || true)
          
          if [ -n "$SEC_LIST_ID" ]; then
              echo "✅ Found Security List: $SEC_LIST_ID"
              # Update
              oci network security-list update --security-list-id $SEC_LIST_ID \
              --ingress-security-rules '[{
                  "source": "0.0.0.0/0",
                  "protocol": "6",
                  "isStateless": false,
                  "tcpOptions": { "destinationPortRange": { "max": 80, "min": 80 } },
                  "description": "Allow HTTP for Cloudflare Jumpstart"
              }]' --force || echo "⚠️ OCI Update Failed (Permission?)"
          else
              echo "⚠️ Could not list Security Lists (Check OCI Permissions)"
          fi
      else
          echo "⚠️ OCI CLI not installed."
      fi
  else
      echo "⚠️ Could not retrieve Compartment ID from Metadata."
  fi

  # 2. APPLY NGINX CONFIG (With Factory Dashboard Timeouts)
  echo "--- UPDATING NGINX CONFIG ---"
  sudo tee /etc/nginx/nginx.conf > /dev/null << 'NGINX_CONF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen 80;
        server_name jumpstartscaling.com www.jumpstartscaling.com _;

        location / {
            proxy_pass http://127.0.0.1:8100;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Factory Dashboard optimization
            proxy_read_timeout 300;
            proxy_connect_timeout 300;
            proxy_send_timeout 300;
        }
    }
}
NGINX_CONF
  
  # 3. RESTART NGINX
  echo "Restarting Nginx..."
  sudo nginx -t
  sudo systemctl restart nginx
  
  # 4. FINAL VERIFICATION
  echo "--- VERIFICATION ---"
  sudo ss -tulpn | grep :80
  curl -I http://127.0.0.1
EOF
