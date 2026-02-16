#!/bin/bash
set -e

echo "🔄 Configuring Nginx Proxy (Port 80 -> 8100)..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  # 1. Install Nginx if missing
  if ! command -v nginx &> /dev/null; then
    echo "Installing Nginx..."
    sudo yum install -y nginx || sudo apt-get install -y nginx
  fi

  # 2. Backup existing config
  sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak 2>/dev/null || true

  # 3. Write new Proxy Config
  echo "Writing proxy configuration..."
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

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    keepalive_timeout  65;

    server {
        listen 80 default_server;
        listen [::]:80 default_server;
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
}
NGINX_CONF

  # 4. Restart Nginx
  echo "Restarting Nginx..."
  sudo systemctl enable nginx
  sudo systemctl restart nginx
  
  echo "✅ Nginx is now proxying Port 80 to Port 8100"
EOF
