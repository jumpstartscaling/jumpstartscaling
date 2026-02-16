#!/bin/bash
# Comprehensive server diagnostic

REPORT="/tmp/server_status_report.txt"

exec > $REPORT 2>&1

echo "=========================================="
echo "SERVER DIAGNOSTIC REPORT"
echo "Generated: $(date)"
echo "=========================================="

echo ""
echo "1. CLOUDFLARE TUNNEL STATUS"
echo "------------------------------------------"
sudo systemctl status cloudflared --no-pager | head -10
ps aux | grep cloudflared | grep -v grep

echo ""
echo "2. DOCKER STATUS"
echo "------------------------------------------"
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "3. LISTENING PORTS"
echo "------------------------------------------"
sudo netstat -tlnp | grep -E "LISTEN"

echo ""
echo "4. APPLICATION STATUS"
echo "------------------------------------------"
echo "Next.js (8100):"
curl -I http://localhost:8100 2>&1 | head -5

echo ""
echo "n8n (5678):"
curl -I http://localhost:5678 2>&1 | head -5

echo ""
echo "Cockpit (9090):"
curl -I http://localhost:9090 2>&1 | head -5

echo ""
echo "5. PM2 PROCESSES"
echo "------------------------------------------"
pm2 list

echo ""
echo "6. COOLIFY STATUS"
echo "------------------------------------------"
if [ -d /data/coolify ]; then
    cd /data/coolify
    sudo docker-compose ps 2>/dev/null || echo "No docker-compose found"
else
    echo "Coolify directory not found at /data/coolify"
fi

echo ""
echo "=========================================="
echo "END OF REPORT"
echo "=========================================="
