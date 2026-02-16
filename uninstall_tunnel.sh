#!/bin/bash
set -e

echo "🧹 UNINSTALLING CLOUDFLARE TUNNEL..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  # 1. Stop and Disable Service
  echo "Stopping cloudflared service..."
  sudo systemctl stop cloudflared || true
  sudo systemctl disable cloudflared || true
  
  # 2. Remove Service File
  echo "Removing service files..."
  sudo rm -f /etc/systemd/system/cloudflared.service
  sudo rm -f /etc/systemd/system/cloudflared.service.wants/*
  sudo systemctl daemon-reload
  
  # 3. Kill any rogue processes
  echo "Killing process..."
  sudo pkill -9 cloudflared || true
  
  # 4. Remove Binary and Config
  echo "Removing binary and config..."
  sudo rm -rf /usr/local/bin/cloudflared
  sudo rm -rf /etc/cloudflared
  sudo rm -rf ~/.cloudflared
  
  echo "✅ Cloudflare Tunnel is GONE."
  
  # 5. DIAGNOSE 523 (Origin Unreachable)
  # Ensure Nginx is binding to 0.0.0.0, NOT 127.0.0.1
  echo "--- Checking Nginx Binding ---"
  sudo netstat -tulpn | grep nginx
  
  # 6. Verify Public IP again
  echo "--- Public IP ---"
  curl -s ifconfig.me
EOF
