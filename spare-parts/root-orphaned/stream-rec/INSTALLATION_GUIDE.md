# 🎥 Stream-Rec Installation Guide
## rec.jumpstartscaling.com

Complete deployment guide for installing Stream-Rec on Oracle Cloud server.

---

## 📋 Overview

**Stream-Rec** is a live stream recording tool that will be accessible at `https://rec.jumpstartscaling.com`

- **Server:** Oracle Cloud ARM64 (193.122.168.215)
- **Domain:** rec.jumpstartscaling.com
- **Backend Port:** 12555 (internal)
- **Frontend Port:** 15275 (internal)
- **Access:** Via Cloudflare Tunnel (HTTPS)

---

## ⚡ Quick Install (3 Steps)

### Step 1: Deploy to Server

From your local machine in the `god-mode` directory:

```bash
cd /Users/christopheramaya/Downloads/spark/god-mode
./stream-rec/deploy.sh
```

This will:
- Sync all files to the Oracle server
- Create necessary directories
- Pull Docker images
- Start the containers

### Step 2: Configure Cloudflare Tunnel

```bash
./stream-rec/configure-server.sh
```

This will:
- Update `/etc/cloudflared/config.yml` on the server
- Add the rec.jumpstartscaling.com routing
- Restart the Cloudflare Tunnel service

### Step 3: Add DNS Record

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Select domain: **jumpstartscaling.com**
3. Navigate to **DNS** → **Records**
4. Click **Add record**
5. Configure:
   - **Type:** CNAME
   - **Name:** rec
   - **Target:** (Same as your other services, e.g., `abc123.cfargotunnel.com`)
   - **Proxy status:** ✅ Proxied (Orange cloud)
   - **TTL:** Auto

6. Click **Save**

### Step 4: Access Stream-Rec

Wait 1-2 minutes for DNS propagation, then visit:

**https://rec.jumpstartscaling.com**

---

## 🔧 Manual Installation Steps

If you prefer to install manually:

### 1. Sync Files to Server

```bash
rsync -av --exclude 'downloads' --exclude 'rclone' \
  ./stream-rec/ opc@193.122.168.215:/home/opc/stream-rec/
```

### 2. SSH to Server

```bash
ssh opc@193.122.168.215
```

### 3. Install Docker (if not already installed)

```bash
# Check if Docker is installed
docker --version

# If not, install it
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
exit
ssh opc@193.122.168.215
```

### 4. Start Stream-Rec

```bash
cd /home/opc/stream-rec

# Create directories
mkdir -p downloads rclone

# Start services
docker compose up -d

# View logs
docker compose logs -f
```

### 5. Configure Cloudflare Tunnel

```bash
# Backup current config
sudo cp /etc/cloudflared/config.yml /etc/cloudflared/config.yml.backup

# Edit config
sudo nano /etc/cloudflared/config.yml
```

Add this entry **before** the final `- service: http_status:404` line:

```yaml
  # Stream Recording Service
  - hostname: rec.jumpstartscaling.com
    service: http://127.0.0.1:15275
```

Save and exit (Ctrl+X, then Y, then Enter)

### 6. Restart Tunnel

```bash
sudo systemctl restart cloudflared
sudo systemctl status cloudflared
```

### 7. Add DNS Record

Follow Step 3 from the Quick Install above.

---

## 🔐 Security Configuration

### Change AUTH_SECRET

**IMPORTANT:** Before first login, change the authentication secret:

1. SSH to server:
   ```bash
   ssh opc@193.122.168.215
   cd /home/opc/stream-rec
   ```

2. Edit docker-compose.yml:
   ```bash
   nano docker-compose.yml
   ```

3. Find this line in the frontend service:
   ```yaml
   - AUTH_SECRET=ChangeThisToASecureRandomString123!
   ```

4. Replace with a secure random string (30+ characters)

5. Restart the services:
   ```bash
   docker compose down
   docker compose up -d
   ```

---

## 📊 Management Commands

### View Status

```bash
# SSH to server
ssh opc@193.122.168.215

# Check containers
cd /home/opc/stream-rec
docker compose ps
```

### View Logs

```bash
# All logs
docker compose logs -f

# Backend only
docker compose logs -f backend

# Frontend only
docker compose logs -f frontend

# Last 50 lines
docker compose logs --tail=50
```

### Restart Services

