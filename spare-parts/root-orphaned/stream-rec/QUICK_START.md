# Stream-Rec Installation - Quick Start (Wildcard Subdomain)

## 🎯 What You're Installing

**Stream-Rec** - A live stream recording tool  
**Domain:** https://rec.jumpstartscaling.com  
**Server:** Oracle Cloud (193.122.168.215)  
**DNS:** Uses existing wildcard subdomain `*.jumpstartscaling.com`

---

## ✅ DNS Already Configured!

Since you have a **wildcard subdomain**, `rec.jumpstartscaling.com` will automatically resolve to your server. **No DNS changes needed!**

---

## ⚡ Installation (3 Commands)

From your Mac in the `god-mode` directory:

### 1. Deploy Docker Containers
```bash
cd /Users/christopheramaya/Downloads/spark/god-mode
./stream-rec/deploy.sh
```
This syncs files and starts Docker containers.

### 2. Setup Nginx Reverse Proxy
```bash
./stream-rec/setup-nginx.sh
```
This installs and configures Nginx.

### 3. Setup SSL Certificate
```bash
./stream-rec/setup-ssl.sh
```

**Options for SSL:**

**A) If you have a wildcard SSL certificate:**
- Update the Nginx config to use your existing wildcard cert
- Skip the Let's Encrypt setup

**B) If you need a new certificate:**
- The script will get a Let's Encrypt cert for `rec.jumpstartscaling.com`
- Make sure ports 80 and 443 are open in Oracle firewall

---

## 🔐 Oracle Cloud Firewall

**Important:** Ports must be open!

In Oracle Cloud Console:
1. Your VM → Virtual Cloud Network
2. Security Lists → Add Ingress Rules:
   - **Port 80** (HTTP) from 0.0.0.0/0
   - **Port 443** (HTTPS) from 0.0.0.0/0

---

## 🎉 Access

Once deployed and SSL configured:

**https://rec.jumpstartscaling.com**

---

## 🔧 If You Have Wildcard SSL Certificate

Update the Nginx configuration to use your existing certificate:

```bash
ssh opc@193.122.168.215
sudo nano /etc/nginx/conf.d/stream-rec.conf
```

Update these lines to point to your wildcard certificate:
```nginx
ssl_certificate /path/to/your/wildcard/fullchain.pem;
ssl_certificate_key /path/to/your/wildcard/privkey.pem;
```

Then reload Nginx:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## ⚙️ Security Setup

### Change AUTH_SECRET (Important!)

```bash
ssh opc@193.122.168.215
nano /home/opc/stream-rec/docker-compose.yml
```

Change:
```yaml
- AUTH_SECRET=ChangeThisToASecureRandomString123!
```

Restart:
```bash
docker compose down && docker compose up -d
```

---

## 📋 Summary

**Advantages of wildcard subdomain:**
✅ No DNS configuration needed  
✅ rec.jumpstartscaling.com resolves automatically  
✅ May already have SSL coverage  
✅ Faster setup  

---

**Questions?** Check `INSTALLATION_GUIDE.md` for detailed help.
