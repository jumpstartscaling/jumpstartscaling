# God Mode Factory Implementation Plan: "The Awakened Container"

This document outlines the systematic upgrade of the God-Mode Container to include a "Nervous System" (FastAPI) and a "Control Room" (Global HUD & Sector Management), transforming it into a high-performance, interconnected factory.

## 🔱 Phase 1: The Nervous System (FastAPI Integration)

We will integrate FastAPI directly into the existing God-Mode container to act as the internal logic gatekeeper and high-speed bridge.

### 1.1 Docker Architecture Upgrade
*   **Goal**: Expose Port `8000` and ensure Python/Node coexistence.
*   **Action**: Update `docker-compose.yml` and `Dockerfile`.
    *   Add `8000:8000` to ports.
    *   Install `python3`, `pip`, `fastapi`, `uvicorn`, `psycopg2-binary`.
    *   Create `entrypoint.sh` to launch both Astro (Port 4321) and FastAPI (Port 8000).

### 1.2 The Air-Lock (API Core)
*   **Goal**: Secure, authenticated internal API for factory commands.
*   **Location**: `/app/api/main.py` (inside container).
*   **Features**:
    *   **Auth**: `verify_god_access` logic using `GOD_MODE_TOKEN`.
    *   **Bedrock Endpoint**: `POST /god/sql/execute` for raw SQL injection (used by "Awaken").
    *   **Ignition Endpoint**: `POST /god/engines/ignite` for triggering Python scripts.
    *   **Quality Control Endpoint**: `POST /god/engines/deep-diagnostic` for site health audits.

## 🔱 Phase 2: The Logic Engines (Python Muscle)

We will migrate local scripts into the container's specialized engine room.

### 2.1 Engine Modules
*   **Location**: `/app/api/engines/`.
*   **Modules**:
    *   `auto_heal.py`: The sentinel logic that executes "Soft Fix" SQL.
    *   `diagnostic.py`: The auditor that identifies 404s and orphan pages.
    *   `generator.py`: The content creation logic.

### 2.2 The "Forever Connection" Bridge
*   **Goal**: Ensure the local Mac (Port 8505) routes commands to the remote Container (Port 8000).
*   **Action**: Update local `forever_connection.py` (the version on your Mac) to point its tasks to `https://api.jumpstartscaling.com` (or the tunnel URL) instead of just logging locally.

## 🔱 Phase 3: The Face Upgrade (Control Room & HUD)

We will replace the sidebar with a high-fidelity "Heads-Up Display" and a dedicated Control Room.

### 3.1 Global HUD Navigation
*   **New Component**: `src/components/admin/GlobalHUD.astro`.
*   **Features**: Top-fixed navbar, multi-level dropdowns for "Factory Floors" and "Engine Rooms".
*   **Action**: Replace `<aside>` in `AdminLayout.astro` with `<GlobalHUD />`.

### 3.2 The Control Room Page
*   **New Page**: `src/pages/admin/control-room.astro`.
*   **Features**:
    *   **Sector Grid**: Visual cards for Logic, Security, Data, Telemetry.
    *   **Feature Control**: Toggle switches (enabled/disabled) for each subsystem.
    *   **Master Reset**: A "Factory Default" button to re-enable everything.

### 3.3 Diagnostic & Repair Console
*   **New Components**: `RepairConsole.tsx` and `SentinelToggle.tsx`.
*   **Features**:
    *   One-click SQL Clipboard for manual fixes.
    *   "Activate Sentinel" toggle for autonomous self-healing.

## 🔱 Phase 4: Persistence (Master Config)

We will ensure your dashboard preferences live forever on your local machine.

### 4.1 Local Config Bedrock
*   **File**: `god_architect_local/master_config.json` (NOGIT).
*   **Logic**: Your local Python bridge will read/write to this file.
*   **Sync**: The Astro frontend will fetch this config on load to determine which features to show/hide.

## 🚀 Execution Sequence

1.  **Local Prep**: Create the new Astro components (HUD, Control Room) and Python logic logic locally.
2.  **Container Prep**: Update the `Dockerfile` and `entrypoint.sh`.
3.  **Deployment**: Push to Git. Coolify will rebuild the container with the new "Nervous System."
4.  **Awakening**:
    *   Operator clicks "Master Reset" in the new Control Room.
    *   Sentinel is activated.
    *   Factory is fully online.

