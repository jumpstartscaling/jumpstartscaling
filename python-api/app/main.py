"""
God Mode API - FastAPI backend for Spark Platform.
Replaces Django. Handles leads, scaling surveys, and future pSEO endpoints.
"""
import sys
from contextlib import asynccontextmanager

print("God Mode API loading...", flush=True)
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
import json
import time

from app.config import config
from app.db.connection import init_db, close_db, get_db
from app.routers import health, leads, admin, locations, pseo_services, content_matrix


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup: init DB (non-fatal). Shutdown: close pool."""
    try:
        await init_db()
    except Exception as e:
        print(f"⚠️ Startup init_db failed (app continues): {e}")
    yield
    try:
        await close_db()
    except Exception as e:
        print(f"⚠️ Shutdown close_db failed: {e}")


app = FastAPI(
    title="God Mode API",
    version="2.0.0",
    description="FastAPI backend for Spark Platform (leads, pSEO, admin)",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(leads.router)
app.include_router(admin.router)
app.include_router(locations.router)
app.include_router(pseo_services.router)
app.include_router(content_matrix.router)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Optional: log requests to api_logs if LOG_REQUESTS=true."""
    body_bytes = await request.body()

    async def receive():
        return {"type": "http.request", "body": body_bytes}
    request._receive = receive

    response = await call_next(request)

    if config.LOG_REQUESTS and config.DATABASE_URL and request.url.path.startswith("/api/"):
        try:
            async with get_db() as conn:
                payload = json.loads(body_bytes) if body_bytes else {}
                await conn.execute(
                    """
                    INSERT INTO api_logs (endpoint, method, status, payload, response, created_at)
                    VALUES ($1, $2, $3, $4, $5, NOW())
                    """,
                    request.url.path,
                    request.method,
                    response.status_code,
                    json.dumps(payload)[:10000],
                    "{}",
                )
        except Exception as e:
            print(f"Log failed: {e}")

    return response
