#!/bin/bash
set -e

echo "🔒 Engaging Universal Proxy Protocol..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  # 1. Aggressively cleanup potential zombie ports
  echo "Cleaning up conflicting ports..."
  sudo fuser -k 3000/tcp || true
  sudo fuser -k 4321/tcp || true
  sudo fuser -k 8080/tcp || true
  # Do NOT kill 8100 (Next.js) or 22 (SSH)

  # 2. Write Universal Nginx Config
  echo "Writing Universal Nginx Configuration..."
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
    
    # Disable caching for now to force updates
    sendfile        off;
    expires         off;

    server {
        # Listen on ALL common ports that the Tunnel might be pointing to
        listen 80 default_server;
        listen 8080;
        listen 3000;
        listen 4321;
        
        server_name _;

        location / {
            # Force traffic to Next.js on 8100
            proxy_pass http://127.0.0.1:8100;
            
            # Websocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
            
            # Kill cache headers
            add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0";
        }
    }
}
NGINX_CONF

  # 3. Restart Nginx to apply
  echo "Restarting Nginx..."
  sudo systemctl restart nginx
  
  # 4. Verify Listening Ports
  echo "Verifying active ports..."
  sudo netstat -tulpn | grep nginx
  
  echo "✅ Universal Catch-All Active. Ports 80, 3000, 4321, 8080 -> Next.js (8100)"
EOF
