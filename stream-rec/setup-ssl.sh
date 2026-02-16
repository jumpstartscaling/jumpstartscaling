#!/bin/bash

# Stream-Rec SSL Setup Script
# Installs Let's Encrypt SSL certificate for rec.jumpstartscaling.com
# OR helps configure existing wildcard certificate

set -e

echo "🔐 Stream-Rec SSL Certificate Setup"
echo "===================================="
echo ""

SERVER="opc@193.122.168.215"

echo "Do you have an existing wildcard SSL certificate for *.jumpstartscaling.com?"
echo ""
echo "1) Yes - I have a wildcard certificate"
echo "2) No - Get a new Let's Encrypt certificate for rec.jumpstartscaling.com"
echo ""
read -p "Choose (1 or 2): " choice

if [ "$choice" = "1" ]; then
  echo ""
  echo "📋 Using existing wildcard certificate"
  echo ""
  echo "Please provide the paths to your wildcard certificate files on the server:"
  read -p "Path to fullchain.pem: " cert_path
  read -p "Path to privkey.pem: " key_path
  
  echo ""
  echo "Updating Nginx configuration with your certificate paths..."
  
  ssh "$SERVER" << ENDSSH
    # Update Nginx configuration with wildcard certificate paths
    sudo sed -i "s|/etc/letsencrypt/live/rec.jumpstartscaling.com/fullchain.pem|${cert_path}|g" /etc/nginx/conf.d/stream-rec.conf
    sudo sed -i "s|/etc/letsencrypt/live/rec.jumpstartscaling.com/privkey.pem|${key_path}|g" /etc/nginx/conf.d/stream-rec.conf
    
    # Test configuration
    echo "Testing Nginx configuration..."
    sudo nginx -t
    
    # Reload Nginx
    echo "Reloading Nginx..."
    sudo systemctl reload nginx
    
    echo ""
    echo "✅ Nginx configured with wildcard certificate!"
ENDSSH
  
  echo ""
  echo "✅ SSL setup complete with wildcard certificate!"
  
else
  echo ""
  echo "⚠️  IMPORTANT PREREQUISITES:"
  echo ""
  echo "1. DNS must resolve rec.jumpstartscaling.com → 193.122.168.215"
  echo "   (Should work automatically with wildcard subdomain)"
  echo ""
  echo "2. Oracle Cloud firewall must allow:"
  echo "   - Port 80 (HTTP)"
  echo "   - Port 443 (HTTPS)"
  echo ""
  echo "3. Nginx must be installed (run setup-nginx.sh first)"
  echo ""
  read -p "Have you completed these prerequisites? (yes/no): " confirm
  
  if [ "$confirm" != "yes" ]; then
    echo "Please complete prerequisites first"
    exit 1
  fi
  
  echo ""
  echo "📝 Installing Certbot and obtaining SSL certificate..."
  echo ""
  
  ssh "$SERVER" << 'ENDSSH'
    # Install Certbot
    if ! command -v certbot &> /dev/null; then
      echo "Installing Certbot..."
      sudo dnf install -y certbot python3-certbot-nginx
    else
      echo "✅ Certbot is already installed"
    fi
    
    # Temporarily modify Nginx config for certificate acquisition
    echo "Creating temporary Nginx config for certificate acquisition..."
    sudo tee /etc/nginx/conf.d/stream-rec-temp.conf > /dev/null << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name rec.jumpstartscaling.com;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 200 'Temporary - Setting up SSL';
        add_header Content-Type text/plain;
    }
}
EOF
    
    # Remove the main config temporarily
    sudo mv /etc/nginx/conf.d/stream-rec.conf /etc/nginx/conf.d/stream-rec.conf.disabled
    
    # Test and reload Nginx
    sudo nginx -t
    sudo systemctl reload nginx
    
    # Obtain SSL certificate
    echo ""
    echo "Obtaining SSL certificate from Let's Encrypt..."
    sudo certbot certonly --webroot \
      -w /var/www/html \
      -d rec.jumpstartscaling.com \
      --non-interactive \
      --agree-tos \
      --email admin@jumpstartscaling.com \
      || {
        echo "❌ Certificate acquisition failed!"
        echo "Check DNS configuration and firewall rules"
        exit 1
      }
    
    # Restore the main Nginx config
    echo "Restoring main Nginx configuration..."
    sudo mv /etc/nginx/conf.d/stream-rec.conf.disabled /etc/nginx/conf.d/stream-rec.conf
    sudo rm /etc/nginx/conf.d/stream-rec-temp.conf
    
    # Test configuration
    echo "Testing Nginx configuration with SSL..."
    sudo nginx -t
    
    # Reload Nginx
    echo "Reloading Nginx..."
    sudo systemctl reload nginx
    
    # Set up auto-renewal
    echo "Setting up automatic certificate renewal..."
    sudo systemctl enable certbot-renew.timer
    sudo systemctl start certbot-renew.timer
    
    echo ""
    echo "✅ SSL certificate installed and configured!"
    echo ""
    echo "Certificate details:"
    sudo certbot certificates
ENDSSH
  
  echo ""
  echo "✅ Let's Encrypt SSL setup complete!"
fi

echo ""
echo "📋 Final Steps:"
echo ""
echo "1. Verify HTTPS is working:"
echo "   Visit: https://rec.jumpstartscaling.com"
echo ""
echo "2. Check SSL certificate in browser"
echo ""
echo "✨ Stream-Rec should now be accessible at:"
echo "   https://rec.jumpstartscaling.com"
echo ""
