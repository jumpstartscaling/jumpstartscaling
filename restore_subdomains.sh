#!/bin/bash
echo "🚦 RESTORING SUBDOMAIN ROUTING..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
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
    
    # Common Proxy Headers
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    # --- 1. COCKPIT (Port 9090) ---
    server {
        listen 80;
        server_name cockpit.jumpstartscaling.com;
        
        location / {
            proxy_pass http://127.0.0.1:9090;
            proxy_buffering off;
        }
    }

    # --- 2. N8N (Port 5678) ---
    server {
        listen 80;
        server_name n8n.jumpstartscaling.com;
        
        location / {
            proxy_pass http://127.0.0.1:5678;
            proxy_buffering off;
        }
    }
    
    # --- 3. MAIN SITE + CATCH ALL (Port 8100) ---
    server {
        listen 80 default_server;
        server_name jumpstartscaling.com www.jumpstartscaling.com _;
        
        location / {
            proxy_pass http://127.0.0.1:8100;
        }
    }
}
NGINX_CONF

  # Restart to Apply
  echo "Restarting Nginx..."
  sudo nginx -t
  sudo systemctl restart nginx
  
  echo "✅ Subdomain routing restored."
EOF
