# REST API Golden Path

Reference definition for REST API service scaffolds. This is the most common archetype, covering HTTP backends, CRUD services, and API endpoints.

## Directory Structure

```
{service-name}/
├── app/
│   ├── src/
│   │   ├── {main entry}         # FastAPI/Spring Boot/Express/Gin entry point
│   │   ├── routes/              # Route definitions, one file per resource
│   │   ├── models/              # Data models / schemas
│   │   ├── services/            # Business logic layer
│   │   ├── config.{ext}         # Configuration from environment variables
│   │   └── health.{ext}         # Health check endpoint (/health, /ready)
│   ├── tests/
│   │   ├── test_health.{ext}    # Health check test (always included)
│   │   └── test_routes.{ext}    # Example route test
│   ├── Dockerfile
│   └── {dependency manifest}
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── .github/workflows/ci-cd.yml
├── docs/
│   ├── adr-001-service-architecture.md
│   └── runbook.md
├── README.md
├── .gitignore
└── Makefile
```

## Language-Specific Patterns

### Python (FastAPI)
- Framework: FastAPI with uvicorn
- Entry point: `app/src/main.py`
- Dependencies: `app/requirements.txt`
- Config: Pydantic Settings class loading from environment
- Logging: `structlog` with JSON output
- Health: `/health` returns `{"status": "healthy", "version": "..."}` and `/ready` checks downstream dependencies
- Testing: `pytest` with `httpx.AsyncClient`
- Dockerfile: Multi-stage with `python:3.12-slim`, pip install in builder stage, non-root user in runtime

### Java (Spring Boot)
- Framework: Spring Boot 3.x with Spring Web
- Entry point: `app/src/main/java/.../Application.java`
- Dependencies: `app/pom.xml` (Maven)
- Config: `application.yml` with Spring profiles
- Logging: SLF4J with Logback, JSON encoder
- Health: Spring Actuator `/actuator/health` and `/actuator/ready`
- Testing: JUnit 5 with Spring Boot Test
- Dockerfile: Multi-stage with Eclipse Temurin, Maven build in builder, JRE-only runtime

### Node.js (Express)
- Framework: Express with TypeScript
- Entry point: `app/src/index.ts`
- Dependencies: `app/package.json`
- Config: `dotenv` with typed config module
- Logging: `pino` with JSON output
- Health: `/health` and `/ready` endpoints
- Testing: `jest` with `supertest`
- Dockerfile: Multi-stage with `node:20-slim`, npm ci in builder, non-root user

### Go (Gin)
- Framework: Gin
- Entry point: `app/src/main.go`
- Dependencies: `app/go.mod`
- Config: `envconfig` struct tags
- Logging: `zerolog` with JSON output
- Health: `/health` and `/ready` handlers
- Testing: Standard `testing` package with `net/http/httptest`
- Dockerfile: Multi-stage with `golang:1.22` builder, `gcr.io/distroless/static` runtime

## Infrastructure Patterns (Terraform)

### ECS Fargate (Default)
```
Resources:
- aws_ecs_cluster (or reference existing)
- aws_ecs_task_definition with container definitions
- aws_ecs_service with desired_count, deployment configuration
- aws_lb_target_group with health check on /health
- aws_lb_listener_rule routing to target group
- aws_security_group allowing ingress from ALB only
- aws_iam_role for task execution and task role (least privilege)
- aws_cloudwatch_log_group with retention
- aws_appautoscaling_target and policy (CPU-based)

Key decisions:
- Fargate over EC2 for operational simplicity
- ALB health check on /health endpoint
- Auto scaling on CPU utilization (target 70%)
- Log driver: awslogs to CloudWatch
- Secrets via AWS Secrets Manager, referenced in task definition
```

### EKS
```
Resources:
- Kubernetes Deployment manifest
- Kubernetes Service (ClusterIP)
- Kubernetes Ingress (ALB Ingress Controller)
- Kubernetes HorizontalPodAutoscaler
- Kubernetes ConfigMap and Secret references
- IAM Role for Service Account (IRSA)

Key decisions:
- Deployment with rolling update strategy
- Resource requests and limits set explicitly
- Liveness probe on /health, readiness probe on /ready
- HPA targeting 70% CPU
- IRSA for AWS API access (no static credentials)
```

### Lambda
```
Resources:
- aws_lambda_function with handler and runtime
- aws_api_gateway_rest_api or aws_apigatewayv2_api (HTTP API)
- aws_iam_role with minimal permissions
- aws_cloudwatch_log_group with retention
- aws_lambda_permission for API Gateway invocation

Key decisions:
- HTTP API (v2) over REST API for cost and performance
- Provisioned concurrency only if latency-sensitive
- Lambda Powertools for structured logging and tracing
- Cold start mitigation via keep-warm if needed
```

## CI/CD Pipeline (GitHub Actions)

```yaml
Stages:
  1. Build
     - Checkout code
     - Set up language runtime
     - Install dependencies
     - Run linter
     - Compile / build

  2. Test
     - Run unit tests
     - Generate coverage report
     - Fail if coverage below threshold (80%)

  3. Security Scan
     - SAST scan (Semgrep or language-specific)
     - Dependency vulnerability scan (Trivy, Snyk, or npm audit)
     - Container image scan (Trivy)

  4. Build & Push Image
     - Build Docker image
     - Tag with git SHA and branch
     - Push to ECR

  5. Deploy (per environment)
     - Dev: automatic on push to main
     - Staging: automatic after dev succeeds
     - Production: manual approval gate
     - Terraform plan and apply for infrastructure
     - ECS service update / kubectl apply / Lambda update

Environment variables:
  - AWS credentials via OIDC (no static keys)
  - ECR repository URI
  - ECS cluster and service names
  - Environment-specific config via GitHub Environments
```

## Observability

### Structured Logging
- JSON format with consistent fields: `timestamp`, `level`, `message`, `service`, `trace_id`, `span_id`
- Request logging middleware: method, path, status, duration_ms, request_id
- No sensitive data in logs (mask PII, cardholder data, credentials)
- Log level configurable via environment variable

### Health Checks
- `/health`: Returns 200 if the application process is running. No dependency checks. Used for liveness probes.
- `/ready`: Returns 200 if the application can serve traffic (database connected, caches warm). Used for readiness probes and load balancer health checks.

### Metrics
- Request count by method, path, status
- Request duration histogram
- Active connections gauge
- Custom business metrics via StatsD or CloudWatch embedded metrics

### Distributed Tracing
- AWS X-Ray SDK or OpenTelemetry integration
- Trace context propagation on outbound HTTP calls
- Span creation for database queries and external service calls

## Data Store Integration

When a data store is requested, add:

### PostgreSQL
- Connection pool configuration (max connections, idle timeout)
- Health check query in `/ready` endpoint
- Migration tool setup (Alembic for Python, Flyway for Java, Prisma for Node, golang-migrate for Go)
- Terraform: `aws_db_instance` or `aws_rds_cluster` with encryption, private subnet, parameter group

### DynamoDB
- Table definition in Terraform with appropriate key schema
- DAX cluster if caching is needed
- Terraform: `aws_dynamodb_table` with encryption, point-in-time recovery

### Redis
- Connection configuration with TLS
- Health check via PING in `/ready`
- Terraform: `aws_elasticache_replication_group` with encryption in transit and at rest

### S3
- Bucket configuration in Terraform with encryption, versioning, lifecycle
- Pre-signed URL generation for uploads/downloads if client-facing
