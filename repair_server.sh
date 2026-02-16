#!/bin/bash
set -e

SERVER_IP="150.136.117.198"
SSH_KEY="~/.ssh/id_rsa"
REMOTE_DIR="~/jumpstart-next"

echo "🔧 Starting Server Repair..."
echo "---------------------------"

# Create a remote script to run on the server
cat > remote_fix.sh << 'EOF'
#!/bin/bash
source ~/.bashrc
export PATH=$PATH:/usr/local/bin

echo "1. Killing old processes..."
# Kill any process on port 8100
fuser -k 8100/tcp || true
# Stop all PM2
pm2 stop all || true
pm2 delete all || true
pm2 flush

echo "2. Checking directory..."
if [ ! -d "/home/opc/jumpstart-next" ]; then
    echo "❌ Directory /home/opc/jumpstart-next does not exist!"
    exit 1
fi
cd /home/opc/jumpstart-next

echo "3. Installing dependencies..."
npm install --no-audit --no-fund

echo "4. Starting Next.js..."
# Run dev mode on 0.0.0.0 to access from outside
pm2 start npm --name "jumpstart-next" -- run dev -- --port 8100 --hostname 0.0.0.0 --turbo
pm2 save

echo "5. Verifying..."
sleep 5
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8100)
echo "HTTP Status: $HTTP_CODE"

if [ "$HTTP_CODE" -eq "200" ]; then
    echo "✅ Success! Next.js is running."
    curl -s http://localhost:8100 | grep -o "<title>.*</title>"
else
    echo "❌ Failed to verify localhost:8100"
    pm2 logs --lines 20
    exit 1
fi
EOF

# Upload and run the script
echo "📤 Uploading fix script..."
scp -i $SSH_KEY remote_fix.sh opc@$SERVER_IP:~/remote_fix.sh

echo "🚀 Executing fix script on server..."
ssh -i $SSH_KEY opc@$SERVER_IP "chmod +x ~/remote_fix.sh && ~/remote_fix.sh"

echo "---------------------------"
echo "✅ Repair Complete."
rm remote_fix.sh
