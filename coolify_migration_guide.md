# Coolify App Migration Guide

## Step 1: Access Coolify
Open your browser and navigate to:
- **http://150.136.117.198:8000**
- or **http://coolify.jumpstartscaling.com:8000**

## Step 2: Initial Setup
1. Complete the registration wizard
2. Set admin email and password
3. Create your first project/server

## Step 3: Import Next.js Application

### Option A: From Directory (Recommended)
1. In Coolify, click **+ Add Resource**
2. Select **Service** > **Docker Compose**
3. Configure:
   ```yaml
   services:
     nextjs:
       image: node:20
       working_dir: /app
       volumes:
         - /home/opc/jumpstart-next:/app
       command: npm run dev
       ports:
         - "8100:8100"
       environment:
         - PORT=8100
   ```
4. Set domain: `jumpstartscaling.com`
5. Deploy

### Option B: From Git Repository
1. Click **+ Add Resource** > **Application**
2. Select **Public Repository** or connect GitHub
3. Enter repository URL
4. Set build settings:
   - Build Command: `npm run build`
   - Start Command: `npm start`
   - Port: 8100
5. Add domain: `jumpstartscaling.com`
6. Deploy

## Step 4: Import n8n

1. Click **+ Add Resource** > **Service**
2. Search for **n8n** in templates
3. Or use Docker Compose:
   ```yaml
   services:
     n8n:
       image: n8nio/n8n
       ports:
         - "5678:5678"
       volumes:
         - /home/opc/.n8n:/home/node/.n8n
       environment:
         - N8N_HOST=n8n.jumpstartscaling.com
         - N8N_PORT=5678
   ```
4. Set domain: `n8n.jumpstartscaling.com`
5. Deploy

## Step 5: Configure Domains in Coolify

For each application:
1. Go to application settings
2. Click **Domains**
3. Add your domain (e.g., `jumpstartscaling.com`)
4. Coolify will automatically:
   - Configure Traefik reverse proxy
   - Request SSL certificate (if exposed)
   - Route traffic correctly

## Step 6: DNS Configuration Options

### Option A: Direct to Coolify (Recommended)
Update Cloudflare DNS:
- `jumpstartscaling.com` → A record → `150.136.117.198`
- `n8n.jumpstartscaling.com` → A record → `150.136.117.198`
- Enable Cloudflare proxy (orange cloud)
- Coolify's Traefik will handle routing

### Option B: Keep Cloudflare Tunnel
- Configure tunnel ingress to point to Coolify's Traefik (port 80/443)
- Let Coolify handle internal routing

## Step 7: Verify Everything Works

Test each domain:
- https://jumpstartscaling.com
- https://n8n.jumpstartscaling.com  
- https://coolify.jumpstartscaling.com:8000

## Important Notes

- **Stop PM2 processes** before importing to avoid port conflicts
- **Backup data** before migration
- **Environment variables**: Add in Coolify UI under application settings
- **Database**: If using PostgreSQL, add as a separate service in Coolify

## Troubleshooting

**Port conflicts:**
```bash
# Stop PM2
pm2 stop all
pm2 delete all
```

**View Coolify logs:**
```bash
sudo docker logs -f <container-name>
```

**Restart Coolify:**
```bash
sudo docker-compose -f /path/to/coolify/docker-compose.yml restart
```
