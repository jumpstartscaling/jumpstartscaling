#!/bin/bash
set -e

echo "Installing Coolify..."
echo ""

# Stop cloudflare tunnel to free up resources
sudo systemctl stop cloudflared 2>/dev/null || true

# Run official Coolify installer
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash

echo ""
echo "Waiting for Coolify to start..."
sleep 20

echo ""
echo "Checking installation..."
sudo docker ps | grep coolify || echo "Coolify containers not found"

echo ""
echo "Checking port 8000..."
sudo netstat -tlnp | grep 8000 || echo "Port 8000 not listening"

echo ""
echo "Installation complete!"
echo "Access Coolify at: http://150.136.117.198:8000"
