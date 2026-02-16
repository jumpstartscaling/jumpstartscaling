#!/bin/bash
echo "🔧 FORCING NGINX UP..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  # 1. Stop Nginx
  sudo systemctl stop nginx
  
  # 2. Kill anything on port 80
  sudo fuser -k 80/tcp || true
  
  # 3. Check config
  sudo nginx -t
  
  # 4. Start Nginx
  sudo systemctl start nginx
  sudo systemctl enable nginx
  
  # 5. Check Netstat (Verify 0.0.0.0:80)
  echo "--- NETSTAT ---"
  sudo netstat -tulpn | grep nginx
  
  # 6. Check localhost
  curl -I http://127.0.0.1
EOF
