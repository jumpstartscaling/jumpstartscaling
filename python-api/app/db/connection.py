"""PostgreSQL connection and session management."""
import asyncpg
from contextlib import asynccontextmanager
from typing import AsyncGenerator

from app.config import config


_pool: asyncpg.Pool | None = None


async def init_db() -> None:
    """Create connection pool and run migrations."""
    global _pool
    _pool = await asyncpg.create_pool(
        config.DATABASE_URL,
        min_size=2,
        max_size=10,
        command_timeout=10,
    )
    async with _pool.acquire() as conn:
        await conn.execute(_SCHEMA_SQL)


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


# Schema aligned with router.js and TypeScript types
_SCHEMA_SQL = """
-- Leads (contact forms, audit survey, n8n form, etc.)
CREATE TABLE IF NOT EXISTS leads (
    id SERIAL PRIMARY KEY,
    source TEXT,
    name TEXT,
    email TEXT,
    phone TEXT,
    website TEXT,
    revenue TEXT,
    budget TEXT,
    problem TEXT,
    form_type TEXT,
    data_json JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Scaling survey (Moat Audit, detailed survey)
CREATE TABLE IF NOT EXISTS scaling_survey_submissions (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    company TEXT,
    role TEXT,
    current_revenue TEXT,
    target_revenue TEXT,
    team_size TEXT,
    industry TEXT,
    challenges JSONB,
    marketing_spend TEXT,
    channels JSONB,
    biggest_goal TEXT,
    raw_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Request logging (optional, for debugging)
CREATE TABLE IF NOT EXISTS api_logs (
    id SERIAL PRIMARY KEY,
    endpoint TEXT,
    method TEXT,
    status INTEGER,
    payload JSONB,
    response JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Harris matrix (pSEO): locations, services, content
CREATE TABLE IF NOT EXISTS locations (
    id SERIAL PRIMARY KEY,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip TEXT,
    neighborhood TEXT,
    slug TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pseo_services (
    id SERIAL PRIMARY KEY,
    service_type TEXT NOT NULL,
    sub_niche TEXT,
    slug TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS content_matrix (
    id SERIAL PRIMARY KEY,
    location_id INT REFERENCES locations(id),
    service_id INT REFERENCES pseo_services(id),
    slug TEXT UNIQUE,
    title TEXT,
    meta_description TEXT,
    content_json JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"""
