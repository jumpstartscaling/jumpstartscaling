# 🚀 System Setup Confirmation Guide (AI Assistant Prompt)

**Purpose**: This document is a comprehensive checklist to confirm the Oracle Cloud ARM64 server setup is 100% operational. Use this content as a prompt for your AI Assistant (Gemini Pro) to help you verify and troubleshoot the environment.

---

### 📋 Phase 1: Live Domain Verification
Check if the following URLs resolve correctly in your browser:
- [ ] **Main Site**: `https://jumpstartscaling.com` (Should show the production Astro site).
- [ ] **Portfolio**: `https://chrisamaya.work` (Should show your personal portfolio).
- [ ] **Automation**: `https://n8n.jumpstartscaling.com` (Should load the n8n login/dashboard).
- [ ] **God Mode API (FastAPI)**: `https://api.jumpstartscaling.com/` (Should return `{"status":"active","service":"God Mode API"}`).

---

### 📋 Phase 2: Administrative Control Access
Verify that you can manage the server without using the terminal:
- [ ] **Cockpit GUI**: Visit `https://cockpit.jumpstartscaling.com`.
    - Login with your server credentials:
        - **User**: `opc`
        - **Password**: `JumpStartAdmin2026!`
    - Verify you can see **CPU/RAM graphs**.
    - Navigate to the **Files** tab and see `/home/opc/sites`.
- [ ] **Process Management**:
    - In Cockpit, go to the **Services** tab.
    - Search for `pm2-opc`. Ensure it is active.

---

### 📋 Phase 3: Infrastructure Health (The "Heartbeat")
Run these checks inside the server (or via Cockpit Terminal) to ensure the backend logic is sound:

1.  **Process Consistency**:
    ```bash
    pm2 status
    ```
    *Expectation*: You should see `jumpstart-prod`, `chrisamaya-prod`, `god-mode-api`, and `server-health` all showing `online`.

2.  **Diagnostics API**:
    ```bash
    curl http://localhost:8088/health | jq
    ```
    *Expectation*: A clean JSON output showing `tunnel: ONLINE` and a list of all 15+ PM2 processes with their memory/CPU usage.

3.  **Deployment Configuration**:
    ```bash
    cat ~/ecosystem.config.js
    ```
    *Expectation*: Ensure paths point to `/home/opc/.nvm/versions/node/v20.19.6/bin/node` to confirm version-locking is in place.

---

### 🛠️ Troubleshooting for AI Assistants
If any of the above fails, check these three common blockers:
1.  **Tunnel Down?**: `sudo systemctl status cloudflared`
2.  **Port Conflict?**: `sudo netstat -tulpn | grep LISTEN` (Check if ports 8100, 8101, 8200, 9090 are occupied).
3.  **Build Missing?**: If the site shows a 404 but PM2 is online, go to `~/sites/[site]` and run `npm run build`.

---

### 📜 Summary for Senior Engineering
- **Architecture**: Astro (Frontend) + Django/FastAPI (Backend) + n8n/Postgres/Redis (Core Services).
- **Versioning**: Node.js v20.19.6 (LTS), Python 3.11.
- **Entry Points**: 100% proxied through Cloudflare Tunnel with Cockpit as the native management layer.
