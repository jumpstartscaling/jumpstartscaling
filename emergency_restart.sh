#!/bin/bash
echo "🚑 EMERGENCY RESTART..."
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  # 1. Restart Next.js
  echo "Restarting Next.js..."
  cd ~/sites/jumpstartscaling
  pm2 delete next-jumpstart || true
  pm2 start npm --name "next-jumpstart" -- start -- -p 8100
  pm2 save
  
  # 2. Restart Nginx
  echo "Restarting Nginx..."
  sudo systemctl restart nginx
  
  # 3. Re-Flush Firewall (Just in case)
  echo "Flushing Firewall..."
  sudo iptables -F
  sudo iptables -P INPUT ACCEPT
  
  # 4. Check status
  echo "--- STATUS ---"
  curl -I http://127.0.0.1:8100
  curl -I http://127.0.0.1
EOF
