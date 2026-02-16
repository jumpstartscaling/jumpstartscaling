#!/bin/bash
set -e

echo "🔐 ENABLING SSL (PORT 443) FOR COMPATIBILITY..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  # 1. Generate Self-Signed Cert (valid for 365 days)
  echo "Generating Self-Signed Certificate..."
  sudo mkdir -p /etc/nginx/ssl
  sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=jumpstartscaling.com"

  # 2. Update Nginx Config to listen on BOTH 80 and 443
  echo "Updating Nginx Configuration..."
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
    access_log  /var/log/nginx/access.log;
    sendfile        on;
    keepalive_timeout  65;

    # --- HTTP (Port 80) ---
    server {
        listen 80 default_server;
        server_name _;
        
        location / {
            proxy_pass http://127.0.0.1:8100;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
        }
    }

    # --- HTTPS (Port 443) ---
    server {
        listen 443 ssl http2 default_server;
        server_name _;
        
        ssl_certificate /etc/nginx/ssl/nginx.crt;
        ssl_certificate_key /etc/nginx/ssl/nginx.key;
        
        location / {
            proxy_pass http://127.0.0.1:8100;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
        }
    }
}
NGINX_CONF

  # 3. Restart Nginx
  echo "Restarting Nginx..."
  sudo nginx -t
  sudo systemctl restart nginx
  
  # 4. Verify Listening Ports
  echo "Verifying Ports..."
  sudo netstat -tulpn | grep nginx
EOF
