#!/bin/bash
set -e

# Configuration
LOCAL_DIR="/Users/christopheramaya/Downloads/spark/god-mode/sites/jumpstartscaling-next"
REMOTE_USER="opc"
REMOTE_IP="193.122.168.215"
SSH_KEY="~/.ssh/id_rsa"
REMOTE_DEST="/home/opc/jumpstart-next"

echo "🚀 Starting Deployment Pulse..."

# 1. Prepare Local Archive
echo "[1/5] Compressing source files..."
cd "$LOCAL_DIR"
# Exclude node_modules and .next to save bandwidth/time
tar -czf ../jumpstart-next.tar.gz --exclude='node_modules' --exclude='.next' .
cd ..

# 2. Upload
echo "[2/5] Uploading to server (Velocity Transport)..."
scp -i $SSH_KEY jumpstart-next.tar.gz $REMOTE_USER@$REMOTE_IP:~/jumpstart-next.tar.gz

# 3. Remote Execution
echo "[3/5] Executing remote build protocol..."
ssh -i $SSH_KEY $REMOTE_USER@$REMOTE_IP << 'EOF'
    set -e
    
    # ENSURE NODE IS INSTALLED
    if ! command -v npm &> /dev/null; then
        echo " -> npm not found. Installing Node.js 20 (RPM)..."
        curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
        sudo yum install -y nodejs
    else
        echo " -> npm found."
    fi
    
    # ENSURE PM2 IS INSTALLED
    if ! command -v pm2 &> /dev/null; then
        echo " -> pm2 not found. Installing global pm2..."
        sudo npm install -g pm2
    fi

    # Setup Directory - HARD RESET
    echo " -> [RESET] Wiping old artifacts to force clean deploy..."
    rm -rf ~/jumpstart-next
    mkdir -p ~/jumpstart-next
    
    # Extract
    echo " -> Extracting payload..."
    tar -xzf ~/jumpstart-next.tar.gz -C ~/jumpstart-next
    
    # Production Build
    echo " -> Building production bundle (This fixes CSS)..."
    cd ~/jumpstart-next
    npm install --no-audit --no-fund --silent
    npm run build
    
    # Restart Process
    echo " -> Restarting Jumpstart Engine..."
    # Ensure PM2 is running the right command
    pm2 delete jumpstart-next || true
    # Nuke next cache just in case
    rm -rf .next/cache
    pm2 start npm --name "jumpstart-next" -- start -- --port 8100 --hostname 0.0.0.0
    pm2 save
    
    # Cleanup
    rm ~/jumpstart-next.tar.gz
EOF

# 4. Cleanup Local
rm jumpstart-next.tar.gz

echo "✅ DEPLOYMENT COMPLETE. System Live."
