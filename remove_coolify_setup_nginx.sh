#!/bin/bash
# Remove Coolify and setup pure Nginx + PM2 architecture

set -e

echo "🧹 Step 1: Stopping Coolify containers..."
docker stop coolify coolify-proxy coolify-db coolify-redis coolify-realtime coolify-sentinel 2>/dev/null || true

echo "🗑️  Step 2: Removing Coolify containers..."
docker rm coolify coolify-proxy coolify-db coolify-redis coolify-realtime coolify-sentinel 2>/dev/null || true

echo "🗑️  Step 3: Removing Coolify-deployed apps (keeping standalone n8n)..."
docker stop payload-cms-fixed 2>/dev/null || true
docker rm payload-cms-fixed 2>/dev/null || true
docker stop ksgwgg0kg08o000s80wcgkks-013644315692 2>/dev/null || true
docker rm ksgwgg0kg08o000s80wcgkks-013644315692 2>/dev/null || true
docker stop vvveb-ucc0so8goso8ock8wggwo08w mariadb-ucc0so8goso8ock8wggwo08w 2>/dev/null || true
docker rm vvveb-ucc0so8goso8ock8wggwo08w mariadb-ucc0so8goso8ock8wggwo08w 2>/dev/null || true

echo "🗑️  Step 4: Removing Coolify n8n (keeping standalone)..."
docker stop n8n-wwgg8ggw00w0s0sow0ogooww n8n-worker-wwgg8ggw00w0s0sow0ogooww 2>/dev/null || true
docker rm n8n-wwgg8ggw00w0s0sow0ogooww n8n-worker-wwgg8ggw00w0s0sow0ogooww 2>/dev/null || true
docker stop postgresql-wwgg8ggw00w0s0sow0ogooww redis-wwgg8ggw00w0s0sow0ogooww 2>/dev/null || true
docker rm postgresql-wwgg8ggw00w0s0sow0ogooww redis-wwgg8ggw00w0s0sow0ogooww 2>/dev/null || true

echo "📦 Step 5: Installing Nginx..."
sudo yum install -y nginx || sudo apt-get install -y nginx

echo "⚙️  Step 6: Creating Nginx config for multi-site..."
sudo tee /etc/nginx/conf.d/multisite.conf > /dev/null <<'EOF'
# JumpStart Scaling
server {
    listen 80;
    server_name jumpstartscaling.com www.jumpstartscaling.com;
    
    location / {
        proxy_pass http://localhost:8100;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Chris Amaya
server {
    listen 80;
    server_name chrisamaya.work www.chrisamaya.work;
    
    location / {
        proxy_pass http://localhost:8100;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Standalone n8n (already running on port 5678)
server {
    listen 80;
    server_name n8n.jumpstartscaling.com;
    
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

echo "🔄 Step 7: Testing Nginx config..."
sudo nginx -t

echo "🚀 Step 8: Starting/Restarting Nginx..."
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "🔄 Step 9: Fixing multisite-router..."
cd /home/opc/sites
pm2 delete multisite-router 2>/dev/null || true
pm2 start router.js --name multisite-router
pm2 save

echo "🧹 Step 10: Cleanup old PM2 apps..."
pm2 delete jumpstart-next 2>/dev/null || true
pm2 save

echo "✅ Coolify removed! Architecture now:"
echo "   - Nginx: Reverse proxy on port 80/443"
echo "   - multisite-router: Serves Astro sites on port 8100"
echo "   - n8n: Standalone on port 5678"
echo ""
echo "📍 Sites:"
echo "   http://jumpstartscaling.com"
echo "   http://chrisamaya.work"
echo "   http://n8n.jumpstartscaling.com"
