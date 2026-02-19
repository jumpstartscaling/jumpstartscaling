"""CRUD and matrix permutation routes for content_matrix. No auth."""
import json
from fastapi import APIRouter, HTTPException
from app.db.connection import get_db
from app.schemas.matrix import (
    ContentMatrixCreate,
    ContentMatrixUpdate,
    ContentMatrixRead,
    MatrixPermutation,
)

router = APIRouter(prefix="/api", tags=["content_matrix"])


@router.get("/matrix/permutations", response_model=list[MatrixPermutation])
async def get_permutations():
    """Return all content_matrix rows with location/service denormalized for pSEO pages."""
    async with get_db() as conn:
        rows = await conn.fetch(
            """
            SELECT cm.slug, cm.title, cm.meta_description, l.city AS location_city, l.state AS location_state, ps.service_type
            FROM content_matrix cm
            LEFT JOIN locations l ON cm.location_id = l.id
            LEFT JOIN pseo_services ps ON cm.service_id = ps.id
            ORDER BY cm.slug
            """
        )
        return [
            MatrixPermutation(
                slug=r["slug"],
                title=r["title"],
                meta_description=r["meta_description"],
                location_city=r["location_city"],
                location_state=r["location_state"],
                service_type=r["service_type"],
            )
            for r in rows
        ]


@router.get("/matrix/by-slug/{slug}", response_model=ContentMatrixRead)
async def get_by_slug(slug: str):
    """Fetch a single content_matrix row by slug (for pSEO page render)."""
    async with get_db() as conn:
        row = await conn.fetchrow(
            "SELECT id, location_id, service_id, slug, title, meta_description, content_json FROM content_matrix WHERE slug = $1",
            slug,
        )
        if not row:
            raise HTTPException(404, "Content not found")
        return ContentMatrixRead(**dict(row))


@router.get("/content-matrix", response_model=list[ContentMatrixRead])
async def list_content_matrix(skip: int = 0, limit: int = 100):
    async with get_db() as conn:
        rows = await conn.fetch(
            """
            SELECT id, location_id, service_id, slug, title, meta_description, content_json
            FROM content_matrix ORDER BY slug OFFSET $1 LIMIT $2
            """,
            skip, limit,
        )
        return [ContentMatrixRead(**dict(r)) for r in rows]


@router.post("/content-matrix", response_model=ContentMatrixRead)
async def create_content(body: ContentMatrixCreate):
    content_json = json.dumps(body.content_json) if body.content_json else None
    async with get_db() as conn:
        row = await conn.fetchrow(
            """
            INSERT INTO content_matrix (location_id, service_id, slug, title, meta_description, content_json)
            VALUES ($1, $2, $3, $4, $5, $6::jsonb)
            ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, meta_description = EXCLUDED.meta_description, content_json = EXCLUDED.content_json
            RETURNING id, location_id, service_id, slug, title, meta_description, content_json
            """,
            body.location_id, body.service_id, body.slug, body.title, body.meta_description, content_json,
        )
        return ContentMatrixRead(**dict(row))


@router.get("/content-matrix/{cm_id}", response_model=ContentMatrixRead)
async def get_content(cm_id: int):
    async with get_db() as conn:
        row = await conn.fetchrow(
            "SELECT id, location_id, service_id, slug, title, meta_description, content_json FROM content_matrix WHERE id = $1",
            cm_id,
        )
        if not row:
            raise HTTPException(404, "Content not found")
        return ContentMatrixRead(**dict(row))


@router.patch("/content-matrix/{cm_id}", response_model=ContentMatrixRead)
async def update_content(cm_id: int, body: ContentMatrixUpdate):
    updates = body.model_dump(exclude_unset=True)
    if not updates:
        async with get_db() as conn:
            row = await conn.fetchrow(
                "SELECT id, location_id, service_id, slug, title, meta_description, content_json FROM content_matrix WHERE id = $1",
                cm_id,
            )
            if not row:
                raise HTTPException(404, "Content not found")
            return ContentMatrixRead(**dict(row))
    if "content_json" in updates and updates["content_json"] is not None:
        updates["content_json"] = json.dumps(updates["content_json"])
    cols = list(updates.keys())
    def _col(c: str, i: int) -> str:
        return f"{c} = ${i+2}::jsonb" if c == "content_json" else f"{c} = ${i+2}"
    set_clause = ", ".join(_col(c, i) for i, c in enumerate(cols))
    values = [updates[c] for c in cols] + [cm_id]
    async with get_db() as conn:
        await conn.execute(
            f"UPDATE content_matrix SET {set_clause} WHERE id = ${len(values)}",
            *values,
        )
        row = await conn.fetchrow(
            "SELECT id, location_id, service_id, slug, title, meta_description, content_json FROM content_matrix WHERE id = $1",
            cm_id,
        )
        return ContentMatrixRead(**dict(row))


@router.delete("/content-matrix/{cm_id}", status_code=204)
async def delete_content(cm_id: int):
    async with get_db() as conn:
        r = await conn.execute("DELETE FROM content_matrix WHERE id = $1", cm_id)
        if r == "DELETE 0":
            raise HTTPException(404, "Content not found")
