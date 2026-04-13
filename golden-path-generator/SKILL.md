---
name: golden-path-generator
description: >
  Generate opinionated, production-ready service scaffolds (Golden Paths) for common service archetypes
  including REST APIs, event-driven consumers, batch jobs, and static frontends. Use this skill whenever
  the user wants to create a new service, microservice, application scaffold, starter template, or
  project skeleton for cloud-native workloads. Also trigger when the user asks about service templates,
  platform starter kits, internal developer platform templates, IDP Golden Paths, or how to bootstrap
  a new service with CI/CD, observability, and security built in. Supports AWS-native runtimes (ECS,
  EKS, Lambda), multiple languages, and compliance-aware configurations (PCI DSS, SOC2).
---

# Golden Path Generator

Generate opinionated, production-ready service scaffolds with infrastructure, CI/CD, observability, and security built in from the start.

## What This Skill Does

Takes a service description (type, runtime, language, constraints) and generates a complete project scaffold including:

1. **Application skeleton** with structured logging, health checks, and configuration management
2. **Infrastructure-as-Code** (Terraform) for the target runtime with security and compliance controls
3. **CI/CD pipeline** (GitHub Actions) with build, test, security scan, and deploy stages
4. **Observability setup** with structured logging, metrics, distributed tracing, and alerting
5. **Documentation** including a README with onboarding steps and an ADR explaining key decisions
6. **Dockerfile** optimized for the target runtime

## Gathering Requirements

Before generating, collect these inputs. If not specified, use the defaults shown.

| Parameter | Options | Default |
|-----------|---------|---------|
| Service type | REST API, Event Consumer, Batch Job, Static Frontend | REST API |
| Runtime | ECS Fargate, EKS, Lambda, EC2 | ECS Fargate |
| Language | Python, Java, Node.js, Go | Python |
| Data store | PostgreSQL, DynamoDB, Redis, S3, None | None |
| Compliance scope | PCI, SOC2, General, None | General |
| Team experience | New to platform, Experienced | Experienced |

If the user provides a natural language description like "I need a Python API that processes payments and stores data in Postgres, PCI scoped," extract the parameters from that description rather than asking for each one.

## Service Archetypes

Four archetype reference files are available in `references/`. Load the one matching the requested service type:

| Archetype | File | When to Use |
|-----------|------|-------------|
| REST API | `references/rest-api.md` | HTTP services, API backends, CRUD services, GraphQL endpoints |
| Event Consumer | `references/event-consumer.md` | Message queue consumers, event processors, stream handlers |
| Batch Job | `references/batch-job.md` | Scheduled tasks, ETL pipelines, data processing jobs |
| Static Frontend | `references/static-frontend.md` | SPAs, marketing sites, documentation sites |

Read the relevant reference file before generating. It contains the directory structure, required files, infrastructure patterns, and key decisions for that archetype.

## Generation Process

### Step 1: Resolve Parameters

Map the user's request to the parameter table above. For anything unspecified, use defaults. Confirm the resolved parameters with the user before generating if there is ambiguity.

### Step 2: Load Archetype Reference

Read the appropriate reference file from `references/`. This defines the project structure, required files, and archetype-specific patterns.

### Step 3: Apply Compliance Overlay

Based on the compliance scope, adjust the generated output:

**PCI scope adjustments:**
- Infrastructure: Add encryption at rest with customer-managed KMS, encryption in transit with TLS 1.2+, VPC placement in private subnets, security group restrictions
- CI/CD: Add SAST scanning step, container image scanning, dependency vulnerability check
- Logging: Ensure no cardholder data appears in logs, add audit logging
- Tagging: Include `ComplianceScope = "PCI"` and `DataClassification` tags on all resources
- Documentation: Note PCI requirements in the ADR

**SOC2 scope adjustments:**
- Infrastructure: Add CloudTrail integration, access logging on all data stores
- CI/CD: Add audit trail for deployments, approval gates for production
- Logging: Ensure log retention meets SOC2 requirements (minimum 1 year)
- Documentation: Note SOC2 control mappings in the ADR

