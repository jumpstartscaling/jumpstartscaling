#!/bin/bash
set -e

echo "🧹 RESETTING SERVER TO STANDARD CONFIGURATION..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  # 1. Clean Nginx Config (Standard Port 80 Only - Best for Cloudflare Flexible)
  echo "Restoring standard nginx.conf..."
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

    # PRIMARY SERVER (Port 80)
    server {
        listen 80 default_server;
        server_name _;
        
        # Proxy to Next.js running on 8100
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

  # 2. Restart Nginx
  echo "Restarting Nginx..."
  sudo systemctl restart nginx
  
  # 3. Ensure Next.js is running
  echo "Checking Next.js..."
  pm2 list
  # If not running, start it
  if ! pm2 list | grep -q "next-jumpstart"; then
      cd ~/sites/jumpstartscaling
      pm2 start npm --name "next-jumpstart" -- start -- -p 8100
  fi
  
  # 4. Clean Firewalls (Ensuring 80 is OPEN)
  echo "Verifying Firewall..."
  # Just to be safe, ensure IPtables accepts Port 80
  sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
  
  # 5. Verification
  echo "--- LOCAL STATUS (Port 80) ---"
  curl -I http://127.0.0.1
  echo "--- APP STATUS (Port 8100) ---"
  curl -I http://127.0.0.1:8100
EOF
