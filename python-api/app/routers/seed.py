"""Seed endpoints - run chrisamaya.work tenant seed via API. Requires X-Admin-Key."""
import json
from fastapi import APIRouter, Header, HTTPException

from app.config import config
from app.db.connection import get_db, DatabaseUnavailableError
from app.seed_data.chrisamaya import (
    DEFAULT_THEME,
    LOCATIONS,
    PSEO_SERVICES,
    SYNONYM_GROUPS,
    SPINTAX,
    CONTENT_FRAGMENTS,
    HEADLINES,
    OFFER_BLOCKS,
    _geo_for_slug,
)

router = APIRouter(prefix="/api/seed", tags=["seed"])


async def _run_chrisamaya_seed(conn):
    """Execute chrisamaya v4 seed logic. Returns {site_id, campaign_id, counts}."""
    counts = {}

    # 1. Site (idempotent)
    row = await conn.fetchrow("SELECT id FROM sites WHERE url ILIKE '%chrisamaya.work%' LIMIT 1")
    if row:
        site_id = str(row["id"])
        await conn.execute(
            "UPDATE sites SET theme_config = $1::jsonb, name = 'chrisamaya', status = 'active' WHERE id = $2::uuid",
            json.dumps(DEFAULT_THEME),
            site_id,
        )
    else:
        row = await conn.fetchrow(
            """
            INSERT INTO sites (name, url, status, theme_config)
            VALUES ('chrisamaya', 'https://chrisamaya.work', 'active', $1::jsonb)
            RETURNING id
            """,
            json.dumps(DEFAULT_THEME),
        )
        site_id = str(row["id"])
    counts["site"] = 1

    # 2. Campaign
    row = await conn.fetchrow(
        "SELECT id FROM campaign_masters WHERE site_id = $1::uuid AND name = 'Unicorn Developer' LIMIT 1",
        site_id,
    )
    niche_vars = json.dumps({"refresh_mode": "light", "uniqueness_target": 82})
    spintax_root = "{Ready to|Want to|Need to} {build|launch|scale|automate} your {Custom SaaS|Private AI System|Unicorn App} {in|for} {City}?"
    if not row:
        row = await conn.fetchrow(
            """
            INSERT INTO campaign_masters (site_id, name, status, headline_spintax_root, target_word_count, niche_variables)
            VALUES ($1::uuid, 'Unicorn Developer', 'active', $2, 2000, $3::jsonb)
            RETURNING id
            """,
            site_id,
            spintax_root,
            niche_vars,
        )
    else:
        await conn.execute(
            """
            UPDATE campaign_masters SET headline_spintax_root = $1, target_word_count = 2000, niche_variables = $2::jsonb
            WHERE id = $3::uuid
            """,
            spintax_root,
            niche_vars,
            row["id"],
        )
    campaign_id = str(row["id"])
    counts["campaign"] = 1

    # 3. Locations
    for loc in LOCATIONS:
        await conn.execute(
            """
            INSERT INTO locations (city, state, zip, slug)
            VALUES ($1, $2, $3, $4)
            ON CONFLICT (slug) DO UPDATE SET city = EXCLUDED.city, state = EXCLUDED.state, zip = EXCLUDED.zip
            """,
            loc["city"],
            loc["state"],
            loc.get("zip"),
            loc["slug"],
        )
    counts["locations"] = len(LOCATIONS)

    # 4. pseo_services
    for svc in PSEO_SERVICES:
        await conn.execute(
            """
            INSERT INTO pseo_services (service_type, sub_niche, slug)
            VALUES ($1, $2, $3)
            ON CONFLICT (slug) DO UPDATE SET service_type = EXCLUDED.service_type, sub_niche = EXCLUDED.sub_niche
            """,
            svc["service_type"],
            svc.get("sub_niche"),
            svc["slug"],
        )
    counts["pseo_services"] = len(PSEO_SERVICES)

    # 5. Synonym groups
    for item in SYNONYM_GROUPS:
        n = await conn.fetchval("SELECT COUNT(*) FROM synonym_groups WHERE category = $1", item["category"])
        if n == 0:
            await conn.execute(
                "INSERT INTO synonym_groups (category, terms) VALUES ($1, $2::jsonb)",
                item["category"],
                json.dumps(item["terms"]),
            )
    counts["synonym_groups"] = len(SYNONYM_GROUPS)

    # 6. Spintax
    for item in SPINTAX:
        n = await conn.fetchval("SELECT COUNT(*) FROM spintax_dictionaries WHERE category = $1", item["category"])
        if n == 0:
            await conn.execute(
                "INSERT INTO spintax_dictionaries (category, data) VALUES ($1, $2::jsonb)",
                item["category"],
                json.dumps(item["data"]),
            )
    counts["spintax_dictionaries"] = len(SPINTAX)

    # 7. Content fragments
    n_frag = await conn.fetchval(
        "SELECT COUNT(*) FROM content_fragments WHERE campaign_id = $1::uuid",
        campaign_id,
    )
    if n_frag < 50:
        for ftype, body in CONTENT_FRAGMENTS:
            await conn.execute(
                """
                INSERT INTO content_fragments (campaign_id, fragment_type, content_body, fragment_text, status)
                VALUES ($1::uuid, $2, $3, $3, 'active')
                """,
                campaign_id,
                ftype,
                body,
            )
    counts["content_fragments"] = len(CONTENT_FRAGMENTS)

    # 8. Headlines
    n_hl = await conn.fetchval(
        "SELECT COUNT(*) FROM headline_inventory WHERE campaign_id = $1::uuid",
        campaign_id,
    )
    if n_hl < 30:
        for htype, text in HEADLINES:
            await conn.execute(
                "INSERT INTO headline_inventory (campaign_id, headline_text, status) VALUES ($1::uuid, $2, 'active')",
                campaign_id,
                text,
            )
    counts["headline_inventory"] = len(HEADLINES)

    # 9. Offer blocks
    n_offer = await conn.fetchval("SELECT COUNT(*) FROM offer_blocks")
    if n_offer < 18:
        for item in OFFER_BLOCKS:
            await conn.execute(
                "INSERT INTO offer_blocks (block_type, data) VALUES ($1, $2::jsonb)",
                item["block_type"],
                json.dumps(item["data"]),
            )
    counts["offer_blocks"] = len(OFFER_BLOCKS)

    # 10. geo_intelligence
    for loc in LOCATIONS:
        slug = loc["slug"]
        data = _geo_for_slug(slug)
        data["latitude"] = 30.0 + hash(slug) % 20 * 0.1
        data["longitude"] = -100.0 + hash(slug) % 30 * 0.5
        exists = await conn.fetchval("SELECT 1 FROM geo_intelligence WHERE cluster_key = $1 LIMIT 1", slug)
        if not exists:
            await conn.execute(
                "INSERT INTO geo_intelligence (cluster_key, data) VALUES ($1, $2::jsonb)",
                slug,
                json.dumps(data),
            )
    counts["geo_intelligence"] = len(LOCATIONS)

    # 11. content_matrix — Cartesian
    loc_rows = await conn.fetch(
        "SELECT id, slug FROM locations WHERE slug = ANY($1::text[])",
        [l["slug"] for l in LOCATIONS],
    )
    svc_rows = await conn.fetch(
        "SELECT id, slug FROM pseo_services WHERE slug = ANY($1::text[])",
        [s["slug"] for s in PSEO_SERVICES],
    )
    loc_by_slug = {r["slug"]: r["id"] for r in loc_rows}
    svc_by_slug = {r["slug"]: r["id"] for r in svc_rows}
    for loc in LOCATIONS:
        loc_id = loc_by_slug.get(loc["slug"])
        if not loc_id:
            continue
        for svc in PSEO_SERVICES:
            svc_id = svc_by_slug.get(svc["slug"])
            if not svc_id:
                continue
            cm_slug = f"{svc['slug']}-{loc['slug']}"
            title = f"{svc['service_type']} {svc.get('sub_niche', '')} in {loc['city']}, {loc['state']}".strip()
            meta = f"Find {svc['service_type']} {svc.get('sub_niche', '')} in {loc['city']}, {loc['state']}. Expert solutions. Book a free audit."
            await conn.execute(
                """
                INSERT INTO content_matrix (location_id, service_id, slug, title, meta_description)
                VALUES ($1, $2, $3, $4, $5)
                ON CONFLICT (slug) DO NOTHING
                """,
                loc_id,
                svc_id,
                cm_slug,
                title,
                meta,
            )
    cm_count = await conn.fetchval("SELECT COUNT(*) FROM content_matrix")
    counts["content_matrix"] = cm_count

    return {
        "site_id": site_id,
        "campaign_id": campaign_id,
        "counts": counts,
        "message": "chrisamaya.work God Mode v4 — 2000-word survey factory ready.",
    }


@router.post("/chrisamaya")
async def seed_chrisamaya(x_admin_key: str = Header(alias="X-Admin-Key", default="")):
    """Seed chrisamaya.work tenant (site, campaign, locations, pseo_services, etc.). Requires X-Admin-Key."""
    if not x_admin_key or x_admin_key != config.ADMIN_KEY:
        raise HTTPException(status_code=401, detail="Admin key required")
    try:
        async with get_db() as conn:
            result = await _run_chrisamaya_seed(conn)
        return result
    except DatabaseUnavailableError as e:
        raise HTTPException(status_code=503, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
