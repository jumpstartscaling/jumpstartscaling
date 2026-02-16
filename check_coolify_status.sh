#!/bin/bash
echo "=== COOLIFY INSTALLATION STATUS ==="
echo ""

echo "1. Docker Status:"
docker --version || echo "Docker NOT installed"

echo ""
echo "2. Docker Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}" || echo "Cannot list containers"

echo ""
echo "3. Port 8000 Status:"
sudo netstat -tlnp | grep 8000 || echo "Port 8000 NOT listening"

echo ""
echo "4. Coolify Directory:"
ls -la /data/coolify 2>/dev/null || echo "/data/coolify does NOT exist"

echo ""
echo "5. If Coolify not installed, install now:"
if ! docker ps | grep -q coolify; then
    echo "Running Coolify installer..."
    curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
else
    echo "Coolify appears to be installed"
fi
