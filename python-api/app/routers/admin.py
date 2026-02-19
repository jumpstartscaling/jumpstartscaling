"""Admin routes - lead list, Harris matrix CRUD, etc. No auth."""
import json

from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, JSONResponse

from app.config import config
from app.db.connection import get_db

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/leads", response_class=HTMLResponse)
async def admin_leads(request: Request):
    """Leads dashboard. No auth."""

    async with get_db() as conn:
        rows = await conn.fetch("SELECT * FROM leads ORDER BY created_at DESC LIMIT 500")

    def _row_html(row):
        badge = "ca" if (row.get("source") or "").lower() == "chrisamaya" else "js"
        dj = row.get("data_json") or {}
        if isinstance(dj, str):
            dj = json.loads(dj) if dj else {}
        extras = []
        if dj.get("industry"):
            extras.append(f'<div>🏭 {dj["industry"]}</div>')
        if dj.get("team"):
            extras.append(f'<div>👥 {dj["team"]}</div>')
        tracking = []
        if dj.get("utm_source"):
            tracking.append(f"Src: {dj['utm_source']}")
        if dj.get("utm_campaign"):
            tracking.append(f"Cmp: {dj['utm_campaign']}")
        if dj.get("page_url"):
            try:
                tracking.append(f"Page: {dj['page_url'].split('/')[-1] or '/'}")
            except Exception:
                pass
        if tracking:
            extras.append(
                f'<div style="margin-top:8px;font-size:0.75rem;color:#888;">{" • ".join(tracking)}</div>'
            )
        return f"""
            <tr>
                <td>{row["id"]}</td>
                <td><span class="badge {badge}">{row.get("source") or "-"}</span></td>
                <td>{row.get("name") or "-"}</td>
                <td><a href="mailto:{row.get("email") or ""}" style="color:#4da6ff">{row.get("email") or "-"}</a></td>
                <td>{row.get("phone") or "-"}</td>
                <td>
                    {f'<div>🌐 {row["website"]}</div>' if row.get("website") else ''}
                    {f'<div>💰 {row["revenue"]}</div>' if row.get("revenue") else ''}
                    {f'<div>⚠️ {row["problem"]}</div>' if row.get("problem") else ''}
                    {"".join(extras)}
                </td>
                <td>{row.get("created_at", "")}</td>
            </tr>
        """

    rows_html = "".join(_row_html(dict(r)) for r in rows)

    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Leads Dashboard</title>
        <style>
            body {{ font-family: sans-serif; background: #111; color: #eee; padding: 2rem; }}
            table {{ width: 100%; border-collapse: collapse; margin-top: 20px; }}
            th, td {{ border: 1px solid #333; padding: 12px; text-align: left; }}
            th {{ background: #222; color: #C9A961; }}
            tr:nth-child(even) {{ background: #1a1a1a; }}
            .badge {{ padding: 4px 8px; border-radius: 4px; font-size: 0.8rem; font-weight: bold; }}
            .js {{ background: #C9A961; color: #000; }}
            .ca {{ background: #00FF94; color: #000; }}
        </style>
    </head>
    <body>
        <h1>🚀 Leads Dashboard (God Mode API)</h1>
        <table>
            <thead>
                <tr>
                    <th>ID</th><th>Source</th><th>Name</th><th>Email</th><th>Phone</th><th>Details</th><th>Date</th>
                </tr>
            </thead>
            <tbody>{rows_html}</tbody>
        </table>
    </body>
    </html>
    """
    return HTMLResponse(html)


@router.get("/leads/json")
async def admin_leads_json(
    request: Request,
    limit: int = Query(50, le=500),
    offset: int = Query(0, ge=0),
):
    """JSON API for leads. No auth."""
    async with get_db() as conn:
        rows = await conn.fetch(
            "SELECT * FROM leads ORDER BY created_at DESC LIMIT $1 OFFSET $2",
            limit,
            offset,
        )
    return {"success": True, "leads": [dict(r) for r in rows]}


_ADMIN_STYLE = """
body { font-family: system-ui, sans-serif; background: #111; color: #eee; padding: 2rem; }
a { color: #C9A961; }
a:hover { text-decoration: underline; }
table { width: 100%; border-collapse: collapse; margin: 1rem 0; }
th, td { border: 1px solid #333; padding: 10px; text-align: left; }
th { background: #222; color: #C9A961; }
tr:nth-child(even) { background: #1a1a1a; }
input, textarea, select { padding: 6px; background: #222; color: #eee; border: 1px solid #444; }
button { padding: 8px 16px; background: #C9A961; color: #000; border: none; cursor: pointer; }
button.danger { background: #c33; color: #fff; }
.nav { margin-bottom: 2rem; }
.nav a { margin-right: 1rem; }
"""


@router.get("/", response_class=HTMLResponse)
async def admin_index():
    return HTMLResponse(f"""
    <!DOCTYPE html>
    <html><head><title>God Mode Admin</title><style>{_ADMIN_STYLE}</style></head>
    <body>
        <h1>🔱 God Mode Admin</h1>
        <nav class="nav">
            <a href="/admin/leads">Leads</a>
            <a href="/admin/locations">Locations</a>
            <a href="/admin/pseo-services">Services</a>
            <a href="/admin/content-matrix">Content Matrix</a>
            <a href="/admin/debug">Debug</a>
        </nav>
    </body></html>
    """)


@router.get("/locations", response_class=HTMLResponse)
async def admin_locations():
    async with get_db() as conn:
        rows = await conn.fetch("SELECT id, city, state, zip, neighborhood, slug FROM locations ORDER BY city, state")
    rows_html = "".join(
        f'<tr><td>{r["id"]}</td><td>{r["city"]}</td><td>{r["state"]}</td><td>{r["zip"] or ""}</td>'
        f'<td>{r["neighborhood"] or ""}</td><td>{r["slug"] or ""}</td><td></td></tr>'
        for r in rows
    )
    return HTMLResponse(f"""
    <!DOCTYPE html>
    <html><head><title>Locations</title><style>{_ADMIN_STYLE}</style></head>
    <body>
        <h1>Locations (Harris Matrix)</h1>
        <nav class="nav"><a href="/admin/">← Admin</a></nav>
        <table><thead><tr><th>ID</th><th>City</th><th>State</th><th>Zip</th><th>Neighborhood</th><th>Slug</th><th></th></tr></thead>
        <tbody>{rows_html}</tbody></table>
        <p>Use API: POST /api/locations?key=... with {{"city":"...","state":"..."}}</p>
    </body></html>
    """)


@router.get("/pseo-services", response_class=HTMLResponse)
async def admin_pseo_services():
    async with get_db() as conn:
        rows = await conn.fetch("SELECT id, service_type, sub_niche, slug FROM pseo_services ORDER BY service_type")
    rows_html = "".join(
        f'<tr><td>{r["id"]}</td><td>{r["service_type"]}</td><td>{r["sub_niche"] or ""}</td><td>{r["slug"] or ""}</td></tr>'
        for r in rows
    )
    return HTMLResponse(f"""
    <!DOCTYPE html>
    <html><head><title>pSEO Services</title><style>{_ADMIN_STYLE}</style></head>
    <body>
        <h1>pSEO Services</h1>
        <nav class="nav"><a href="/admin/">← Admin</a></nav>
        <table><thead><tr><th>ID</th><th>Service Type</th><th>Sub Niche</th><th>Slug</th></tr></thead>
        <tbody>{rows_html}</tbody></table>
        <p>Use API: POST /api/pseo-services?key=... with {{"service_type":"..."}}</p>
    </body></html>
    """)


@router.get("/content-matrix", response_class=HTMLResponse)
async def admin_content_matrix():
    async with get_db() as conn:
        rows = await conn.fetch(
            "SELECT cm.id, cm.slug, cm.title, l.city, l.state, ps.service_type FROM content_matrix cm "
            "LEFT JOIN locations l ON cm.location_id = l.id LEFT JOIN pseo_services ps ON cm.service_id = ps.id "
            "ORDER BY cm.slug LIMIT 200"
        )
    rows_html = "".join(
        f'<tr><td>{r["id"]}</td><td>{r["slug"]}</td><td>{(r["title"] or "")[:60]}...</td>'
        f'<td>{r["city"] or ""} {r["state"] or ""}</td><td>{r["service_type"] or ""}</td></tr>'
        for r in rows
    )
    return HTMLResponse(f"""
    <!DOCTYPE html>
    <html><head><title>Content Matrix</title><style>{_ADMIN_STYLE}</style></head>
    <body>
        <h1>Content Matrix (pSEO)</h1>
        <nav class="nav"><a href="/admin/">← Admin</a></nav>
        <table><thead><tr><th>ID</th><th>Slug</th><th>Title</th><th>Location</th><th>Service</th></tr></thead>
        <tbody>{rows_html}</tbody></table>
        <p>Use API: POST /api/content-matrix?key=... or seed_from_exports.py</p>
    </body></html>
    """)


@router.get("/debug", response_class=HTMLResponse)
async def admin_debug():
    """Debug panel: env info, api_logs, health. Session-protected."""
    import os
    from urllib.parse import urlparse

    env_safe = {}
    for k in ("DATABASE_URL", "ADMIN_KEY", "ADMIN_USERNAME", "ADMIN_PASSWORD", "DEBUG", "LOG_REQUESTS", "HOST", "PORT"):
        v = os.getenv(k, "")
        if k == "DATABASE_URL" and v:
            try:
                u = urlparse(v)
                env_safe[k] = f"{u.scheme}://{u.hostname}:{u.port or 5432}/{u.path.lstrip('/')}" if u.hostname else "[set]"
            except Exception:
                env_safe[k] = "[set]" if v else ""
        elif k == "ADMIN_KEY":
            env_safe[k] = "***" if v else "[empty]"
        elif k == "ADMIN_PASSWORD":
            env_safe[k] = "***" if os.getenv("ADMIN_PASSWORD") else "[empty]"
        elif k in ("DEBUG", "LOG_REQUESTS"):
            env_safe[k] = str(config.DEBUG if k == "DEBUG" else config.LOG_REQUESTS)
        else:
            env_safe[k] = v or "[empty]"

    api_logs = []
    try:
        async with get_db() as conn:
            rows = await conn.fetch(
                "SELECT id, endpoint, method, status, created_at FROM api_logs ORDER BY created_at DESC LIMIT 50"
            )
            api_logs = [dict(r) for r in rows]
    except Exception as e:
        api_logs = [{"error": str(e)}]

    health_status = "ok"
    try:
        async with get_db() as conn:
            await conn.fetchval("SELECT 1")
    except Exception as e:
        health_status = f"db error: {e}"

    rows_html = ""
    if api_logs and "error" not in api_logs[0]:
        rows_html = "".join(
            f'<tr><td>{r["id"]}</td><td>{r.get("endpoint","")}</td><td>{r.get("method","")}</td>'
            f'<td>{r.get("status","")}</td><td>{r.get("created_at","")}</td></tr>'
            for r in api_logs
        )
    else:
        rows_html = f'<tr><td colspan="5">{api_logs[0].get("error","No logs")}</td></tr>' if api_logs else '<tr><td colspan="5">No api_logs table</td></tr>'

    return HTMLResponse(f"""
    <!DOCTYPE html>
    <html><head><title>Debug Panel</title><style>{_ADMIN_STYLE}</style></head>
    <body>
        <h1>Debug Panel</h1>
        <nav class="nav"><a href="/admin/">← Admin</a></nav>
        <h2>Config (safe)</h2>
        <pre>{json.dumps(env_safe, indent=2)}</pre>
        <h2>Health</h2>
        <p>{health_status}</p>
        <h2>Recent api_logs (last 50)</h2>
        <table><thead><tr><th>ID</th><th>Endpoint</th><th>Method</th><th>Status</th><th>Created</th></tr></thead>
        <tbody>{rows_html}</tbody></table>
    </body></html>
    """)
