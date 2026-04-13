"""Health check endpoints for liveness and readiness probes."""

from fastapi import APIRouter

from config import settings

router = APIRouter(tags=["health"])


@router.get("/health")
async def health():
    """Liveness probe. Returns 200 if the process is running."""
    return {"status": "healthy", "service": settings.service_name, "version": settings.version}


@router.get("/ready")
async def ready():
    """Readiness probe. Returns 200 if the service can accept traffic.

    In production, this would check downstream dependencies
    (database connectivity, cache availability, etc.).
    """
    checks = {
        "database": await _check_database(),
    }
    all_healthy = all(checks.values())
    return {
        "status": "ready" if all_healthy else "not_ready",
        "checks": checks,
    }


async def _check_database() -> bool:
    """Check database connectivity."""
    # Placeholder: implement actual DB health check
    # Example: execute SELECT 1 against the connection pool
    return True
