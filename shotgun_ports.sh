#!/bin/bash
set -e

echo "🔫 CONFIGURING SHOTGUN LISTENER (ALL CF PORTS)..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  # 1. Update Nginx to listen on ALL Cloudflare Ports
  # HTTP: 80, 8080, 8880, 2052, 2082, 2086, 2095
  # HTTPS: 443, 8443, 2053, 2083, 2087, 2096
  
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

    # --- HTTP PORTS ---
    # Attempting to catch ANY open http port
    server {
        listen 80;
        listen 8080;
        listen 8880;
        listen 2052;
        listen 2082;
        listen 2086;
        listen 2095;
        
        server_name _;
        
        location / {
            proxy_pass http://127.0.0.1:8100;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
        }
    }

    # --- HTTPS PORTS ---
    # Using Self-Signed Cert for all these ports
    server {
        listen 443 ssl;
        listen 8443 ssl;
        listen 2053 ssl;
        listen 2083 ssl;
        listen 2087 ssl;
        listen 2096 ssl;
        
        server_name _;
        
        ssl_certificate /etc/nginx/ssl/nginx.crt;
        ssl_certificate_key /etc/nginx/ssl/nginx.key;
        
        location / {
            proxy_pass http://127.0.0.1:8100;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
        }
    }
}
NGINX_CONF

  # 2. Restart Nginx
  echo "Restarting Nginx..."
  sudo nginx -t
  sudo systemctl restart nginx
  
  # 3. Open ALL these ports in OS Firewall (just in case it was re-enabled)
  if command -v firewall-cmd &> /dev/null; then
      sudo firewall-cmd --permanent --add-port=8080/tcp
      sudo firewall-cmd --permanent --add-port=8880/tcp
      sudo firewall-cmd --permanent --add-port=8443/tcp
      sudo firewall-cmd --permanent --add-port=2052/tcp
      sudo firewall-cmd --permanent --add-port=2053/tcp
      sudo firewall-cmd --permanent --add-port=2082/tcp
      sudo firewall-cmd --permanent --add-port=2083/tcp
      sudo firewall-cmd --reload
  fi
  
  # 4. Flush IPtables again to be sure
  sudo iptables -I INPUT -p tcp --match multiport --dports 8080,8443,8880,2052,2053,2082,2083,2086,2087,2095,2096 -j ACCEPT
  
  echo "✅ Nginx is now listening on ALL Cloudflare-compatible ports."
EOF
