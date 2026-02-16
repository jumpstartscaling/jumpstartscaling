# ✅ Stream-Rec Installation - Complete Package

## 📦 What's Ready

I've created a complete **Stream-Rec** installation package for your Oracle server at **rec.jumpstartscaling.com**.

### Files Created

```
god-mode/stream-rec/
├── docker-compose.yml               # Docker configuration (backend + frontend)
├── deploy.sh                        # Automated deployment script ⭐
├── configure-server.sh              # Server configuration script ⭐
├── QUICK_START.md                   # 3-step installation guide
├── INSTALLATION_GUIDE.md            # Complete documentation
├── README.md                        # General documentation
├── cloudflare-tunnel-config.yml     # Tunnel routing snippet
└── .gitignore                       # Protects sensitive data
```

---

## 🎯 Next Steps (Choose Your Path)

### Option A: Automated (Recommended) ⚡

Run these 3 commands from your Mac:

```bash
cd /Users/christopheramaya/Downloads/spark/god-mode

# 1. Deploy to server
./stream-rec/deploy.sh

# 2. Configure Cloudflare Tunnel
./stream-rec/configure-server.sh

# 3. Add DNS record (see below)
```

### Option B: Manual Installation 🔧

Follow the detailed step-by-step guide:
- Open: `stream-rec/INSTALLATION_GUIDE.md`
- Full control over every step

---

## 🌐 DNS Configuration (Required)

After running the scripts above, add this DNS record in Cloudflare:

1. Go to: https://dash.cloudflare.com
2. Domain: **jumpstartscaling.com**
3. DNS → Add record:
   - **Type:** CNAME
   - **Name:** rec
   - **Target:** Your existing tunnel target (same as other subdomains)
   - **Proxied:** ✅ Yes (Orange cloud)
   - **TTL:** Auto

---

## 📊 Architecture Overview

```
User Browser
    ↓
https://rec.jumpstartscaling.com
    ↓
Cloudflare CDN (HTTPS/DDoS Protection)
    ↓
Cloudflare Tunnel (QUIC Protocol)
    ↓
Oracle Server (193.122.168.215)
    ↓
Port 15275 (Stream-Rec Frontend) → Docker Container
    ↓
Port 12555 (Stream-Rec Backend) → Docker Container
    ↓
Stores recordings in: /home/opc/stream-rec/downloads/
```

---

## 🔐 Security Features

✅ **No public ports exposed** (all traffic via Cloudflare Tunnel)  
✅ **HTTPS encryption** (managed by Cloudflare)  
✅ **DDoS protection** (Cloudflare CDN)  
✅ **Authentication** (next-auth with configurable secret)  
✅ **Isolated Docker containers** (network isolation)

---

## ⚙️ Configuration Highlights

### Docker Services

**Frontend (Port 15275)**
- Web interface
- User authentication
- Live stream monitoring
- WebSocket for real-time updates

**Backend (Port 12555)**
- Stream recording engine
- Database management
- API endpoints
- File storage

### Environment Variables Set

- **Timezone:** America/New_York
- **Log Level:** INFO
- **Storage:** /home/opc/stream-rec/downloads/
- **Public URL:** https://rec.jumpstartscaling.com
- **WebSocket:** wss://rec.jumpstartscaling.com/live/update
- **Cloudflare Tunnel:** Enabled (AUTH_TRUST_HOST=true)

---

## 📝 Documentation Updated

I've also updated your server documentation:

### `ORACLE_SERVER_SETUP.md`

Added Stream-Rec to:
- ✅ Production Services table
- ✅ Cloudflare Tunnel configuration
- ✅ Service URLs quick reference

---

## 🚀 What Happens Next

When you run the deployment:

1. **Files sync** to `/home/opc/stream-rec/` on Oracle server
2. **Docker pulls** latest Stream-Rec images (ARM64 compatible)
3. **Containers start** with auto-restart policy
4. **Cloudflare Tunnel** gets updated routing rules
5. **DNS propagates** in 1-2 minutes
6. **Service goes live** at https://rec.jumpstartscaling.com

---

## 💾 Storage Considerations

**Recordings can be large!** Monitor disk space:

```bash
# Check available space
df -h /home/opc

# Check stream-rec folder size
du -sh /home/opc/stream-rec/downloads/
```

**Oracle Cloud Free Tier:**
- Boot volume: Usually 50-200GB
- Consider increasing if you'll record frequently

---

## 🛠️ Management Commands

After installation, SSH to server and use:

```bash
cd /home/opc/stream-rec

# View status
docker compose ps

# View logs
docker compose logs -f

# Restart
docker compose restart

# Stop
docker compose down

# Update to latest version
docker compose pull && docker compose up -d
```

---

## 🔄 Backup Strategy

Stream-Rec data is stored in:
```
/home/opc/stream-rec/
├── downloads/          # Your recordings (can be large!)
├── rclone/             # Cloud storage config (optional)
└── [Docker volumes]    # Database & settings
```

**Backup command:**
```bash
cd /home/opc
tar -czf stream-rec-backup-$(date +%Y%m%d).tar.gz \
  --exclude='stream-rec/downloads' \
  stream-rec/
```

---

## 🆘 Quick Troubleshooting

### Containers won't start
```bash
docker compose logs
sudo systemctl restart docker
```

### Can't access via domain
```bash
sudo systemctl status cloudflared
curl -I http://localhost:15275/
```

### WebSocket issues
Check `WS_API_URL` in docker-compose.yml

### Disk space full
```bash
du -sh /home/opc/stream-rec/downloads/*
# Delete old recordings as needed
```

---

## 📚 Resources

- **Quick Start:** `stream-rec/QUICK_START.md` (3 commands)
- **Full Guide:** `stream-rec/INSTALLATION_GUIDE.md` (complete docs)
- **README:** `stream-rec/README.md` (overview)
- **Official Repo:** https://github.com/stream-rec/stream-rec

---

## ✨ Features You'll Get

🎥 **Multi-platform support:** Twitch, YouTube, etc.  
📁 **Organized storage:** Auto-naming and categorization  
🔴 **Live monitoring:** Real-time recording status  
☁️ **Cloud upload:** Rclone integration (optional)  
⚙️ **Configurable:** Quality, format, scheduling  
🌐 **Web UI:** Easy management interface  

---

## 🎯 Ready to Deploy?

**From your Mac:**

```bash
cd /Users/christopheramaya/Downloads/spark/god-mode
./stream-rec/deploy.sh
```

Then follow the on-screen instructions!

Or read `stream-rec/QUICK_START.md` for the full 3-step process.

---

**Package Created:** February 5, 2026  
**Target Server:** Oracle Cloud ARM64 (193.122.168.215)  
**Domain:** rec.jumpstartscaling.com  
**Contact:** Chris Amaya

---

🎉 **Everything is ready to go!** Just run the deployment scripts when you're ready.
