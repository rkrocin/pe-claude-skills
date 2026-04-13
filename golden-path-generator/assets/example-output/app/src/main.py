"""Payment Service - FastAPI Application Entry Point."""

import structlog
from fastapi import FastAPI
from contextlib import asynccontextmanager

from config import settings
from routes.payments import router as payments_router
from health import router as health_router

logger = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown lifecycle."""
    logger.info("service_starting", service=settings.service_name, version=settings.version)
    yield
    logger.info("service_stopping", service=settings.service_name)


app = FastAPI(
    title=settings.service_name,
    version=settings.version,
    docs_url="/docs" if settings.environment != "production" else None,
    lifespan=lifespan,
)

app.include_router(health_router)
app.include_router(payments_router, prefix="/api/v1")
