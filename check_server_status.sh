#!/bin/bash
echo "=== NGINX STATUS ==="
sudo systemctl status nginx --no-pager | head -10

echo ""
echo "=== PORT 80 LISTENER ==="
sudo netstat -tlnp | grep ":80 "

echo ""
echo "=== TESTING SITES LOCALLY ==="
echo "Next.js (8100):"
curl -I http://localhost:8100 2>&1 | head -3

echo ""
echo "Via Nginx (80) - jumpstartscaling.com:"
curl -I -H "Host: jumpstartscaling.com" http://localhost 2>&1 | head -3

echo ""
echo "Via Nginx (80) - n8n.jumpstartscaling.com:"
curl -I -H "Host: n8n.jumpstartscaling.com" http://localhost 2>&1 | head -3

echo ""
echo "=== PM2 APPS ==="
pm2 list | grep online

echo ""
echo "=== NGINX CONFIG TEST ==="
sudo nginx -t
