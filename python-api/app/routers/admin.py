"""Admin routes - lead list, Harris matrix CRUD, etc. No auth."""
import json
import os
import time
import uuid
from urllib.parse import urlparse
from fastapi import APIRouter, Request, Query, Body
from fastapi.responses import HTMLResponse, JSONResponse

from fastapi import Header, HTTPException

from app.config import config
from app.db.connection import get_db, run_schema, DatabaseUnavailableError

router = APIRouter(prefix="/admin", tags=["admin"])
api_router = APIRouter(prefix="/api", tags=["admin"])


async def _get_debug_data():
    """Shared debug data: config, health, api_logs. Used by HTML and JSON endpoints."""
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

    return {"config": env_safe, "health": health_status, "api_logs": api_logs}


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


@api_router.get("/debug")
async def api_debug():
    """JSON debug endpoint: config, health, api_logs. Used by Astro admin Debug page."""
    return await _get_debug_data()


@api_router.get("/counts")
async def api_counts():
    """Counts for intelligence and collections dashboards."""
    async with get_db() as conn:
        out = {}
        for table in [
            "avatar_intelligence", "avatar_variants", "geo_intelligence",
            "spintax_dictionaries", "cartesian_patterns",
            "page_blocks", "offer_blocks", "headline_inventory", "content_fragments",
        ]:
            n = await conn.fetchval(f"SELECT COUNT(*) FROM {table}")
            out[table] = n or 0
    return out


@api_router.get("/generation-jobs")
async def api_generation_jobs(limit: int = 200):
    """List generation jobs for factory kanban."""
    async with get_db() as conn:
        rows = await conn.fetch(
            "SELECT id, status, target_quantity, progress, site_id, campaign_id FROM generation_jobs ORDER BY id DESC LIMIT $1",
            min(limit, 500),
        )
        return [dict(r) for r in rows]


@api_router.get("/analytics/summary")
async def api_analytics_summary():
    """Analytics summary from events, pageviews, conversions tables."""
    async with get_db() as conn:
        events_n = await conn.fetchval("SELECT COUNT(*) FROM events")
        pageviews_n = await conn.fetchval("SELECT COUNT(*) FROM pageviews")
        conversions_n = await conn.fetchval("SELECT COUNT(*) FROM conversions")
    return {"events": events_n or 0, "pageviews": pageviews_n or 0, "conversions": conversions_n or 0}


async def _list_table(table: str, limit: int = 200):
    """List rows from table."""
    async with get_db() as conn:
        rows = await conn.fetch(f"SELECT * FROM {table} LIMIT $1", min(limit, 500))
        return [dict(r) for r in rows]


@api_router.get("/avatar-intelligence")
async def api_avatar_intelligence(limit: int = 200):
    return await _list_table("avatar_intelligence", limit)


@api_router.get("/avatar-variants")
async def api_avatar_variants(limit: int = 200):
    return await _list_table("avatar_variants", limit)


@api_router.get("/campaign-masters")
async def api_campaign_masters(limit: int = 200):
    return await _list_table("campaign_masters", limit)


@api_router.get("/cartesian-patterns")
async def api_cartesian_patterns(limit: int = 200):
    return await _list_table("cartesian_patterns", limit)


@api_router.get("/content-fragments")
async def api_content_fragments(limit: int = 200):
    return await _list_table("content_fragments", limit)


@api_router.get("/conversions")
async def api_conversions(limit: int = 200):
    return await _list_table("conversions", limit)


@api_router.get("/events")
async def api_events(limit: int = 200):
    return await _list_table("events", limit)


@api_router.get("/generated-articles")
async def api_generated_articles(limit: int = 200):
    return await _list_table("generated_articles", limit)


@api_router.get("/geo-intelligence")
async def api_geo_intelligence(limit: int = 200):
    return await _list_table("geo_intelligence", limit)


@api_router.get("/headline-inventory")
async def api_headline_inventory(limit: int = 200):
    return await _list_table("headline_inventory", limit)


