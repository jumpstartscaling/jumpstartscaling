# Fresh Server Setup Plan - Coolify Installation

## Current Status
- ✅ Website files: Stored locally in `/Users/christopheramaya/Downloads/spark/god-mode/sites/`
- ⏳ PostgreSQL: Need to backup before wiping
- ⏳ Server: Ready to be wiped

## Preparation Steps

### 1. Backup PostgreSQL Database
Run on server before wiping:
```bash
# This will backup all databases
bash /tmp/backup_postgres.sh
# Download backup
scp opc@150.136.117.198:~/postgres_backup_*.tar.gz ./
```

### 2. Verify Local Files
We have these sites locally:
- jumpstartscaling-next (Next.js 16)
- jumpstartscaling (old Astro - can delete)
- chrisamaya (personal site)

## Fresh Install Procedure

### Step 1: Wipe Server
**Option A: Oracle Cloud Console**
- Go to OCI console
- Terminate instance
- Create new instance (same specs)
- Note new IP address

**Option B: Keep instance, fresh OS**
- Oracle Linux reinstall via console

### Step 2: Initial Server Setup
```bash
# SSH to new server
ssh opc@<NEW_IP>

# Update system
sudo yum update -y

# Install Docker
curl -fsSL https://get.docker.com | bash
sudo usermod -aG docker opc
sudo systemctl enable docker
sudo systemctl start docker

# Logout and login to apply docker group
exit
ssh opc@<NEW_IP>
```

### Step 3: Install Coolify
```bash
# Official installer
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash

# Wait 2-3 minutes for containers to start
sleep 180

# Verify
docker ps | grep coolify
```

### Step 4: Configure DNS
Update Cloudflare DNS:
```
spark.jumpstartscaling.com → A → <NEW_IP> (proxied: NO)
jumpstartscaling.com → A → <NEW_IP> (proxied: YES)
www.jumpstartscaling.com → A → <NEW_IP> (proxied: YES)
n8n.jumpstartscaling.com → A → <NEW_IP> (proxied: YES)
cockpit.jumpstartscaling.com → A → <NEW_IP> (proxied: YES)
```

### Step 5: Access Coolify
1. Open: `http://spark.jumpstartscaling.com:8000`
2. Complete setup wizard
3. Create admin account

### Step 6: Deploy Applications

#### Next.js Site
1. In Coolify: **+ Add Resource** → **Application** → **Public Repository**
2. Or upload `/Users/christopheramaya/Downloads/spark/god-mode/sites/jumpstartscaling-next`
3. Configure:
   - Build: `npm run build`
   - Start: `npm start`
   - Port: 8100
   - Domain: `jumpstartscaling.com`

#### PostgreSQL Database
1. Add Resource → **Database** → **PostgreSQL**
2. Restore backup:
   ```bash
   scp postgres_backup_*.tar.gz opc@<NEW_IP>:/tmp/
   # In Coolify container, restore
   ```

#### n8n
1. Add Resource → **Service** → Search "n8n"
2. Domain: `n8n.jumpstartscaling.com`

## Advantages of Fresh Start
✅ No conflicting services (nginx, cloudflared, etc)
✅ Clean Coolify install
✅ Proper Docker environment
✅ Easy to manage via UI
✅ Automatic SSL certificates
✅ One place to see all apps

## Timeline
- Backup: 10 minutes
- Server wipe/setup: 20 minutes
- Coolify install: 5 minutes
- App deployment: 30 minutes
- **Total: ~1 hour**

## Ready to proceed?
1. Run backup script
2. Confirm we have all files locally
3. Wipe server and start fresh
