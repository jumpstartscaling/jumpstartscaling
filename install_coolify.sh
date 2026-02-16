#!/bin/bash
set -e

SERVER="opc@150.136.117.198"
SSH_KEY="~/.ssh/id_rsa"

echo "=========================================="
echo "COOLIFY INSTALLATION"
echo "=========================================="

echo ""
echo "Step 1: Installing Prerequisites"
echo "------------------------------------------"

ssh -i $SSH_KEY $SERVER << 'PREREQ'
set -e

echo "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | bash
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "Docker already installed"
fi

echo ""
echo "Verifying Docker installation..."
sudo docker --version

echo ""
echo "Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose already installed"
fi

docker-compose --version

echo ""
echo "Stopping conflicting services..."
# Stop services that might conflict with Coolify's ports
sudo systemctl stop nginx 2>/dev/null || true
sudo systemctl disable nginx 2>/dev/null || true
# Keep cloudflared stopped for now
sudo systemctl stop cloudflared 2>/dev/null || true
PREREQ

echo ""
echo "Step 2: Installing Coolify"
echo "------------------------------------------"

ssh -i $SSH_KEY $SERVER << 'INSTALL'
set -e

echo "Downloading and running Coolify installer..."
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash

echo ""
echo "Waiting for Coolify to start..."
sleep 15

echo ""
echo "Coolify installation complete!"
echo ""
echo "Access Coolify at: http://150.136.117.198:8000"
echo ""
INSTALL

echo ""
echo "Step 3: Checking Coolify Status"
echo "------------------------------------------"

ssh -i $SSH_KEY $SERVER << 'STATUS'
echo "Docker containers:"
sudo docker ps

echo ""
echo "Coolify service status:"
sudo systemctl status coolify 2>/dev/null || echo "Coolify not running as systemd service (may be docker-compose managed)"

echo ""
echo "Checking port 8000..."
sudo netstat -tlnp | grep 8000 || echo "Port 8000 not listening yet"
STATUS

echo ""
echo "=========================================="
echo "INSTALLATION COMPLETE"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Open http://150.136.117.198:8000 in your browser"
echo "2. Complete the initial setup wizard"
echo "3. Set up admin credentials"
echo "4. Configure your first project"
echo ""
echo "To access via domain, update DNS:"
echo "  coolify.jumpstartscaling.com → 150.136.117.198"
echo ""
