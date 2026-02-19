# Server Master Documentation (V2 - Advanced Architecture)
**Last Updated:** 2026-01-10
**Server**: Oracle Cloud ARM64 (OCI VM.Standard.A1.Flex)
**OS**: Oracle Linux 10 (ARM64)

## 0. Executive Summary for CTO / Senior Engineering
This server is configured as a **Multi-Tenant Hybrid Monolith**. It balances high-performance Astro frontends with a robust Django/FastAPI backend ecosystem. All services are isolated via PM2, proxied through Cloudflare Tunnels (identity-aware), and managed via a native unified management layer (Cockpit).

---

## 1. Access & Infrastructure
*   **Primary Domain**: `jumpstartscaling.com`
*   **SSH**: `ssh opc@jumpstartscaling.com` (Note: Ensure your SSH keys are mapped to the domain).
*   **Identity Provider**: Cloudflare Tunnel (`cloudflared`) handles SSL, DDoS protection, and routing.
*   **Process Manager**: PM2 (Mastering Zero-Downtime via `ecosystem.config.js`)
*   **Hardware Monitoring (Cockpit)**: 
    *   **Direct URL**: `https://cockpit.jumpstartscaling.com`
    *   **Username**: `opc`
    *   **Password**: `JumpStartAdmin2026!` (Set on 2026-01-10)

---

## 2. Process Map & Ecosystem (`/home/opc/ecosystem.config.js`)
The `ecosystem.config.js` acts as the **Single Source of Truth** for all running applications. It locks Node.js versions via absolute NVM paths to prevent breaking changes during global updates.

| Name | Port | Type | CWD | Interpreter |
| :--- | :--- | :--- | :--- | :--- |
| **jumpstart-prod** | `8100` | Astro (Preview) | `~/sites/jumpstartscaling` | Node v20.19.6 |
| **chrisamaya-prod**| `8101` | Astro (Dev Mode) | `~/sites/chrisamaya` | Node v20.19.6 |
| **god-mode-api**   | `8200` | Django CMS | `~/universe/god-mode` | Python 3.11 |
| **ion-brain**      | `8001` | FastAPI AI | `~/universe/ion-brain` | .venv/python |
| **ion-console**    | `3000` | Next.js | `~/universe/ion/console`| Node v20.19.6 |
| **payload-cms**    | `4000` | Payload CMS | `~/payload-cms` | Node v20.19.6 |
| **ion-n8n**        | `5678` | Workflow | `~/universe` | Node v20.19.6 |
| **server-health**  | `8088` | Health API | `~/universe` | Python 3.11 |

---

## 3. Deployment Workflows

### ☢️ The "Nuclear" Strategy (Astro Frontends)
Astro generates unique hashes for CSS/JS. To prevent stale-state issues:
1.  **Sync**: `rsync` or `scp` source code to `~/sites/[site]`.
2.  **Purge**: `rm -rf dist` (Crucial: Forces fresh bundle generation).
3.  **Build**: `npm run build`.
4.  **Reload**: `pm2 reload [app-name]` (Zero-downtime transition).

### ⚙️ Backend Logic
Frontends are proxied via **Cloudflare Tunnel Ingress Rules**.
*   **Configuration Path**: `/etc/cloudflared/config.yml`
*   **Reload Tunnel**: `sudo systemctl restart cloudflared`

---

## 4. Monitoring & observability

### 🖥️ Native Management (Cockpit)
Cockpit is installed and running on port **9090**, proxied via the Tunnel.
*   **Interface**: `https://cockpit.jumpstartscaling.com`
*   **Alternative**: `https://jumpstartscaling.com:9090` (Only works if Cloudflare Proxy is DISABLED or using server IP).
*   **Features**: File browsing (Terminal-free editing), service management, and ARM64 core utilization tracking.

### 🏥 Programmable Health API
A custom FastAPI watchdog monitors PM2 process status and tunnel health.
*   **Endpoints**:
    *   **N8N**: `https://n8n.jumpstartscaling.com`
    *   **God Mode API**: `https://api.jumpstartscaling.com/health/`
    *   **Diagnostics**: `GET http://localhost:8088/health` (Internal diagnostic only).

---

## 5. Security Architecture
1.  **Identity-First Networking**: Cloudflare Tunnel creates a secure outbound connection. No public ingress ports besides SSH (22) and Cockpit (9090) are strictly required.
2.  **Port Hardening**:
    *   **Redis (6379)**: (Action Recommended) Bind to `127.0.0.1`.
    *   **Postgres (5432)**: Bound to `127.0.0.1` (Safe).
    *   **Ollama (11434)**: Bound to `0.0.0.0` (Use for internal AI networking, block externally).
3.  **OS Hardening**: Oracle Linux 10 utilizes SELinux and firewalld (pre-configured for Cockpit).

---

## 6. Network Topology (Visual Flow)
1.  **Public Ingress**: `Internet` -> `Cloudflare` -> `cloudflared (QUIC Tunnel)` -> `Local Ports`.
2.  **Internal Fabric**:
    *   **Port 8100**: Jumpstart Hosting (Production).
    *   **Port 8200**: God Mode Core (Data Orchestration).
    *   **Port 3000**: Console UI (Administrative Dashboard).
    *   **Port 5678**: Automation Engine (n8n).
    *   **Port 9090**: System Management (Cockpit).
3.  **Data Tier**:
    *   **PostgreSQL**: `localhost:5432` (Auth & User Data).
    *   **Redis**: `localhost:6379` (Caching & Task Queues).

---

## 7. Maintenance Reference (Senior Engineer Quick-Start)
```bash
# Update everything safely
cd ~
pm2 reload ecosystem.config.js --update-env

# Check unified logs
pm2 logs

# View Health JSON
curl localhost:8088/health | jq

# Manage OS via CLI
sudo cockpit-bridge --version
```

---

## 8. Future Road Map
*   **Log Consolidation**: Implement `pm2-logrotate` (Already installed) to prevent 50GB boot volume saturation.
*   **Database Scaling**: Migrating from SQLite (where used) to the existing PostgreSQL 15 instance.
*   **CI/CD**: Integrating the Health API with GitHub Actions for automated "Nuclear" deployments.
