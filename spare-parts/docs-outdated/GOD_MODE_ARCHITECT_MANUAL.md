# God Architect: System Manual & Architecture

**System:** Spark God Mode (Admin & Factory)
**Architect:** "The Architect" (AI Agent)
**Date:** December 20, 2025

---

## 1. System Overview

God Mode is a hybrid administrative interface and autonomous factory system designed for the Spark Platform. It bridges the gap between a high-level visual control center (React/Astro) and low-level logic execution (Python/FastAPI).

### Core Components

1.  **The Deck (Frontend)**
    *   **Framework**: Astro + React + Tailwind CSS.
    *   **Location**: `src/pages/admin/*`
    *   **Role**: Visual interface, user input, monitoring.
    *   **Key Page**: `Control Room` (/admin/control-room) - The central switchboard.

2.  **The Bridge (Middleware)**
    *   **Tech**: FastAPI (Python).
    *   **File**: `god_architect_local/forever_connection.py`.
    *   **Port**: `8505` (Localhost).
    *   **Role**: Proxies requests between the frontend and the heavy logic engines. Manages local configuration.

3.  **The Bedrock (Database)**
    *   **Tech**: PostgreSQL + Directus.
    *   **Role**: The single source of truth for "Real" data (Campaigns, Sites, Articles).

4.  **The Factory (Logic)**
    *   **Tech**: Python Scripts (`god_architect_local/*.py`).
    *   **Role**: Content generation, auto-healing, SEO analysis.

---

## 2. Data Flow & Truth Sources

To ensure system integrity, it is critical to distinguish between Real Data and Mock Data.

### A. Real Data (Production Grade)
*   **PostgreSQL**: All Campaign, Site, and Article data is real.
    *   *Access*: Via Directus SDK (`src/lib/directus.ts`) or Direct SQL Bridge.
*   **Configuration**: `god_architect_local/master_config.json`.
    *   *Status*: **Real**. This JSON file is the source of truth for the local Control Room state.
    *   *API*: Accessed via `http://localhost:8505/api/config`.

### B. Mock Data (To Be Deprecated)
*   **SystemStatus.tsx**: Some legacy status indicators may use randomizers. *Action*: Replace with `GET /api/status` from Bridge.
*   **Hardcoded JSON**: `HUDItems.json` is "Real" in the sense that it defines the menu structure, but it is static. *Action*: Keep static for performance, update via git.

---

## 3. The Python Bridge (FastAPI)

The **Forever Connection** (`forever_connection.py`) is the heartbeat of local development.

### How it Works
1.  **Startup**: Runs `uvicorn` on port 8505.
2.  **Config**: Loads `master_config.json` on startup.
3.  **Endpoints**:
    *   `GET /`: Health check.
    *   `GET /api/config`: Returns the JSON config.
    *   `POST /api/config/update`: Writes to the JSON config.
    *   `POST /api/tasks/*`: Triggers heavy python tasks (e.g., `FactoryControl.task_a_awaken_all`).
4.  **Auto-Reload**: When running with `--reload`, changes to `.py` files restart the server. Changes to `.json` files do NOT restart the server but are read fresh on each request (via `load_config` helper).

### Extension Guide
To add a new feature (e.g., "Deep Research Mode"):
1.  **Frontend**: Add toggle to `FeatureControl.tsx`. Map it to a new key (e.g., `research_mode`).
2.  **Config**: Add default value to `master_config.json` (`"research_mode": false`).
3.  **Bridge**: If the feature requires backend logic, add a listener or check `load_config()['research_mode']` before executing tasks.

---

## 4. API Reference (Port 8505)

### Configuration
| Method | Path | Description | Payload |
|:---|:---|:---|:---|
| GET | `/api/config` | Get full system config | - |
| POST | `/api/config/update` | Update a config value | `{ "section": "logic_engine", "key": "status", "value": "inactive" }` |
| POST | `/api/config/reset` | Reset to factory defaults | - |

### Tasks
| Method | Path | Description | Payload |
|:---|:---|:---|:---|
| POST | `/api/tasks/awaken-all` | Run generic maintenance | - |
| POST | `/api/tasks/ignite` | Start content generation | `{ "siteId": "123" }` |
| GET | `/api/tasks/backup` | Dump DB schema to Downloads | - |
