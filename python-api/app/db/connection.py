"""PostgreSQL connection and session management."""
import asyncpg
from contextlib import asynccontextmanager
from pathlib import Path
from typing import AsyncGenerator

from app.config import config


_pool: asyncpg.Pool | None = None

_SCHEMA_PATH = Path(__file__).parent / "schema.sql"


def _load_schema() -> str:
    """Load schema from schema.sql (single source of truth)."""
    return _SCHEMA_PATH.read_text(encoding="utf-8")


async def init_db() -> None:
    """Create connection pool and run migrations. Non-fatal on failure so app can start."""
    global _pool
    if not config.DATABASE_URL:
        print("⚠️ DATABASE_URL not set; DB-dependent routes will return 503")
        return
    try:
        _pool = await asyncpg.create_pool(
            config.DATABASE_URL,
            min_size=1,
            max_size=5,
            command_timeout=10,
            timeout=8,
        )
        schema_sql = _load_schema()
        async with _pool.acquire() as conn:
            await conn.execute(schema_sql)
        print("✅ Database connected")
    except Exception as e:
        print(f"⚠️ Database connection failed (app will start, DB routes return 503): {e}")
        _pool = None


@asynccontextmanager
async def get_db() -> AsyncGenerator[asyncpg.Connection, None]:
    """Get a database connection from the pool."""
    if _pool is None:
        raise RuntimeError("Database not initialized. Call init_db() first.")
    async with _pool.acquire() as conn:
        yield conn


async def close_db() -> None:
    """Close the connection pool."""
    global _pool
    if _pool:
        await _pool.close()
        _pool = None
