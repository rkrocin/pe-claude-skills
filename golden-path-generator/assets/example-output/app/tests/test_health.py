"""Tests for health check endpoints."""

import pytest
from httpx import AsyncClient, ASGITransport
from main import app


@pytest.fixture
def client():
    transport = ASGITransport(app=app)
    return AsyncClient(transport=transport, base_url="http://test")


@pytest.mark.asyncio
async def test_health_returns_200(client):
    async with client as c:
        response = await c.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "version" in data
    assert "service" in data


@pytest.mark.asyncio
async def test_ready_returns_200(client):
    async with client as c:
        response = await c.get("/ready")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] in ("ready", "not_ready")
    assert "checks" in data
