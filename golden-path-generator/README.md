# Golden Path Generator

A [Claude Skill](https://docs.anthropic.com/) that generates opinionated, production-ready service scaffolds with infrastructure, CI/CD, observability, and security built in from the first commit.

## What It Does

Describe what you need and it generates a complete project scaffold:

- **Application code** with structured logging, health checks, configuration management, and an example endpoint
- **Infrastructure-as-Code** (Terraform) for ECS Fargate, EKS, or Lambda with encryption, least-privilege IAM, and auto scaling
- **CI/CD pipeline** (GitHub Actions) with build, test, SAST, container scan, and multi-environment deploy
- **Observability** with structured JSON logging, health/readiness endpoints, and metrics instrumentation
- **Documentation** including an Architecture Decision Record explaining every key choice
- **Dockerfile** with multi-stage build, non-root user, and health check

## Service Archetypes

| Archetype | Use Case | Default Runtime |
|-----------|----------|-----------------|
| REST API | HTTP backends, CRUD services, API endpoints | ECS Fargate |
| Event Consumer | SQS/SNS/Kafka message processors | ECS Fargate |
| Batch Job | Scheduled ETL, data pipelines, periodic tasks | ECS Fargate Task |
| Static Frontend | SPAs, documentation sites, dashboards | S3 + CloudFront |

## Usage

### With Claude Desktop or Claude.ai

Install the skill, then describe your service:

```
I need a Python REST API for a payment service that stores data in PostgreSQL.
It runs on ECS Fargate and needs PCI compliance. The team is new to the platform.
```

Or be more concise:

```
Generate a Golden Path for a Go event consumer on EKS that reads from SQS.
```

### Parameters

| Parameter | Options | Default |
|-----------|---------|---------|
| Service type | REST API, Event Consumer, Batch Job, Static Frontend | REST API |
| Runtime | ECS Fargate, EKS, Lambda, EC2 | ECS Fargate |
| Language | Python, Java, Node.js, Go | Python |
| Data store | PostgreSQL, DynamoDB, Redis, S3, None | None |
| Compliance | PCI, SOC2, General, None | General |
| Team experience | New to platform, Experienced | Experienced |

## Example Output

The `assets/example-output/` directory contains a fully generated REST API Golden Path for a PCI-scoped payment service on ECS Fargate. Browse it to see exactly what the skill produces:

```
example-output/
├── app/
│   ├── src/
│   │   ├── main.py              # FastAPI entry point
│   │   ├── config.py            # Pydantic Settings configuration
│   │   ├── health.py            # /health and /ready endpoints
│   │   └── routes/
│   │       └── payments.py      # Example payment endpoints
│   ├── tests/
│   │   └── test_health.py       # Health check tests
│   ├── Dockerfile               # Multi-stage, non-root user
│   └── requirements.txt
├── infra/
│   ├── main.tf                  # ECS Fargate + KMS + IAM + auto scaling
│   └── variables.tf             # Configurable inputs
├── .github/workflows/
│   └── ci-cd.yml                # Build, test, scan, deploy pipeline
├── docs/
│   └── adr-001-service-architecture.md  # Architecture Decision Record
└── Makefile                     # build, test, run, lint, deploy commands
```

## Design Philosophy

**Opinionated by default, flexible by request.** Every Golden Path makes decisions about tooling, configuration, and architecture patterns. The ADR documents why each decision was made so teams understand the reasoning rather than inheriting unexplained conventions.

**Secure from the first commit.** Encryption, least-privilege IAM, secrets management, and security scanning are not "add later" items. They ship with the scaffold because retrofitting security is always harder than building it in.

**Observable from day one.** Structured logging, health checks, and metrics instrumentation are included in the application skeleton. Teams do not need to figure out observability after their first production incident.

**Compliant by construction.** PCI and SOC2 overlays embed the relevant controls into the infrastructure and pipeline rather than requiring a separate compliance review after the fact. The goal is to make the compliant path the easiest path.

## Archetype Reference Files

The `references/` directory contains detailed definitions for each archetype:

| File | Content |
|------|---------|
| `rest-api.md` | Directory structure, language patterns (Python/Java/Node/Go), infrastructure for ECS/EKS/Lambda, CI/CD stages, observability, data store integration |
| `event-consumer.md` | SQS/SNS/Kafka/EventBridge patterns, reliability (idempotency, retry, DLQ), graceful shutdown, consumer scaling |
| `batch-job.md` | Checkpoint/resume, idempotent execution, Step Functions/ECS task/Lambda patterns, job monitoring |
| `static-frontend.md` | React/Next.js/plain HTML, S3 + CloudFront with OAC, security headers, cache invalidation |

## Skill Structure

```
golden-path-generator/
├── SKILL.md                     # Skill definition and generation process
├── README.md                    # This file
├── references/
│   ├── rest-api.md              # REST API archetype definition
│   ├── event-consumer.md        # Event consumer archetype definition
│   ├── batch-job.md             # Batch job archetype definition
│   └── static-frontend.md      # Static frontend archetype definition
└── assets/
    └── example-output/          # Fully generated REST API Golden Path
        ├── app/
        ├── infra/
        ├── .github/
        ├── docs/
        └── Makefile
```

## License

MIT
