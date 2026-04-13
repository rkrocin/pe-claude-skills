# ADR-001: Payment Service Architecture

## Status
Accepted

## Context
The payments team needs a new service to handle payment processing for the card platform. The service must operate within the cardholder data environment (CDE) and comply with PCI DSS requirements. Expected traffic is moderate (hundreds of requests per second at peak) with strict reliability requirements.

## Decision

### Service Type: REST API
A synchronous HTTP API is the right fit because payment operations are request/response by nature. Callers need immediate confirmation of payment status. Event-driven processing was considered for downstream side effects (notifications, analytics) but the primary interface must be synchronous.

### Runtime: ECS Fargate
Fargate was chosen over Lambda for three reasons. First, payment processing can involve multiple downstream calls (fraud check, authorization, ledger write) that may exceed Lambda's cold start tolerance for p99 latency. Second, connection pooling to PostgreSQL works better with long-running containers. Third, the team has existing ECS operational expertise.

EKS was considered but adds Kubernetes operational overhead that is not justified for a single service deployment. If the organization standardizes on EKS, this service can be migrated with minimal application changes.

### Language: Python (FastAPI)
FastAPI provides async request handling, automatic OpenAPI documentation, and Pydantic validation. The team has strong Python expertise. Java (Spring Boot) was the alternative but the faster development velocity of Python was prioritized given the team's experience.

### Data Store: PostgreSQL (RDS)
Relational storage is appropriate for payment records that require ACID guarantees. RDS with Multi-AZ provides the durability and availability requirements. DynamoDB was considered but the query patterns (filter by date range, customer, status) favor relational.

### Compliance: PCI DSS
As a CDE service, the following controls are embedded by design:
- Customer-managed KMS key for all encryption (not AWS-managed)
- Private subnet placement, no public accessibility
- Security group restricts ingress to ALB only, egress to internal CIDR
- Secrets in AWS Secrets Manager, never in environment variables or code
- CloudWatch logs encrypted with KMS, 90-day retention
- ECR image scanning on push
- SAST and dependency scanning in CI/CD pipeline
- Immutable image tags to prevent tag mutation

## Consequences

### Positive
- Service is deployable and compliant from the first commit
- Observability (structured logging, health checks, metrics) is built in, not bolted on
- CI/CD pipeline enforces security scanning before any deployment
- Infrastructure is codified and auditable

### Risks to Monitor
- FastAPI's async model requires discipline around blocking I/O (database calls must use async drivers)
- Fargate task sizing (512 CPU, 1GB memory) may need adjustment under production load
- Auto scaling on CPU may not be the best signal for I/O-bound workloads; consider request-count scaling if latency degrades under load

### Future Considerations
- Add distributed tracing (AWS X-Ray or OpenTelemetry) once the service is in production and baseline performance is established
- Evaluate read replicas if reporting queries impact transactional performance
- Consider event publishing (SNS/SQS) for downstream consumers once payment lifecycle events are defined
