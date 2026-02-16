#!/bin/bash
# Deploy the clean payload-v2 to the server

SERVER="opc@193.122.168.215"
REMOTE_DIR="/home/opc/payload-multitenant"
LOCAL_DIR="payload-v2"

echo "📦 Archiving clean build (excluding node_modules/.next)..."
tar -czf payload-clean.tar.gz --exclude='node_modules' --exclude='.next' -C "$LOCAL_DIR" .

echo "🚀 Uploading to server..."
scp -i ~/.ssh/id_rsa payload-clean.tar.gz $SERVER:/home/opc/

echo "🛠️  Deploying on server..."
ssh -i ~/.ssh/id_rsa $SERVER << 'EOF'
  echo "--- Stopping containers ---"
  # Try to stop existing container if running (ignoring errors)
  docker stop $(docker ps -q --filter "name=jumpstartscaling" --filter "name=dockerfile-") 2>/dev/null || true

  echo "--- Backing up old dir ---"
  mv /home/opc/payload-multitenant /home/opc/payload-multitenant-backup-$(date +%s) || true
  mkdir -p /home/opc/payload-multitenant

  echo "--- Extracting new code ---"
  tar -xzf /home/opc/payload-clean.tar.gz -C /home/opc/payload-multitenant
  rm /home/opc/payload-clean.tar.gz

  cd /home/opc/payload-multitenant

  echo "--- Installing dependencies ---"
  # Use --legacy-peer-deps to avoid conflicts as we did locally
  npm install --legacy-peer-deps

  echo "--- Building ---"
  npm run build

  echo "--- Done! ---"
  echo "You can now redeploy via Coolify UI or wait for auto-restart if configured."
EOF

echo "✅ Deployment script finished."
