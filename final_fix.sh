#!/bin/bash
echo "🛡️ FINAL FIREWALL PERSISTENCE & NGINX HEADER FIX..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  set -e
  
  # 1. Firewalld Persistence (The Oracle Linux Default)
  echo "[1/4] Configuring Firewalld Persistence..."
  if command -v firewall-cmd &> /dev/null; then
      sudo firewall-cmd --permanent --zone=public --add-service=http
      sudo firewall-cmd --permanent --zone=public --add-service=https
      sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
      sudo firewall-cmd --permanent --zone=public --add-port=443/tcp
      sudo firewall-cmd --reload
      echo "✅ Firewalld Updated."
  else
      echo "⚠️ Firewalld not present (Skipping)."
  fi

  # 2. IPtables Persistence (Kernel Level)
  echo "[2/4] Forcing IPtables Rules..."
  # Insert at top of chain to ensure priority
  sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
  sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
  
  # Try to save persistently
  if command -v netfilter-persistent &> /dev/null; then
      sudo netfilter-persistent save
  elif command -v service &> /dev/null; then
      sudo service iptables save || true
  fi
  echo "✅ IPtables Rules Applied."

  # 3. Nginx Headers Fix (For Dashboard/Factory Control)
  echo "[3/4] Updating Nginx Headers..."
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
        listen 80 default_server;
        server_name _;
        
        location / {
            proxy_pass http://127.0.0.1:8100;
            
            # CRITICAL HEADERS FOR DASHBOARD / FACTORY CONTROLS
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Websocket Support (Next.js HMR + Dashboard Realtime)
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
}
NGINX_CONF

  # 4. Restart & Verify
  echo "[4/4] Restarting Nginx & Checking Listeners..."
  sudo systemctl restart nginx
  
  echo "--- LISTENING PORTS (Should see *:80) ---"
  sudo ss -tulpn | grep :80
  
  echo "--- LOCAL CONNECTIVITY ---"
  curl -I http://127.0.0.1
EOF
