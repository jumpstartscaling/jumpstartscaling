#!/bin/bash
SERVER_IP="193.122.168.215"
SSH_KEY="~/.ssh/id_rsa"
USER="opc"

echo "🔧 Fixing Coolify Permissions on $SERVER_IP..."

ssh -o StrictHostKeyChecking=no -i $SSH_KEY $USER@$SERVER_IP << 'EOF'
  set -e
  
  echo "[1/3] Resetting ownership of /data/coolify..."
  # Coolify containers use user 9999
  sudo chown -R 9999:root /data/coolify
  
  echo "[2/3] Setting rigid permissions..."
  # Ensure group read/write/execute
  sudo chmod -R 775 /data/coolify
  
  # Fix specifically for n8n/services which often has issues
  if [ -d "/data/coolify/services" ]; then
      echo "Fixing services directory..."
      sudo chmod -R 777 /data/coolify/services
  fi

  echo "[3/3] Verifying..."
  ls -la /data/coolify/services | head -n 5
  
  echo "✅ Permissions Fixed. Please retry the deployment in Coolify Dashboard."
EOF
