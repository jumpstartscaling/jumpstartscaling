# God Mode: Python & JSON Catalog

**Purpose**: This document maps the relationship between Python logic scripts and their dependency files (JSON/SQL). Use this catalog to understand where data is sourced and how to update the system capabilities.

---

## 1. Python Scripts (Logic Engines)
*Location: `god_architect_local/`*

### `forever_connection.py` (The Bridge)
*   **Role**: FastAPI Server, primary interface for usage.
*   **Port**: 8505.
*   **Dependencies**:
    *   `master_config.json`: (Read/Write) Stores system toggles and status.
    *   `awaken_bedrock.sql`: (Read) Basic SQL init script (optional).
    *   `awaken_interfaces.sql`: (Read) Directus Interface definitions (optional).
*   **Key Classes**: `FactoryControl` (Task Router), `ConfigUpdate` (Pydantic Model).

### `god_architect_master.py`
*   **Status**: DEPRECATED / Empty.
*   **Note**: Functionality has been migrated to `forever_connection.py`.

### `tunnel_manager.py` (Hypothetical/Planned)
*   **Role**: Manages Cloudflared or Ngrok tunnels.
*   **Dependencies**:
    *   `tunnels.json` (Proposed): To store tunnel URLs and PIDs.

---

## 2. Data Sources (JSON/SQL)

### `master_config.json`
*   **Location**: `god_architect_local/master_config.json`
*   **Structure**:
    ```json
    {
      "system_status": "operational",
      "logic_engine": { ... },
      "security_sentinel": { ... },
      "telemetry": { ... }
    }
    ```
*   **Managed By**: `forever_connection.py` (API).
*   **Usage**: The 'Control Room' UI reads this to display ON/OFF states.

### `generated_data/*.json` (Output)
*   **Note**: The Python engines typically output generation results (articles, images) to a `generated_data` or `velocity_exports` directory.
*   **Status**: Transient/Temp data.

---

## 3. Frontend Data Catalog
*Location: `src/`*

### `src/components/admin/HUD/HUDItems.json`
*   **Role**: Static Menu Definition for Global HUD.
*   **Content**: List of menu groups ("Command Deck", "Production") and items.
*   **Edit Policy**: Manual Edit. Code changes required to add new icons (`GlobalHUD.astro` import).

### `src/consts.ts` (or similar)
*   **Role**: Often contains Title/Desc constants.
*   **Verdict**: Should move dynamic config to Database or `master_config.json`.

---

## 4. Expansion Guide

### Adding a New Data Source
If you need to add a new logic configuration (e.g., "AI Personas"):
1.  **Create JSON**: `god_architect_local/personas.json`.
2.  **Update Python**: In `forever_connection.py`:
    ```python
    PERSONAS_PATH = Path("god_architect_local/personas.json")
    @app.get("/api/personas")
    def get_personas():
        return json.loads(PERSONAS_PATH.read_text())
    ```
3.  **Update Config**: Add reference in `master_config.json` if it needs a global toggle.

### Database Integration
For robust expansion, prefer **PostgreSQL/Directus** over JSON files.
*   **Pattern**:
    1.  Create Collection in Directus (e.g., `god_personas`).
    2.  In Python, use `requests` or `asyncpg` to query Directus/DB.
    3.  Expose data via `forever_connection.py` API endpoints.
    4.  Frontend consumes API.
