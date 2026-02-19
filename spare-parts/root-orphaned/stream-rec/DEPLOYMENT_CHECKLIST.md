# Stream-Rec Deployment Checklist

Use this checklist to track your installation progress.

---

## ✅ Pre-Deployment Checklist

- [ ] Reviewed the architecture diagram
- [ ] Read `QUICK_START.md`
- [ ] Confirmed Oracle server is accessible via SSH
- [ ] Verified Docker is installed on Oracle server (or will be installed)
- [ ] Have access to Cloudflare Dashboard for jumpstartscaling.com

---

## 🚀 Deployment Steps

### Step 1: Deploy Files & Start Containers

- [ ] Opened terminal on Mac
- [ ] Changed to god-mode directory:
  ```bash
  cd /Users/christopheramaya/Downloads/spark/god-mode
  ```
- [ ] Ran deployment script:
  ```bash
  ./stream-rec/deploy.sh
  ```
- [ ] Verified files synced successfully
- [ ] Confirmed Docker containers started
- [ ] Checked container status shows "Up"

### Step 2: Configure Cloudflare Tunnel

- [ ] Ran configuration script:
  ```bash
  ./stream-rec/configure-server.sh
  ```
- [ ] Verified tunnel configuration updated
- [ ] Confirmed Cloudflare Tunnel restarted successfully
- [ ] Checked tunnel status is "active"

### Step 3: Add DNS Record

- [ ] Logged into Cloudflare Dashboard
- [ ] Selected domain: jumpstartscaling.com
- [ ] Navigated to DNS → Records
- [ ] Added new CNAME record:
  - Type: CNAME
  - Name: rec
  - Target: _________________________ (your tunnel target)
  - Proxied: Yes (Orange cloud)
  - TTL: Auto
- [ ] Saved the record
- [ ] Waited 2 minutes for DNS propagation

---

## 🔐 Post-Deployment Security

### Change AUTH_SECRET

- [ ] SSH to server:
  ```bash
  ssh opc@193.122.168.215
  ```
- [ ] Edited docker-compose.yml:
  ```bash
  cd /home/opc/stream-rec
  nano docker-compose.yml
  ```
- [ ] Changed AUTH_SECRET to secure random string
- [ ] Saved file (Ctrl+X, Y, Enter)
- [ ] Restarted containers:
  ```bash
  docker compose down && docker compose up -d
  ```

---

## ✅ Verification Steps

### Test Local Access (on server)

- [ ] SSH to server
- [ ] Test backend:
  ```bash
  curl -I http://localhost:12555/
  ```
  Expected: HTTP 200 (or similar success response)
  
- [ ] Test frontend:
  ```bash
  curl -I http://localhost:15275/
  ```
  Expected: HTTP 200

### Test Public Access

- [ ] Open browser
- [ ] Navigate to: https://rec.jumpstartscaling.com
- [ ] Page loads successfully
- [ ] No SSL errors
- [ ] Login page appears

### Verify Services

- [ ] Check Docker containers:
  ```bash
  ssh opc@193.122.168.215
  cd /home/opc/stream-rec
  docker compose ps
  ```
  Both should be "Up"

- [ ] Check logs for errors:
  ```bash
  docker compose logs --tail=50
  ```
  No critical errors

- [ ] Verify Cloudflare Tunnel:
  ```bash
  sudo systemctl status cloudflared
  ```
  Status: active (running)

---

## 📊 Monitoring Setup

- [ ] Bookmarked: https://rec.jumpstartscaling.com
- [ ] Added to Oracle Server documentation
- [ ] Set up disk space monitoring reminder
- [ ] Documented admin credentials (if created)

---

## 📝 Documentation Updated

- [ ] Updated ORACLE_SERVER_SETUP.md
  - Added to Production Services table
  - Added to Cloudflare Tunnel config
  - Added to Service URLs list

---

## 🎯 Optional Configuration

- [ ] Configure Rclone for cloud uploads (if needed)
- [ ] Set up recording schedules
- [ ] Configure quality settings
- [ ] Test recording a stream
- [ ] Set up backup automation

---

## 🆘 Troubleshooting (If Needed)

If something isn't working:

- [ ] Checked deployment logs
- [ ] Verified Docker is running
- [ ] Confirmed Cloudflare Tunnel is active
- [ ] Tested local connectivity (curl localhost)
- [ ] Checked DNS propagation
- [ ] Reviewed container logs
- [ ] Consulted INSTALLATION_GUIDE.md troubleshooting section

---

## ✨ Success Criteria

You're successfully deployed when:

- ✅ https://rec.jumpstartscaling.com loads
- ✅ Login page appears
- ✅ No browser security warnings
- ✅ Both Docker containers running
- ✅ Cloudflare Tunnel active
- ✅ AUTH_SECRET changed
- ✅ Can login and access dashboard

---

## 📅 Post-Installation

Date Deployed: ___________________

Server Location: Oracle Cloud ARM64 (193.122.168.215)

Domain: https://rec.jumpstartscaling.com

Notes:
_____________________________________________
_____________________________________________
_____________________________________________

---

## 🔄 Maintenance Schedule

- [ ] Weekly: Check disk space for recordings
- [ ] Monthly: Review and delete old recordings
- [ ] Monthly: Check for Stream-Rec updates
- [ ] Quarterly: Backup configuration
- [ ] As needed: Review recording quality settings

---

**Installation Package Created:** February 5, 2026  
**Documentation:** See INSTALLATION_GUIDE.md for detailed help
