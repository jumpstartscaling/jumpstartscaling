# Stream-Rec Installation for rec.jumpstartscaling.com

Stream-Rec is a tool for recording live streams from various platforms.

## Overview

- **Domain:** https://rec.jumpstartscaling.com
- **Backend Port:** 12555
- **Frontend Port:** 15275
- **Server:** Oracle Cloud ARM64 (193.122.168.215)

## Quick Start

### 1. Deploy to Server

```bash
# From your local machine, sync files to the Oracle server
rsync -av --exclude 'downloads' --exclude 'rclone' \
  ./stream-rec/ opc@193.122.168.215:/home/opc/stream-rec/
```

### 2. SSH to Server

```bash
ssh opc@193.122.168.215
```

### 3. Start the Services

```bash
cd /home/opc/stream-rec

# Create directories if they don't exist
mkdir -p downloads rclone

# Start Docker services
docker compose up -d

# View logs
docker compose logs -f
```

### 4. Configure Cloudflare Tunnel

Add the following to `/etc/cloudflared/config.yml` on the server:

```yaml
ingress:
  # ... existing entries ...
  
  - hostname: rec.jumpstartscaling.com
    service: http://127.0.0.1:15275
  
  - service: http_status:404
```

Then restart the tunnel:

```bash
sudo systemctl restart cloudflared
sudo systemctl status cloudflared
```

### 5. Configure Cloudflare DNS

In your Cloudflare dashboard for `jumpstartscaling.com`:

1. Go to DNS settings
2. Add a new CNAME record:
   - **Type:** CNAME
   - **Name:** rec
   - **Target:** Your Cloudflare Tunnel ID (or existing tunnel target)
   - **Proxy status:** Proxied (orange cloud)
   - **TTL:** Auto

## Access

Once deployed, access the web interface at:

**https://rec.jumpstartscaling.com**

## Docker Commands

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f

# View backend logs only
docker compose logs -f backend

# View frontend logs only
docker compose logs -f frontend

# Restart services
docker compose restart

# Update to latest version
docker compose pull
docker compose up -d
```

## Storage

All recordings are stored in:
```
/home/opc/stream-rec/downloads/
```

**Important:** Monitor disk space as recordings can be large.

```bash
# Check disk usage
df -h /home/opc

# Check stream-rec directory size
du -sh /home/opc/stream-rec/downloads/
```

## Configuration

### Backend Environment Variables

Edit `docker-compose.yml` to change:

- `TZ` - Timezone (currently America/New_York)
- `LOG_LEVEL` - Logging verbosity (INFO, DEBUG, WARN, ERROR)
- `DB_PATH` - Database storage location
- `DOWNLOAD_PATH` - Where recordings are saved

### Frontend Environment Variables

**Important:** Change the `AUTH_SECRET` in docker-compose.yml before first run:

```yaml
- AUTH_SECRET=YourSecureRandomStringHere
```

## Troubleshooting

### Check if services are running

```bash
docker compose ps
```

### View real-time logs

```bash
docker compose logs -f
```

### Test backend connection

```bash
curl -I http://localhost:12555/
```

### Test frontend connection

```bash
curl -I http://localhost:15275/
```

### Restart everything

```bash
docker compose down
docker compose up -d
```

## Security Notes

1. The services are only accessible through Cloudflare Tunnel (no direct external ports)
2. All traffic is encrypted via HTTPS by Cloudflare
3. Change the `AUTH_SECRET` to a secure random string
4. Rclone credentials (if used) are stored in `./rclone/` and should be kept secure

## Backup

To backup your Stream-Rec data:

```bash
cd /home/opc
tar -czf stream-rec-backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  --exclude='stream-rec/downloads' \
  stream-rec/
```

## Uninstall

```bash
# Stop and remove containers
docker compose down

# Remove volumes (WARNING: This deletes all data)
docker compose down -v

# Remove directory
cd /home/opc
rm -rf stream-rec/
```

## Official Documentation

- Repository: https://github.com/stream-rec/stream-rec
- Frontend: https://github.com/stream-rec/stream-rec-frontend

---

**Deployed on:** Oracle Cloud ARM64  
**IP:** 193.122.168.215  
**Contact:** Chris Amaya
