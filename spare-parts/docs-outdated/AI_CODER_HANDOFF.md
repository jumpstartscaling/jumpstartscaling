# 🤖 AI Coder Handoff - Jumpstart Scaling & Tenant Sites

> **Last Updated**: January 6, 2026
> **Author**: Antigravity (Google DeepMind)
> **Goal**: Enable next coder/AI to take over development of tenant sites initiated on Oracle ARM64 server.

---

## 🌍 Current Status
Two static Astro sites are successfully deployed and live via Cloudflared Tunnel.

1.  **Jumpstart Scaling**
    *   **URL**: [jumpstartscaling.com](https://jumpstartscaling.com)
    *   **Path**: `/home/opc/sites/jumpstartscaling/`
    *   **Port**: `8100`
    *   **State**: **Stable (V2 Logic + Content Updates)**. The site displays the required 6 services using a glassmorphic grid layout.
    *   **Caveat**: An advanced "Feature Section" design (V3-V6) was attempted but rolled back due to a persistent environment-specific build error (`Expected "}" but found ";"`) in the Astro/Esbuild pipeline on the server.

2.  **Chris Amaya Portfolio**
    *   **URL**: [chrisamaya.work](https://chrisamaya.work)
    *   **Path**: `/home/opc/sites/chrisamaya/`
    *   **Port**: `8101`
    *   **State**: Stable.

---

## 🔑 Access & Environment

*   **Server**: Oracle Cloud ARM64 (`150.136.117.198`)
*   **User**: `opc` (SSH Key: `~/.ssh/id_rsa`)
*   **SSH Command**: `ssh opc@150.136.117.198`
*   **Web Server**: Nginx (Reverse Proxy to localized ports `8100`, `8101`)
*   **Tunnel**: Cloudflared (UUID: `54f5301e-76b0-48ff-8660-030accf4cfa8`)

---

## 🛠️ Development Workflow

To update a site (e.g., Jumpstart Scaling):

1.  **Edit Locally**: Modified `src/pages/index.astro`.
2.  **Upload**: `scp local_index.astro opc@150.136.117.198:/home/opc/sites/jumpstartscaling/src/pages/index.astro`
3.  **Build**: `ssh opc@150.136.117.198 "cd /home/opc/sites/jumpstartscaling && npm run build"`
4.  **Purge Cache**: (Optional) Purge Cloudflare cache if changes aren't visible.

---

## 🚧 Known Issues & Tasks

### 1. The "Feature Section" Layout (Blocking)
*   **Goal**: Replace the services grid with 6 full-width, alternating feature sections with code-art visuals.
*   **Problem**: Injecting the new CSS and HTML structure causes `npm run build` to fail with `[vite] Build failed... Expected "}" but found ";"`. This occurs even with valid CSS, suggesting a parser bug in the specific server environment or hidden character encoding issue.
*   **Solution Strategy for Next Coder**:
    *   Do **NOT** try to force the existing `index.astro` to accept the styles.
    *   **Action**: Create a completely NEW Astro project on the server (`/home/opc/sites/jumpstartscaling_v2`) using the standard "fresh" template, install dependencies, and migrate the content there. Then switch the Nginx root to point to the new build. This ensures a clean slate.

### 2. Assets on Server
I have left the intended design assets on the server for reference:
*   `/home/opc/sites/jumpstartscaling/partial_services.html`: The HTML structure for the 6 feature sections.
*   `/home/opc/sites/jumpstartscaling/partial_styles.css`: The CSS required for those sections.
*   `/home/opc/sites/jumpstartscaling/patch_site.sh`: A script intended to splice them (failed due to build error).

### 3. Image Generation Script
*   **User Note**: "There was image gen script and tools available already in there".
*   **Search Status**: `configure_directus_previews.py` was found in `god-mode`. Check `/home/opc/universe` on the server for other scripts.

### 4. n8n Webhook
*   **Task**: Update the placeholder URL in `index.astro`:
    ```javascript
    const n8n = 'https://n8n.jumpstartscaling.com/webhook/YOUR_UNIQUE_ID';
    ```
    Get the ID from the user and replace it.

---

## 📄 Reference Files
*   **Deployment Guide**: `TENANT_SITES_DEPLOYMENT.md` (detailed architecture).
*   **Current Live File**: `/home/opc/sites/jumpstartscaling/src/pages/index.astro` (V2).

---
**Summary for AI**: The site is functional but aesthetically simpler than the final vision. Use a "Fresh Install" strategy to implement the complex design to avoid legacy parser issues.
