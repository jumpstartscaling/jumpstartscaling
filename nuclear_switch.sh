#!/bin/bash
set -e

echo "☢️ INITIATING NUCLEAR DEPLOYMENT..."
echo "==================================="

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  # 1. STOP EVERYTHING
  echo "--- 1. Killing Services ---"
  sudo systemctl stop cloudflared || true
  sudo systemctl disable cloudflared || true
  sudo systemctl stop nginx || true
  sudo systemctl stop apache2 || true
  sudo systemctl stop httpd || true
  
  # 2. KILL PROCESSES
  echo "--- 2. Killing Processes ---"
  sudo pkill -9 -f cloudflared || true
  sudo pkill -9 -f node || true
  sudo pkill -9 -f pm2 || true
  sudo fuser -k 80/tcp || true
  sudo fuser -k 443/tcp || true

  # 3. START NEXT.JS
  echo "--- 3. Starting Next.js (Port 8100) ---"
  cd ~/jumpstart-next
  # Ensure clean slate for PM2
  rm -rf ~/.pm2
  pm2 start npm --name jumpstart-next -- run dev -- --port 8100
  pm2 save
  
  # Wait for boot
  sleep 5
  curl -I http://localhost:8100

  # 4. CONFIGURE NGINX (Strict)
  echo "--- 4. overwriting Nginx Config ---"
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
    sendfile        off; # Disable caching
    keepalive_timeout  65;

    server {
        listen 80 default_server;
        server_name _;

        location / {
            proxy_pass http://127.0.0.1:8100;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }
    }
}
NGINX_CONF

  # 5. START NGINX configuration test
  echo "Testing Nginx Config..."
  sudo nginx -t

  echo "Starting Nginx..."
  sudo systemctl start nginx
  sudo systemctl enable nginx

  echo "✅ Nginx (Port 80) -> Next.js (Port 8100) ACTIVE"
  sudo netstat -tulpn | grep nginx
EOF
