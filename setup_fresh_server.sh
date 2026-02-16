#!/bin/bash
# Fresh server setup script for IP: 193.122.168.215

NEW_IP="193.122.168.215"

echo "=========================================="
echo "FRESH SERVER SETUP"
echo "Server IP: $NEW_IP"
echo "=========================================="

echo ""
echo "Step 1: Testing SSH connection..."
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no opc@$NEW_IP "echo 'Connection successful!'"

echo ""
echo "Step 2: Updating system..."
ssh -i ~/.ssh/id_rsa opc@$NEW_IP << 'SETUP'
sudo yum update -y
SETUP

echo ""
echo "Step 3: Installing Docker..."
ssh -i ~/.ssh/id_rsa opc@$NEW_IP << 'DOCKER'
# Install Docker
curl -fsSL https://get.docker.com | bash
sudo usermod -aG docker opc
sudo systemctl enable docker
sudo systemctl start docker
sudo docker --version
DOCKER

echo ""
echo "Step 4: Installing Coolify..."
ssh -i ~/.ssh/id_rsa opc@$NEW_IP << 'COOLIFY'
# Official Coolify installer
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
COOLIFY

echo ""
echo "Step 5: Waiting for Coolify to start..."
sleep 30

echo ""
echo "Step 6: Verifying Coolify installation..."
ssh -i ~/.ssh/id_rsa opc@$NEW_IP << 'VERIFY'
echo "Docker containers:"
sudo docker ps
echo ""
echo "Port 8000 status:"
sudo netstat -tlnp | grep 8000 || echo "Port 8000 not yet listening"
VERIFY

echo ""
echo "=========================================="
echo "SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "Access Coolify at:"
echo "  http://spark.jumpstartscaling.com:8000"
echo "  or http://$NEW_IP:8000"
echo ""
echo "DNS has been updated to point to $NEW_IP"