@api_router.get("/offer-blocks")
async def api_offer_blocks(limit: int = 200):
    return await _list_table("offer_blocks", limit)


@api_router.get("/page-blocks")
async def api_page_blocks(limit: int = 200):
    return await _list_table("page_blocks", limit)


@api_router.get("/pages")
async def api_pages(limit: int = 200):
    return await _list_table("pages", limit)


@api_router.get("/pageviews")
async def api_pageviews(limit: int = 200):
    return await _list_table("pageviews", limit)


@api_router.get("/public/posts")
async def api_public_posts(site_url: str = Query(..., alias="site_url")):
    """Resolve site by URL and return published posts."""
    domain = (site_url or "").strip()
    if not domain:
        return {"posts": [], "site_id": None}
    try:
        p = urlparse(domain if "://" in domain else f"https://{domain}")
        domain = p.hostname or domain
    except Exception:
        domain = domain
    async with get_db() as conn:
        row = await conn.fetchrow(
            "SELECT id FROM sites WHERE status = 'active' AND url ILIKE $1 LIMIT 1",
            f"%{domain}%",
        )
        if not row:
            return {"posts": [], "site_id": None}
        site_id = row["id"]
        rows = await conn.fetch(
            """
            SELECT id, title, slug, content, excerpt, published_at, created_at
            FROM posts
            WHERE site_id = $1 AND status = 'published'
            ORDER BY published_at DESC NULLS LAST, created_at DESC
            LIMIT 100
            """,
            site_id,
        )
    return {"posts": [dict(r) for r in rows], "site_id": str(site_id)}


@api_router.get("/posts")
async def api_posts(limit: int = 200, site_id: str | None = Query(None, alias="site_id")):
    """List posts. Optional site_id filter."""
    limit = min(limit, 500)
    if not site_id:
        return await _list_table("posts", limit)
    async with get_db() as conn:
        rows = await conn.fetch(
            "SELECT * FROM posts WHERE site_id = $1::uuid ORDER BY published_at DESC NULLS LAST LIMIT $2",
            uuid.UUID(site_id),
            limit,
        )
        return [dict(r) for r in rows]


@api_router.get("/scheduled-tasks")
async def api_scheduled_tasks(limit: int = 200):
    return await _list_table("scheduled_tasks", limit)


# --- Sites resolve (TTL 60s) ---
_resolve_cache: dict[str, tuple[dict, float]] = {}
RESOLVE_TTL = 60


@api_router.get("/sites/resolve")
async def api_sites_resolve(domain: str = Query(..., alias="domain")):
    """Resolve domain to site. Returns site_id, status, theme_config. TTL 60s."""
    domain = (domain or "").strip().lower()
    if not domain:
        return {"found": False, "site_id": None, "status": None, "theme_config": None}
    now = time.time()
    if domain in _resolve_cache:
        cached, expiry = _resolve_cache[domain]
        if now < expiry:
            return cached
    async with get_db() as conn:
        row = await conn.fetchrow(
            """
            SELECT id, status, theme_config FROM sites
            WHERE status = 'active' AND url ILIKE $1
            LIMIT 1
            """,
            f"%{domain}%",
        )
    if not row:
        out = {"found": False, "site_id": None, "status": None, "theme_config": None}
    else:
        theme = row.get("theme_config")
        if isinstance(theme, dict):
            pass
        elif isinstance(theme, str):
            try:
                theme = json.loads(theme) if theme else None
            except Exception:
                theme = None
        out = {
            "found": True,
            "site_id": str(row["id"]),
            "status": row.get("status"),
            "theme_config": theme,
        }
    _resolve_cache[domain] = (out, now + RESOLVE_TTL)
    return out


@api_router.get("/sites")
async def api_sites(limit: int = 200):
    return await _list_table("sites", limit)


@api_router.get("/spintax-dictionaries")
async def api_spintax_dictionaries(limit: int = 200):
    return await _list_table("spintax_dictionaries", limit)


