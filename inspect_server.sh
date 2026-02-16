#!/bin/bash
echo "🔍 Running Server Inspection..."
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
echo "--- HOSTNAME ---"
hostname
echo "--- PM2 LIST ---"
pm2 list
echo "--- LISTENING PORTS (sudo netstat) ---"
sudo netstat -tulpn | grep LISTEN
echo "--- PROCESSES (node) ---"
ps aux | grep node
echo "--- CLOUDFLARED CONFIG SEARCH ---"
find / -name config.yml 2>/dev/null | grep cloudflared
echo "--- CLOUDFLARED PROCESS ---"
ps aux | grep cloudflared
EOF
