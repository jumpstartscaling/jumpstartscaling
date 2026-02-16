#!/bin/bash

echo "Running server diagnostics..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 'bash -s' << 'ENDSSH' > server_diagnostic.log 2>&1

echo "=========================================="
echo "SERVER DIAGNOSTIC REPORT"
echo "Generated: $(date)"
echo "=========================================="
echo ""

echo "1. PM2 STATUS"
echo "-------------"
pm2 list
echo ""

echo "2. JUMPSTARTSCALING PM2 DETAILS"
echo "--------------------------------"
pm2 describe jumpstartscaling
echo ""

echo "3. ALL JUMPSTARTSCALING FOLDERS"
echo "--------------------------------"
find ~ -type d -name "*jumpstart*" 2>/dev/null
echo ""

echo "4. CHECKING ~/jumpstart-v3/"
echo "---------------------------"
if [ -d ~/jumpstart-v3 ]; then
  echo "✓ Folder exists"
  ls -lah ~/jumpstart-v3/ | head -20
else
  echo "✗ Folder does NOT exist"
fi
echo ""

echo "5. CHECKING ~/sites/jumpstartscaling/"
echo "--------------------------------------"
if [ -d ~/sites/jumpstartscaling ]; then
  echo "✓ Folder exists"
  ls -lah ~/sites/jumpstartscaling/ | head -20
else
  echo "✗ Folder does NOT exist"
fi
echo ""

echo "6. TESTING LOCALHOST:8100"
echo "-------------------------"
curl -s http://localhost:8100 | head -50
echo ""
echo "Checking for menu system in HTML:"
if curl -s http://localhost:8100 | grep -q "quick-nav-react"; then
  echo "✓ Menu system FOUND in served HTML"
else
  echo "✗ Menu system NOT found in served HTML"
fi
echo ""

echo "7. CLOUDFLARE TUNNEL CONFIG"
echo "---------------------------"
sudo cat /etc/cloudflared/config.yml 2>/dev/null || echo "Cannot read config"
echo ""

echo "8. PORTS LISTENING"
echo "------------------"
netstat -tulpn 2>/dev/null | grep LISTEN | grep -E "8100|8101" || ss -tulpn | grep LISTEN | grep -E "8100|8101"
echo ""

echo "=========================================="
echo "END OF DIAGNOSTIC REPORT"
echo "=========================================="

ENDSSH

cat server_diagnostic.log

echo ""
echo "Diagnostic saved to: server_diagnostic.log"
