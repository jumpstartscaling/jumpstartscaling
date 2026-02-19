#!/bin/bash

# Stream-Rec Deployment Script (Direct Access - No Cloudflare Tunnel)
# Deploys Stream-Rec to Oracle Cloud server at rec.jumpstartscaling.com

set -e  # Exit on error

echo "🚀 Stream-Rec Deployment Script"
echo "================================"
echo ""

# Configuration
SERVER="opc@193.122.168.215"
REMOTE_DIR="/home/opc/stream-rec"
LOCAL_DIR="./stream-rec"

echo "📦 Step 1: Syncing files to server..."
rsync -av --progress \
  --exclude 'downloads' \
  --exclude 'rclone' \
  --exclude '.git' \
  --exclude 'node_modules' \
  "$LOCAL_DIR/" "$SERVER:$REMOTE_DIR/"

echo ""
echo "✅ Files synced successfully!"
echo ""

echo "🔧 Step 2: Setting up on server..."
ssh "$SERVER" << 'ENDSSH'
  cd /home/opc/stream-rec
  
  # Create necessary directories
  echo "Creating directories..."
  mkdir -p downloads rclone
  
  # Check if Docker is installed
  if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed on the server!"
    echo "Please install Docker first:"
    echo "  curl -fsSL https://get.docker.com | sh"
    exit 1
  fi
  
  # Check if docker compose is available
  if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available!"
    exit 1
  fi
  
  echo "✅ Docker is ready"
  
  # Pull latest images
  echo "Pulling latest images..."
  docker compose pull
  
  # Start services
  echo "Starting services..."
  docker compose up -d
  
  # Wait a moment for services to start
  sleep 5
  
  # Show status
  echo ""
  echo "📊 Service Status:"
  docker compose ps
  
  echo ""
  echo "📝 Recent logs:"
  docker compose logs --tail=20
ENDSSH

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Install and configure Nginx (if not already done):"
echo "   ./stream-rec/setup-nginx.sh"
echo ""
echo "2. Configure SSL certificate with Let's Encrypt:"
echo "   ./stream-rec/setup-ssl.sh"
echo ""
echo "3. Add DNS A record in Cloudflare:"
echo "   Type: A"
echo "   Name: rec"
echo "   Target: 193.122.168.215"
echo "   Proxied: No (DNS only - gray cloud)"
echo ""
echo "4. Open firewall port 443 on Oracle Cloud"
echo ""
echo "5. Access Stream-Rec at:"
echo "   https://rec.jumpstartscaling.com"
echo ""
echo "🔍 To view logs:"
echo "   ssh opc@193.122.168.215"
echo "   cd /home/opc/stream-rec"
echo "   docker compose logs -f"
echo ""