```bash
# Restart all
docker compose restart

# Restart backend only
docker compose restart backend

# Restart frontend only
docker compose restart frontend
```

### Update Stream-Rec

```bash
cd /home/opc/stream-rec

# Pull latest images
docker compose pull

# Restart with new images
docker compose up -d
```

### Stop Services

```bash
# Stop (keeps data)
docker compose down

# Stop and remove volumes (DELETES ALL DATA)
docker compose down -v
```

---

## 💾 Storage Management

### Check Disk Space

```bash
# Overall disk usage
df -h /home/opc

# Stream-Rec directory size
du -sh /home/opc/stream-rec/downloads/
```

### Recording Storage

All recordings are saved to:
```
/home/opc/stream-rec/downloads/
```

**Monitor this regularly** as video files can be very large!

### Clean Old Recordings

```bash
# List recordings by size
du -sh /home/opc/stream-rec/downloads/* | sort -h

# Delete specific recording
rm -rf /home/opc/stream-rec/downloads/[recording-name]
```

---

## 🔍 Troubleshooting

### Services Won't Start

```bash
# Check Docker status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Try starting again
cd /home/opc/stream-rec
docker compose up -d
```

### Can't Access via Domain

1. Check Cloudflare Tunnel:
   ```bash
   sudo systemctl status cloudflared
   sudo journalctl -u cloudflared -n 50
   ```

2. Verify tunnel config:
   ```bash
   sudo cat /etc/cloudflared/config.yml | grep -A2 "rec.jumpstartscaling.com"
   ```

3. Check if frontend is running:
   ```bash
   curl -I http://localhost:15275/
   ```

4. Check DNS propagation:
   ```bash
   nslookup rec.jumpstartscaling.com
   ```

### WebSocket Connection Issues

If live updates don't work, check the WebSocket URL in docker-compose.yml:

```yaml
- WS_API_URL=wss://rec.jumpstartscaling.com/live/update
```

This should match your public domain.

### Container Logs Show Errors

```bash
# View detailed logs
docker compose logs backend --tail=100
docker compose logs frontend --tail=100

# Check container status
docker compose ps

# Restart problematic container
docker compose restart [backend|frontend]
```

---

## 📦 Backup & Restore

### Backup Stream-Rec

```bash
# On server
cd /home/opc
tar -czf stream-rec-backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  --exclude='stream-rec/downloads' \
  stream-rec/

# Move to backups directory
mv stream-rec-backup-*.tar.gz ~/backups/
```

### Restore from Backup

```bash
cd /home/opc
tar -xzf backups/stream-rec-backup-[timestamp].tar.gz

cd stream-rec
docker compose up -d
```

---

## 🔄 Complete Removal

If you need to uninstall:

```bash
# SSH to server
ssh opc@193.122.168.215

# Stop and remove containers
cd /home/opc/stream-rec
docker compose down -v

# Remove directory
cd /home/opc
rm -rf stream-rec/

# Remove from Cloudflare Tunnel
sudo nano /etc/cloudflared/config.yml
# Delete the rec.jumpstartscaling.com entry

# Restart tunnel
sudo systemctl restart cloudflared

# Remove DNS record from Cloudflare Dashboard
```

---

## 📚 Additional Resources

- **Official Repo:** https://github.com/stream-rec/stream-rec
- **Frontend Repo:** https://github.com/stream-rec/stream-rec-frontend
- **Documentation:** Check the official repository for detailed usage guides

---

## 🆘 Need Help?

### Quick Diagnostics

Run this on the server to get a full status report:

```bash
cd /home/opc/stream-rec

echo "=== Container Status ==="
docker compose ps

echo -e "\n=== Backend Health ==="
curl -I http://localhost:12555/ 2>&1 | head -n 5

echo -e "\n=== Frontend Health ==="
curl -I http://localhost:15275/ 2>&1 | head -n 5

echo -e "\n=== Tunnel Status ==="
sudo systemctl status cloudflared --no-pager | head -n 10

echo -e "\n=== Disk Space ==="
df -h /home/opc | grep -E "Filesystem|/home"

echo -e "\n=== Recent Logs ==="
docker compose logs --tail=20
```

---

**Server:** Oracle Cloud ARM64 (193.122.168.215)  
**Domain:** rec.jumpstartscaling.com  
**Support:** Chris Amaya  
**Last Updated:** February 5, 2026
