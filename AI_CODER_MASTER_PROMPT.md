# 🤖 AI Coder Master Prompt & Developer Instructions

> **Copy and paste this entire document into your AI chat context to instantly onboard it to this project.**

---

## 🚀 Project Overview: "Spark" Tenant Ecosystem
You are working on a multi-site ecosystem hosted on an Oracle Cloud ARM64 server. The system consists of two front-end sites and one shared backend API, all exposed via a Cloudflare Tunnel.

### 🌍 Live Sites
1.  **Jumpstart Scaling** (Business Site)
    *   **URL**: [https://jumpstartscaling.com](https://jumpstartscaling.com)
    *   **Local Path**: `./sites/jumpstartscaling/`
    *   **Remote Path**: `/home/opc/sites/jumpstartscaling/`
    *   **Port**: `8100` (Proxy to Tunnel)
    *   **Stack**: Astro v5 + React (Framework Mode)

2.  **Chris Amaya Portfolio** (Personal Site)
    *   **URL**: [https://chrisamaya.work](https://chrisamaya.work)
    *   **Local Path**: `./sites/chrisamaya/`
    *   **Remote Path**: `/home/opc/sites/chrisamaya/`
    *   **Port**: `8101` (Proxy to Tunnel)
    *   **Stack**: Astro v5 + React (Framework Mode)

3.  **Backend API**
    *   **URL**: [https://api.jumpstartscaling.com](https://api.jumpstartscaling.com)
    *   **Docs**: [https://api.jumpstartscaling.com/docs](https://api.jumpstartscaling.com/docs)
    *   **Tech**: Python (FastAPI/Django)
    *   **Usage**: Accessible globally. Use standard `fetch` from the frontend components.

---

## 🛠️ Development Workflow (How to Edit & Deploy)

**DO NOT** attempt to SSH into the server to edit files manually. The server is configured to run in "Dev Mode" via PM2 to allow instant updates.

### Step-by-Step Guide
1.  **Edit Locally**:
    *   The source code is in the `./sites/` folder in the root of the workspace.
    *   Create ASTRO pages in `src/pages/`.
    *   Create REACT components in `src/components/`.
    *   Use `.jsx` or `.tsx` extension for React.

2.  **Deploy (Sync)**:
    *   We do **not** run a build pipeline (yet). We sync the source files, and the server's dev watcher picks them up instantly.
    *   **Command**:
        ```bash
        ./sync_sites.sh
        ```
    *   *Note: This script rsyncs the `src`, `public`, and `package.json` files to the server.*

3.  **Verify**:
    *   Visit the live URLs. Changes should appear within seconds.

---

## ⚠️ Critical Constraints & Rules (DO NOT BREAK)

1.  **Vite Configuration (`astro.config.mjs`)**:
    *   **ISSUE**: Cloudflare Tunnels block requests unless the Host header is explicitly allowed in Vite.
    *   **RULE**: If you modify `astro.config.mjs`, you **MUST** retain the `allowedHosts` array.
    *   *Example Safe Config*:
        ```javascript
        vite: {
          server: {
            allowedHosts: ['jumpstartscaling.com', 'www.jumpstartscaling.com', 'localhost']
          }
        }
        ```

2.  **Server Process Management**:
    *   The sites are kept alive by **PM2**.
    *   Service Names: `jumpstart-v2`, `chrisamaya-v2`.
    *   If the site goes down, restart it via SSH:
        ```bash
        ssh opc@150.136.117.198 "pm2 restart jumpstart-v2 chrisamaya-v2"
        ```

3.  **Assets & Visuals**:
    *   The user wants "Visual Excellence". Use **Astro Layouts** and **React Components** with clear CSS or Tailwind (if installed later, currently standard CSS).
    *   Do **not** use a CMS. The data source is the API + Hardcoded Visuals.

---

## 🔌 Integrating the API
You have direct access to the backend. No authentication is currently required for public endpoints.

**Example React Component Pattern**:
```jsx
// src/components/ServiceStatus.jsx
import React, { useEffect, useState } from 'react';

export default function ServiceStatus() {
  const [status, setStatus] = useState("Loading...");

  useEffect(() => {
    fetch('https://api.jumpstartscaling.com/')
      .then(res => res.json())
      .then(data => setStatus(data.status || "Active"));
  }, []);

  return <div className="status-badge">System Status: {status}</div>;
}
```

---

## 📂 File Structure Map
```text
god-mode/
├── sites/                      <-- WORK HERE
│   ├── jumpstartscaling/
│   │   ├── src/
│   │   │   ├── components/     <-- React Components go here
│   │   │   ├── layouts/
│   │   │   └── pages/          <-- .astro files
│   │   └── astro.config.mjs    <-- CAREFUL WITH THIS
│   └── chrisamaya/
│       └── ...
├── sync_sites.sh               <-- RUN THIS TO DEPLOY
└── AI_CODER_MASTER_PROMPT.md   <-- THIS FILE
```


---

## 📚 Compatible & Recommended Libraries

The following libraries are fully compatible with this **Astro + React** stack and are recommended for "High-End" visual effects.

### 1. Styling & UI
*   **Tailwind CSS**: `npm install -D tailwindcss @tailwindcss/vite` (Requires config update)
*   **Vanilla CSS**: (Currently in use). Good for custom glassmorphism.
*   **Lucide React**: `npm install lucide-react` (Best for icons).
*   **Radix UI**: `npm install @radix-ui/react-*` (Accessible primitives).

### 2. Animations
*   **Framer Motion**: `npm install framer-motion` (Standard for complex React animations).
*   **GSAP**: `npm install gsap` (For timeline-based robust animations).
*   **AOS (Animate on Scroll)**: `npm install aos` (Simple scroll fades).

### 3. State & Logic
*   **Nanostores**: `npm install nanostores @nanostores/react` (Best for state between Astro/React).
*   **React Hook Form**: `npm install react-hook-form` (For complex forms/surveys).
*   **Zod**: `npm install zod` (Validation).

---

## 📦 How to Add New Libraries (Dependencies)
Since we are syncing files but **excluding** `node_modules`, you must install dependencies in **BOTH** locations if you add them.

**Workflow for adding `framer-motion` (Example):**

1.  **Install Locally**:
    ```bash
    cd sites/jumpstartscaling
    npm install framer-motion
    ```

2.  **Install on Server**:
    ```bash
    ssh opc@150.136.117.198 "cd /home/opc/sites/jumpstartscaling && npm install framer-motion"
    ```

3.  **Restart Server Process**:
    ```bash
    ssh opc@150.136.117.198 "pm2 restart jumpstart-v2"
    ```

---

**End of Prompt. Ready for instructions.**