@api_router.get("/work-log")
async def api_work_log(limit: int = 200):
    return await _list_table("work_log", limit)


# --- CRUD: content-fragments ---
@api_router.post("/content-fragments")
async def api_content_fragments_create(body: dict = Body(...)):
    cid = body.get("campaign_id")
    async with get_db() as conn:
        row = await conn.fetchrow(
            """
            INSERT INTO content_fragments (campaign_id, fragment_type, content_body, fragment_text, status)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING *
            """,
            uuid.UUID(cid) if cid else None,
            body.get("fragment_type", "block"),
            body.get("content_body") or body.get("fragment_text") or "",
            body.get("fragment_text") or body.get("content_body") or "",
            body.get("status", "active"),
        )
        return dict(row)


@api_router.delete("/content-fragments/{pk}")
async def api_content_fragments_delete(pk: str):
    async with get_db() as conn:
        await conn.execute("DELETE FROM content_fragments WHERE id = $1", uuid.UUID(pk))
    return {"deleted": pk}


# --- CRUD: avatar-variants ---
@api_router.post("/avatar-variants")
async def api_avatar_variants_create(body: dict = Body(...)):
    async with get_db() as conn:
        row = await conn.fetchrow(
            """
            INSERT INTO avatar_variants (avatar_key, variant_type, data)
            VALUES ($1, $2, $3)
            RETURNING *
            """,
            body.get("avatar_key"),
            body.get("variant_type", "default"),
            json.dumps(body.get("data", {})),
        )
        return dict(row)


@api_router.delete("/avatar-variants/{pk}")
async def api_avatar_variants_delete(pk: str):
    async with get_db() as conn:
        await conn.execute("DELETE FROM avatar_variants WHERE id = $1", uuid.UUID(pk))
    return {"deleted": pk}


# --- CRUD: cartesian-patterns ---
@api_router.post("/cartesian-patterns")
async def api_cartesian_patterns_create(body: dict = Body(...)):
    async with get_db() as conn:
        row = await conn.fetchrow(
            """
            INSERT INTO cartesian_patterns (pattern_key, pattern_type, data)
            VALUES ($1, $2, $3)
            RETURNING *
            """,
            body.get("pattern_key"),
            body.get("pattern_type", "default"),
            json.dumps(body.get("data", {})),
        )
        return dict(row)


@api_router.delete("/cartesian-patterns/{pk}")
async def api_cartesian_patterns_delete(pk: str):
    async with get_db() as conn:
        await conn.execute("DELETE FROM cartesian_patterns WHERE id = $1", uuid.UUID(pk))
    return {"deleted": pk}


# --- CRUD: campaign-masters ---
@api_router.post("/campaign-masters")
async def api_campaign_masters_create(body: dict = Body(...)):
    async with get_db() as conn:
        row = await conn.fetchrow(
            """
            INSERT INTO campaign_masters (site_id, name, status, headline_spintax_root, target_word_count)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING *
            """,
            uuid.UUID(body["site_id"]) if body.get("site_id") else None,
            body.get("name", "New Campaign"),
            body.get("status", "active"),
            body.get("headline_spintax_root"),
            body.get("target_word_count", 1500),
        )
        return dict(row)


@api_router.delete("/campaign-masters/{pk}")
async def api_campaign_masters_delete(pk: str):
    async with get_db() as conn:
        await conn.execute("DELETE FROM campaign_masters WHERE id = $1", uuid.UUID(pk))
    return {"deleted": pk}


# --- CRUD: scheduled-tasks ---
@api_router.post("/scheduled-tasks")
async def api_scheduled_tasks_create(body: dict = Body(...)):
    async with get_db() as conn:
        row = await conn.fetchrow(
            """
            INSERT INTO scheduled_tasks (site_id, campaign_id, task_type, scheduled_at, status, payload)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING *
            """,
            uuid.UUID(body["site_id"]) if body.get("site_id") else None,
            uuid.UUID(body["campaign_id"]) if body.get("campaign_id") else None,
            body.get("task_type", "generation"),
            body.get("scheduled_at"),
            body.get("status", "pending"),
            json.dumps(body.get("payload", {})),
        )
        return dict(row)


