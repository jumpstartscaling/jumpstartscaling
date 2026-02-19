# Stream-Rec Deployment - Updated Architecture

## ✅ UPDATED: Direct Access (No Cloudflare Tunnel)

Based on your feedback, I've **updated the installation** to use **direct HTTPS access** instead of Cloudflare Tunnel.

### New Architecture

```
User Browser (HTTPS)
    ↓
https://rec.jumpstartscaling.com
    ↓
DNS A Record → 193.122.168.215
    ↓
Oracle Cloud Firewall (Ports 80, 443)
    ↓
Nginx Reverse Proxy (Let's Encrypt SSL)
    ↓
Port 15275 → Stream-Rec Frontend (Docker)
Port 12555 → Stream-Rec Backend (Docker)
    ↓
Storage: /home/opc/stream-rec/downloads/
```

---

## 🔄 What Changed

### Before (Cloudflare Tunnel)
- ❌ Required Cloudflare Tunnel configuration
- ❌ Tunnel-specific WebSocket routing
- ❌ Additional complexity

### After (Direct Access)
- ✅ Standard Nginx reverse proxy
- ✅ Let's Encrypt SSL certificates
- ✅ Direct port access via firewall
- ✅ Simpler, more standard setup

---

## 📦 Updated Files

I've updated these files for direct access:

1. **docker-compose.yml**
   - Ports bound to 127.0.0.1 (localhost only)
   - Nginx will proxy to these ports

2. **nginx-stream-rec.conf** **(NEW)**
   - Nginx configuration with SSL
   - WebSocket support
   - Reverse proxy to Docker containers

3. **deploy.sh**
   - Removed Cloudflare Tunnel steps
   - Added Nginx setup instructions

4. **setup-nginx.sh** **(NEW)**
   - Installs and configures Nginx
   - Copies configuration file

5. **setup-ssl.sh** **(NEW)**
   - Installs Certbot
   - Obtains Let's Encrypt certificate
   - Configures auto-renewal

6. **Removed:**
   - ~~configure-server.sh~~ (was for Cloudflare Tunnel)
   - ~~cloudflare-tunnel-config.yml~~ (not needed)

---

## 🚀 New Installation Steps

### 1. Deploy Containers
```bash
./stream-rec/deploy.sh
```

### 2. Setup Nginx
```bash
./stream-rec/setup-nginx.sh
```

### 3. Configure DNS (Cloudflare)
- Type: **A**
- Name: **rec**
- IPv4: **193.122.168.215**
- Proxy: **❌ DNS only** (Gray cloud, NOT orange!)

### 4. Setup SSL
```bash
./stream-rec/setup-ssl.sh
```

### 5. Open Oracle Firewall
In Oracle Cloud Console:
- Port 80 (HTTP)
- Port 443 (HTTPS)

---

## 🔐 Security Notes

### Firewall Configuration Required

**Important:** You must configure Oracle Cloud firewall rules to allow:
- Port 80 (for Let's Encrypt certificate validation)
- Port 443 (for HTTPS access)

### SSL Certificate

- **Provider:** Let's Encrypt (free, auto-renewing)
- **Validity:** 90 days (auto-renews via certbot timer)
- **Type:** Domain-validated

### Nginx Security

The Nginx configuration includes:
- HTTPS redirect (HTTP → HTTPS)
- Security headers (X-Frame-Options, etc.)
- TLS 1.2+ only
- WebSocket support for real-time updates

---

## 📊 Port Configuration

| Service | Port | Binding | Access |
|---------|------|---------|--------|
| Frontend | 15275 | 127.0.0.1 | Via Nginx only |
| Backend | 1 2555 | 127.0.0.1 | Via Nginx only |
| Nginx HTTP | 80 | 0.0.0.0 | Public (redirects to HTTPS) |
| Nginx HTTPS | 443 | 0.0.0.0 | Public |

---

## 📚 Documentation

- **Quick Start:** `QUICK_START.md`
- **Full Guide:** `INSTALLATION_GUIDE.md` (needs update)
- **Nginx Config:** `nginx-stream-rec.conf`

---

## ✨ Ready to Install

Everything is ready for direct HTTPS access without Cloudflare Tunnel!

Run:
```bash
cd /Users/christopheramaya/Downloads/spark/god-mode
./stream-rec/deploy.sh
```

And follow the prompts.

---

**Updated:** February 5, 2026  
**Architecture:** Direct HTTPS (Nginx + Let's Encrypt)  
**No Cloudflare Tunnel required**
