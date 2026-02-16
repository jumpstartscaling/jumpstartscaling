#!/bin/bash
SERVER_IP="193.122.168.215"
SSH_KEY="~/.ssh/id_rsa"
USER="opc"

echo "🔐 Securing Coolify SSH Keys on $SERVER_IP..."

ssh -o StrictHostKeyChecking=no -i $SSH_KEY $USER@$SERVER_IP << 'EOF'
  set -e
  
  APP_DIR="/data/coolify/source"
  KEY_DIR="$APP_DIR/storage/app/ssh/keys"
  
  if [ -d "$KEY_DIR" ]; then
      echo "✅ Found SSH Keys Directory: $KEY_DIR"
      
      echo "[1/2] Locking down permissions (600)..."
      # Private keys must be read/write ONLY by the owner (Coolify user 9999)
      sudo chmod 600 $KEY_DIR/*
      
      echo "[2/2] Ensuring correct ownership..."
      sudo chown 9999:9999 $KEY_DIR/*
      
      echo "✅ Keys secured."
      ls -la $KEY_DIR | head -n 5
  else
      # Check alternative path if running via Docker volume mapping
      echo "⚠️ Standard path not found, searching in Docker volumes..."
      
      # This is the path inside the container, mapped to /data/coolify/ssh/keys usually
      # or /data/coolify/source/storage/app/ssh/keys
      
      # Simply fix ALL potential key files recursively
      echo "Scanning /data/coolify for any SSH key-like files..."
      sudo find /data/coolify -type f -name "id_rsa" -exec chmod 600 {} \;
      sudo find /data/coolify -type f -name "ssh_key*" -exec chmod 600 {} \;
      sudo find /data/coolify -type f -name "ssh_key*" -exec chown 9999:9999 {} \;
      
      echo "✅ Global key fix applied."
  fi
  
  echo "♻️ Restarting Coolify to reload keys..."
  docker restart coolify
EOF
