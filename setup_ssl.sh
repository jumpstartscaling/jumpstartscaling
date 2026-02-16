#!/bin/bash
# Setup Let's Encrypt SSL certificates for Oracle Linux

set -e

echo "🔐 Step 1: Installing Certbot for Oracle Linux..."
# Enable EPEL repository
sudo dnf install -y epel-release
sudo dnf install -y certbot

echo "🔐 Step 2: Installing Nginx plugin..."
sudo dnf install -y python3-certbot-nginx || echo "Nginx plugin not available, will use manual mode"

echo "📧 Step 3: Obtaining SSL certificates..."
# Get certificates for all domains
sudo certbot certonly --webroot -w /home/opc/sites/jumpstartscaling/dist \
  -d jumpstartscaling.com \
  -d www.jumpstartscaling.com \
  --email admin@jumpstartscaling.com \
  --agree-tos \
  --non-interactive || {
  echo "Webroot failed, trying standalone..."
  sudo systemctl stop nginx
  sudo certbot certonly --standalone \
    -d jumpstartscaling.com \
    -d www.jumpstartscaling.com \
    -d chrisamaya.work \
    -d www.chrisamaya.work \
    -d n8n.jumpstartscaling.com \
    --email admin@jumpstartscaling.com \
    --agree-tos \
    --non-interactive
  sudo systemctl start nginx
}

echo "⚙️  Step 4: Updating Nginx configuration for SSL..."
sudo tee /etc/nginx/conf.d/multisite.conf > /dev/null <<'EOF'
# JumpStart Scaling - HTTP to HTTPS redirect
server {
    listen 80;
    server_name jumpstartscaling.com www.jumpstartscaling.com;
    return 301 https://$server_name$request_uri;
}

# JumpStart Scaling - HTTPS
server {
    listen 443 ssl http2;
    server_name jumpstartscaling.com www.jumpstartscaling.com;
    
    ssl_certificate /etc/letsencrypt/live/jumpstartscaling.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/jumpstartscaling.com/privkey.pem;
    
    location / {
        proxy_pass http://localhost:8100;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Chris Amaya - HTTP to HTTPS redirect
server {
    listen 80;
    server_name chrisamaya.work www.chrisamaya.work;
    return 301 https://$server_name$request_uri;
}

# Chris Amaya - HTTPS
server {
    listen 443 ssl http2;
    server_name chrisamaya.work www.chrisamaya.work;
    
    ssl_certificate /etc/letsencrypt/live/chrisamaya.work/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/chrisamaya.work/privkey.pem;
    
    location / {
        proxy_pass http://localhost:8100;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# n8n - HTTP to HTTPS redirect
server {
    listen 80;
    server_name n8n.jumpstartscaling.com;
    return 301 https://$server_name$request_uri;
}

# n8n - HTTPS
server {
    listen 443 ssl http2;
    server_name n8n.jumpstartscaling.com;
    
    ssl_certificate /etc/letsencrypt/live/n8n.jumpstartscaling.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/n8n.jumpstartscaling.com/privkey.pem;
    
    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Connection '';
        proxy_http_version 1.1;
        chunked_transfer_encoding off;
        proxy_buffering off;
        proxy_cache off;
    }
}
EOF

echo "🔒 Step 5: Adding SSL security settings..."
sudo tee /etc/nginx/conf.d/ssl-params.conf > /dev/null <<'EOF'
# SSL Security Settings
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;

# Security headers for SEO
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options SAMEORIGIN always;
add_header X-Content-Type-Options nosniff always;
add_header X-XSS-Protection "1; mode=block" always;
EOF

echo "🔄 Step 6: Testing and reloading Nginx..."
sudo nginx -t && sudo systemctl reload nginx

echo "🔄 Step 7: Setting up auto-renewal..."
# Create systemd timer for renewal
sudo tee /etc/systemd/system/certbot-renewal.service > /dev/null <<'EOF'
[Unit]
Description=Certbot Renewal

[Service]
Type=oneshot
ExecStart=/usr/bin/certbot renew --quiet --post-hook "systemctl reload nginx"
EOF

sudo tee /etc/systemd/system/certbot-renewal.timer > /dev/null <<'EOF'
[Unit]
Description=Run Certbot renewal daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable certbot-renewal.timer
sudo systemctl start certbot-renewal.timer

echo "✅ SSL Setup Complete!"
echo ""
echo "🔒 HTTPS Sites:"
echo "   https://jumpstartscaling.com"
echo "   https://www.jumpstartscaling.com"
echo "   https://chrisamaya.work"
echo "   https://www.chrisamaya.work"
echo "   https://n8n.jumpstartscaling.com"
echo ""
echo "🔄 Auto-renewal: Enabled (systemd timer)"
echo "📊 SEO Benefits:"
echo "   ✓ HTTPS ranking boost"
echo "   ✓ Browser trust indicators"
echo "   ✓ Secure connection badge"
echo "   ✓ HSTS enabled"
