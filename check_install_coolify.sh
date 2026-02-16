#!/bin/bash
echo "=== CHECKING COOLIFY INSTALLATION ==="
echo ""

echo "1. Docker containers:"
sudo docker ps -a | grep -i coolify || echo "No Coolify containers found"

echo ""
echo "2. Coolify directory:"
ls -la /data/coolify 2>/dev/null || echo "/data/coolify not found"

echo ""
echo "3. Port 8000 (Coolify UI):"
sudo netstat -tlnp | grep 8000 || echo "Port 8000 not listening"

echo ""
echo "4. All Docker containers:"
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "5. Installing Coolify if not present..."
if ! sudo docker ps | grep -q coolify; then
    echo "Running Coolify installer..."
    curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
    sleep 15
    echo "Installation attempt complete"
    sudo docker ps | grep coolify || echo "Still no Coolify containers"
else
    echo "Coolify appears to be running"
fi