**General (default):**
- Apply baseline security controls (encryption, least-privilege IAM, no public access)
- Standard logging and monitoring
- No additional compliance-specific overlays

### Step 4: Apply Team Experience Overlay

**New to platform:**
- Expand README with step-by-step setup instructions
- Add inline code comments explaining non-obvious patterns
- Include a "Common Tasks" section in README (how to add an endpoint, how to add a dependency, how to run locally, how to deploy)
- Add a CONTRIBUTING.md with development workflow

**Experienced (default):**
- Concise README with standard sections
- Minimal inline comments (code should be self-documenting)
- Reference platform documentation rather than duplicating it

### Step 5: Generate Files

Generate all files for the project scaffold. Each file should be complete and functional, not a skeleton with TODO comments. The generated project should be runnable with minimal setup.

Output the project as a directory tree with all files. Use the structure defined in the archetype reference, adjusted for the resolved parameters.

### Step 6: Generate ADR

Every Golden Path includes an Architecture Decision Record (ADR) in `docs/adr-001-service-architecture.md`. This explains:

- Why this archetype was selected
- Key technology choices and their rationale
- Compliance controls embedded and why
- Tradeoffs made (e.g., ECS Fargate chosen over Lambda for long-running request support)
- What to revisit as the service matures

The ADR matters because it gives future engineers context for decisions that would otherwise look arbitrary. Frame it as "here is why this was built this way" rather than "here is what was built."

## Output Structure

The generated project follows this layout (archetype-specific files vary):

```
service-name/
├── app/
│   ├── src/                    # Application source code
│   │   ├── main entry point    # Language-specific (main.py, Main.java, main.go, index.ts)
│   │   ├── routes/handlers     # Request handlers or event processors
│   │   ├── config              # Configuration management
│   │   └── health              # Health check endpoint
│   ├── tests/                  # Unit and integration tests
│   ├── Dockerfile              # Multi-stage, optimized for runtime
│   └── dependency manifest     # requirements.txt, pom.xml, go.mod, package.json
├── infra/
│   ├── main.tf                 # Primary infrastructure definition
│   ├── variables.tf            # Input variables with descriptions
│   ├── outputs.tf              # Output values for downstream consumers
│   └── terraform.tfvars.example # Example variable values
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # Build, test, scan, deploy pipeline
├── docs/
│   ├── adr-001-service-architecture.md  # Architecture Decision Record
│   └── runbook.md              # Operational runbook (start, stop, troubleshoot)
├── README.md                   # Onboarding and usage documentation
├── .gitignore                  # Language-appropriate ignores
└── Makefile                    # Common commands (build, test, run, deploy)
```

## Quality Standards

Every generated Golden Path must meet these standards:

- **Runnable**: The application starts and responds to health checks with no code changes
- **Testable**: At least one passing unit test is included
- **Deployable**: The CI/CD pipeline is complete and would succeed given correct environment variables
- **Secure by default**: No hardcoded secrets, encryption enabled, least-privilege IAM
- **Observable**: Structured logging, health endpoint, and metrics instrumentation from day one
- **Documented**: README covers setup, development, deployment, and common tasks

## Edge Cases

- **Multiple data stores**: If the user needs both a relational DB and a cache, include both in the infrastructure and application configuration. Note the added complexity in the ADR.
- **Multi-service**: If the user describes what sounds like multiple services, generate one Golden Path and recommend splitting the others into separate projects. Monorepo patterns are out of scope.
- **Unsupported runtime/language combination**: If a combination is unusual (e.g., Go on Lambda with ECS-style patterns), note the mismatch and recommend the idiomatic approach for that runtime.
- **No infrastructure requested**: If the user only wants the application scaffold without IaC, skip the `infra/` directory but still include CI/CD and observability.
