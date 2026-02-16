#!/bin/bash
SERVER_IP="193.122.168.215"
SSH_KEY="~/.ssh/id_rsa"
USER="opc"

echo "🔐 FORCE Securing SSH Keys on $SERVER_IP..."

ssh -o StrictHostKeyChecking=no -i $SSH_KEY $USER@$SERVER_IP << 'EOF'
  set -e
  
  echo "[1/3] Fixing Docker Permissions first..."
  # Allow opc to run docker commands without sudo issues
  sudo usermod -aG docker opc
  
  echo "[2/3] Locating and locking keys..."
  # Locate the specific file mentioned in the error
  # The path seen in the error "/var/www/html/..." is INSIDE the container
  # We need to find where it lives on the HOST
  
  # It's likely in /data/coolify/source/storage/app/ssh/keys
  # OR directly in /data/coolify/ssh
  
  TARGET_DIR="/data/coolify/source/storage/app/ssh/keys"
  
  if [ -d "$TARGET_DIR" ]; then
      echo " -> Found keys in $TARGET_DIR"
      sudo chmod 600 $TARGET_DIR/*
      sudo chown 9999:9999 $TARGET_DIR/*
  else
      echo " -> Keys not found in standard source path. Searching..."
      # Find any file starting with ssh_key@ in /data/coolify
      sudo find /data/coolify -name "ssh_key@*" -exec chmod 600 {} \;
      sudo find /data/coolify -name "ssh_key@*" -exec chown 9999:9999 {} \;
  fi

  echo "[3/3] Restarting Coolify Container..."
  sudo docker restart coolify
  
  echo "✅ Security Fix Applied."
EOF
