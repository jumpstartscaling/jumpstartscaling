#!/bin/bash
set -e

echo "🔌 Switching to Direct Nginx Architecture..."
echo "=============================================="

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  # 1. Stop and Disable Cloudflare Tunnel
  echo "--- 1. Disabling Cloudflare Tunnel ---"
  sudo systemctl stop cloudflared || true
  sudo systemctl disable cloudflared || true
  # Kill any lingering processes
  sudo pkill -f cloudflared || true
  echo "✅ Cloudflare Tunnel Disabled"

  # 2. Configure Nginx for Production (Standard Port 80)
  echo "--- 2. Configuring Nginx (Port 80 -> 8100) ---"
  
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
    
    # Logs
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    keepalive_timeout  65;

    # Production Server Block
    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name jumpstartscaling.com www.jumpstartscaling.com _;

        # Security Headers
        add_header X-Frame-Options "SAMEORIGIN";
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Content-Type-Options "nosniff";

        location / {
            proxy_pass http://127.0.0.1:8100;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
            
            # Forward real IP from Cloudflare
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
NGINX_CONF

  # 3. Restart Nginx
  echo "Restarting Nginx..."
  sudo systemctl restart nginx
  
  # 4. Verify Firewall (Ensure Port 80 is open)
  echo "Checking Firewall..."
  # Try to open port 80 if using firewalld (common on Oracle Linux)
  if command -v firewall-cmd &> /dev/null; then
    sudo firewall-cmd --permanent --add-service=http || true
    sudo firewall-cmd --reload || true
  fi
  # Try to open port 80 if using ufw (Ubuntu)
  if command -v ufw &> /dev/null; then
    sudo ufw allow 80/tcp || true
  fi

  # 5. Output Public IP
  PUBLIC_IP=$(curl -s ifconfig.me)
  echo ""
  echo "✅ Nginx Active on Port 80"
  echo "🌍 IMPORTANT: Update your DNS A Record for '@' to: $PUBLIC_IP"
EOF
