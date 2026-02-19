# Coolify VPS — Server Setup & Reference
**Last Updated:** February 18, 2026  
**Status:** ✅ Coolify Installed & Running  
**Purpose:** Complete reference for the new production VPS running Coolify.

---

## 🖥️ Server Details

| Field | Value |
|---|---|
| **Provider** | Contabo (or similar VPS) |
| **Hostname** | `vmi3093256` |
| **Host System** | 17596 |
| **Region** | US-East |
| **Public IP** | `86.48.23.38` |
| **IPv6** | `2605:a144:2309:3256::1/64` |
| **MAC Address** | `00:50:56:61:71:45` |
| **OS** | Ubuntu 24.04.4 LTS (Noble) |
| **Kernel** | Linux 6.8.0-94-generic x86_64 |
| **Created** | February 18, 2026 |
| **Plan** | Cloud VPS 30 SSD |
| **Disk** | 400 GB (385 GB free at setup) |
| **CPU** | 8 cores |
| **RAM** | 24 GB |
| **Monthly Cost** | $20.50/mo |
| **VNC** | Enabled — `217.216.62.6:63157` |

---

## 🔐 Access Credentials

### Root SSH Access
```bash
ssh root@86.48.23.38
```
| Field | Value |
|---|---|
| **Default User** | `root` |
| **Root Password** | `HappyChris7752lol` |
| **SSH Port** | 22 |

> ⚠️ **Recommended:** Add your SSH public key to `/root/.ssh/authorized_keys` and disable password auth after setup.

### Coolify Web UI
| Field | Value |
|---|---|
| **URL** | http://86.48.23.38:8000 |
| **Admin Name** | Chris Amaya |
| **Admin Email** | somescreenname@gmail.com |
| **Admin Password** | `HappyChris7752lol!` (note the `!` at the end — required by Coolify) |

---

## 🐳 Docker & Coolify Installation

**Installed:** February 18, 2026  
**Coolify Version:** 4.0.0-beta.463  
**Docker Version:** 27.0.3  
**Installation Method:** Official Coolify installer

```bash
# How it was installed (for reference)
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

### Running Containers

| Container | Status | Ports |
|---|---|---|
| `coolify` | ✅ Healthy | 8000→8080 (UI) |
| `coolify-proxy` | ✅ Healthy | 80, 443, 8080 (Traefik) |
| `coolify-db` | ✅ Healthy | 5432 (internal) |
| `coolify-redis` | ✅ Healthy | 6379 (internal) |
| `coolify-realtime` | ✅ Healthy | 6001-6002 |
| `coolify-sentinel` | ✅ Healthy | — |

### Coolify File Locations on Server
```
/data/coolify/
├── source/
│   ├── .env              ← Coolify environment variables (back this up!)
│   ├── docker-compose.yml
│   └── upgrade-*.log     ← Install logs
└── data/
    ├── databases/        ← PostgreSQL data
    └── applications/     ← Deployed app data
```

### Coolify Internal Secrets (from .env)
| Key | Value |
|---|---|
| `APP_ID` | `3fdfd19932b299092ec72c4d9ad640f8` |
| `APP_KEY` | `base64:0VEwP7d6EoAcPBFaGXN7kaX7ez95cYZGS1XTUJ3eB34=` |
| `DB_PASSWORD` | `8IMaCwNc3DGVpLNS13UhVQSKfwnIzHE/RefF1Ow/kaU=` |
| `REDIS_PASSWORD` | `mx6sWF5pUMxVJOWxNZOlUy01iCtsxDNuabmY0pDhRCY=` |

> ⚠️ Back up `/data/coolify/source/.env` to a password manager. Losing it = losing access to all deployed apps.

---

## 🔑 SSH Keys

### Coolify's Generated SSH Key (for deploying to this server)
Coolify generated an SSH key during setup for internal use. The public key added to `/root/.ssh/authorized_keys`:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB90SKZDkhplPPnjb9Igv/od40QYjjXSlyXkFFDyor9V coolify
```

This key is used by Coolify internally to deploy apps to localhost.

### Adding Your Own SSH Key (Recommended)
To log in without a password, add your Mac's public key:
```bash
# On your Mac, get your public key:
cat ~/.ssh/id_rsa.pub
# or
cat ~/.ssh/id_ed25519.pub

# Then on the server:
echo "YOUR_PUBLIC_KEY" >> /root/.ssh/authorized_keys
```

---

## 🌐 Network & Firewall

**Firewall:** UFW (currently inactive — Coolify manages ports via Docker/Traefik)

### Ports in Use
| Port | Service | Public? |
|---|---|---|
| 22 | SSH | ✅ Yes |
| 80 | HTTP (Traefik/Coolify proxy) | ✅ Yes |
| 443 | HTTPS (Traefik/Coolify proxy) | ✅ Yes |
| 8000 | Coolify UI | ✅ Yes (restrict after setup) |
| 8080 | Traefik dashboard | Internal |
| 6001-6002 | Coolify realtime | Internal |
| 5432 | PostgreSQL | Internal only |
| 6379 | Redis | Internal only |

> **Tip:** After setup is complete, consider restricting port 8000 to your IP only via UFW.

---

## 🚀 Planned Deployments

These 3 services will be deployed via Coolify once GitHub repos are ready:

| App | GitHub Repo | Domain | Framework |
|---|---|---|---|
| Jumpstart Scaling | `jumpstartscaling-site` (private) | jumpstartscaling.com | Astro v5 |
| Chris Amaya Portfolio | `chrisamaya-site` (private) | chrisamaya.work | Astro v5 |
| God Mode API | `god-mode-api` (private) | api.jumpstartscaling.com | FastAPI/Python |

---

## 🔧 Useful Commands

```bash
# SSH into server
ssh root@86.48.23.38

# Check all Coolify containers
docker ps

# View Coolify logs
docker logs coolify -f

# Restart Coolify
cd /data/coolify/source && docker compose restart

# Check disk space
df -h

# Check memory
free -h

# Update system
apt update && apt upgrade -y
```

---

## 📋 Next Steps Checklist

- [ ] Add your SSH public key to `/root/.ssh/authorized_keys`
- [ ] Connect GitHub Enterprise as a source in Coolify UI (Settings → Sources)
- [ ] Create GitHub repos for the 3 services (see `ORACLE_SERVER_HANDOFF.md`)
- [ ] Deploy `jumpstartscaling-site` via Coolify
- [ ] Deploy `chrisamaya-site` via Coolify
- [ ] Deploy `god-mode-api` via Coolify (needs Dockerfile)
- [ ] Update Cloudflare DNS: point domains to `86.48.23.38`
- [ ] Verify SSL auto-provisioned by Coolify (Let's Encrypt via Traefik)
- [ ] Restrict port 8000 to your IP via UFW
- [ ] Back up `/data/coolify/source/.env` to password manager

---

## 🆘 Recovery

If Coolify UI is unreachable:
```bash
ssh root@86.48.23.38
cd /data/coolify/source
docker compose down && docker compose up -d
```

If containers won't start:
```bash
docker logs coolify
docker logs coolify-proxy
```

---

**Server IP:** `86.48.23.38`  
**Coolify UI:** http://86.48.23.38:8000  
**Setup Date:** February 18, 2026  
**Installed By:** Antigravity AI