@api_router.delete("/scheduled-tasks/{pk}")
async def api_scheduled_tasks_delete(pk: str):
    async with get_db() as conn:
        await conn.execute("DELETE FROM scheduled_tasks WHERE id = $1", uuid.UUID(pk))
    return {"deleted": pk}


# --- PATCH: generated-articles (station transitions) ---
@api_router.patch("/generated-articles/{pk}")
async def api_generated_articles_patch(pk: str, body: dict = Body(...)):
    updates = {k: v for k, v in body.items() if k in ("status", "title", "slug", "meta_title", "meta_description", "is_published")}
    if not updates:
        raise HTTPException(400, "No valid fields to update")
    async with get_db() as conn:
        cols = list(updates.keys())
        set_clause = ", ".join(f'"{c}" = ${i+1}' for i, c in enumerate(cols)) + ", date_updated = NOW()"
        values = [updates[c] for c in cols] + [uuid.UUID(pk)]
        await conn.execute(
            f'UPDATE generated_articles SET {set_clause} WHERE id = ${len(values)}',
            *values,
        )
        row = await conn.fetchrow("SELECT * FROM generated_articles WHERE id = $1", uuid.UUID(pk))
        if not row:
            raise HTTPException(404, "Article not found")
        return dict(row)


# --- POST: generation-jobs ---
@api_router.post("/generation-jobs")
async def api_generation_jobs_create(body: dict = Body(...)):
    async with get_db() as conn:
        row = await conn.fetchrow(
            """
            INSERT INTO generation_jobs (site_id, campaign_id, target_quantity, status, source_type, source_article_ids)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING *
            """,
            uuid.UUID(body["site_id"]) if body.get("site_id") else None,
            uuid.UUID(body["campaign_id"]) if body.get("campaign_id") else None,
            body.get("target_quantity", 10),
            body.get("status", "pending"),
            body.get("source_type", "new"),
            json.dumps(body.get("source_article_ids") or []),
        )
        return dict(row)


# --- Bulk delete ---
@api_router.post("/generated-articles/bulk-delete")
async def api_generated_articles_bulk_delete(body: dict = Body(...)):
    ids = body.get("ids", [])
    if not ids:
        raise HTTPException(400, "ids required")
    uuids = [uuid.UUID(str(i)) for i in ids]
    async with get_db() as conn:
        for pk in uuids:
            await conn.execute("DELETE FROM generated_articles WHERE id = $1", pk)
    return {"deleted": len(uuids)}


@api_router.post("/run-schema")
async def api_run_schema(x_admin_key: str = Header(alias="X-Admin-Key", default=""), key: str = Query(default="")):
    """Apply schema.sql to the DB. Requires ADMIN_KEY in X-Admin-Key header or key query param."""
    admin_key = x_admin_key or key or ""
    if not admin_key or admin_key != config.ADMIN_KEY:
        raise HTTPException(status_code=401, detail="Admin key required")
    try:
        await run_schema()
        return {"success": True, "message": "Schema applied"}
    except DatabaseUnavailableError as e:
        raise HTTPException(status_code=503, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/debug", response_class=HTMLResponse)
async def admin_debug():
    """Debug panel: env info, api_logs, health. No auth."""
    data = await _get_debug_data()
    api_logs = data["api_logs"]

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
        <pre>{json.dumps(data["config"], indent=2)}</pre>
        <h2>Health</h2>
        <p>{data["health"]}</p>
        <h2>Recent api_logs (last 50)</h2>
        <table><thead><tr><th>ID</th><th>Endpoint</th><th>Method</th><th>Status</th><th>Created</th></tr></thead>
        <tbody>{rows_html}</tbody></table>
    </body></html>
    """)
