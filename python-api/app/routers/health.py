"""Health and status routes."""
from fastapi import APIRouter
from app.models import HealthResponse

router = APIRouter(tags=["health"])


@router.get("/", response_model=HealthResponse)
async def health():
    """Health check for load balancers and monitoring."""
    return HealthResponse()


@router.get("/health")
async def health_alias():
    """Alternative health endpoint."""
    return {"status": "active", "service": "God Mode API"}
