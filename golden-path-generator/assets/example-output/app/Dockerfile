# Multi-stage Dockerfile for Python FastAPI service
# Stage 1: Build dependencies
# Stage 2: Runtime with minimal footprint

FROM python:3.12-slim AS builder

WORKDIR /build
COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Runtime stage
FROM python:3.12-slim

RUN groupadd -r appuser && useradd -r -g appuser -s /bin/false appuser

WORKDIR /app

COPY --from=builder /install /usr/local
COPY app/src/ ./

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080", "--workers", "2"]
