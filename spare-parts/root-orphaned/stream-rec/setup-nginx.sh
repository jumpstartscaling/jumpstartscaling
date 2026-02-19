#!/bin/bash

# Stream-Rec Nginx Setup Script
# Installs and configures Nginx for Stream-Rec

set -e

echo "🔧 Stream-Rec Nginx Configuration"
echo "=================================="
echo ""

SERVER="opc@193.122.168.215"

echo "📝 Installing and configuring Nginx..."
echo ""

ssh "$SERVER" << 'ENDSSH'
  # Check if Nginx is installed
  if ! command -v nginx &> /dev/null; then
    echo "Installing Nginx..."
    sudo dnf install -y nginx
  else
    echo "✅ Nginx is already installed"
  fi
  
  # Enable and start Nginx
  echo "Enabling Nginx service..."
  sudo systemctl enable nginx
  sudo systemctl start nginx
  
  # Copy Nginx configuration
  echo "Installing Stream-Rec Nginx configuration..."
  sudo cp /home/opc/stream-rec/nginx-stream-rec.conf /etc/nginx/conf.d/stream-rec.conf
  
  # Test Nginx configuration
  echo "Testing Nginx configuration..."
  sudo nginx -t
  
  # Note: Don't reload yet - SSL certificates need to be installed first
  echo ""
  echo "⚠️  Nginx configuration installed but NOT reloaded yet"
  echo "You must install SSL certificates first (run setup-ssl.sh)"
  
ENDSSH

echo ""
echo "✅ Nginx configuration complete!"
echo ""
echo "📋 Next Step:"
echo "Run: ./stream-rec/setup-ssl.sh"
echo ""
