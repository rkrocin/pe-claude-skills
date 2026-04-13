# ADR-003: Adopt Amazon SQS over Apache Kafka for Async Messaging in Payment Services

## Status

Accepted

## Date

2026-01-22

## Participants

- Platform Engineering (decision owner)
- Payments Engineering (primary consumer)
- SRE (operational review)
- Information Security (compliance review)

## Context

The payments platform currently processes authorization and settlement events synchronously through a request/response chain that spans five downstream services. As transaction volume has grown 40% year-over-year, the synchronous chain is producing cascading timeouts during peak periods (Black Friday, Cyber Monday), with p99 latency exceeding 8 seconds against a 3-second SLA.

Introducing asynchronous messaging between the authorization service and its downstream consumers would decouple the critical path, allow independent scaling, and provide a buffer during traffic spikes. The messaging system must operate within the PCI cardholder data environment (CDE), support at-least-once delivery, and integrate with our existing AWS infrastructure and Terraform-managed deployment model.

The team has 12 engineers, none with deep Kafka operational experience. Two engineers have prior experience with SQS from previous roles. The platform engineering team can provide Terraform modules and Golden Path templates for whichever option is selected, but cannot commit dedicated headcount to operate a self-managed messaging cluster.

## Options Considered

### Option 1: Amazon SQS with SNS Fan-out

Fully managed message queuing using SQS queues per consumer with SNS topics for fan-out when multiple services need the same event. Dead-letter queues for failure isolation. No infrastructure to operate.

**Strengths:**
- Zero operational overhead: no brokers, no ZooKeeper, no partition rebalancing
- Native IAM integration for access control within the CDE
- Encryption at rest (KMS) and in transit (TLS) with no additional configuration
- Per-queue scaling is automatic and independent
- Dead-letter queues are a first-class concept with built-in redrive
- Team has prior experience; estimated 1-week ramp-up

**Weaknesses:**
- No message replay capability: once consumed and deleted, messages are gone
- Maximum message size is 256KB (sufficient for our events but constraining for future payloads)
- No ordering guarantees on standard queues (FIFO queues support ordering but cap at 3,000 messages/second per queue with batching)
- Fan-out requires SNS+SQS pattern, adding infrastructure per consumer

**Estimated effort:** 3-4 weeks to implement across the authorization pipeline
**Estimated ongoing cost:** ~$200/month at current volume (pay-per-message)

### Option 2: Amazon MSK (Managed Kafka)

AWS-managed Apache Kafka clusters providing log-based messaging with consumer groups, topic partitioning, and message replay.

**Strengths:**
- Message replay and reprocessing from any offset
- Ordered delivery within partitions
- High throughput with batched writes
- Strong ecosystem: schema registry, Kafka Connect, stream processing
- Industry standard with broad community support

**Weaknesses:**
- Operational complexity: broker sizing, partition management, consumer group rebalancing, topic configuration
- Minimum cluster cost ~$1,200/month regardless of utilization (3 brokers, multi-AZ)
- Team has no Kafka operational experience; estimated 6-8 week ramp-up including incident readiness
- PCI compliance requires additional configuration: encryption, network isolation, access control via SASL/SCRAM
- Cluster upgrades require careful coordination to avoid downtime

**Estimated effort:** 8-10 weeks including operational readiness
**Estimated ongoing cost:** ~$1,500/month at current volume (cluster + storage)

### Option 3: Status Quo (Synchronous Processing)

Continue with the current synchronous request/response chain and address timeouts through retry logic and circuit breakers.

**Strengths:**
- No new infrastructure to introduce or learn
- Simpler debugging: request tracing follows a single thread
- No message serialization/deserialization overhead

**Weaknesses:**
- Does not solve the fundamental coupling problem
- Cascading failures will worsen as volume continues to grow
- Circuit breakers reduce availability rather than improving it
- p99 latency will continue to degrade without architectural change

**Estimated effort:** 2 weeks for retry/circuit breaker hardening
**Estimated ongoing cost:** No additional infrastructure cost, but increasing incident response cost

## Decision

We will adopt Amazon SQS with SNS fan-out for asynchronous messaging in the payment services pipeline. The zero operational overhead is the deciding factor: our team does not have Kafka expertise, and the 6-8 week ramp-up plus ongoing operational burden of MSK is disproportionate to our current messaging needs. SQS meets all functional requirements (at-least-once delivery, dead-letter handling, encryption, IAM-based access control) and aligns with our existing AWS and Terraform infrastructure patterns.

The lack of message replay is an accepted tradeoff. If replay becomes a requirement for audit or reprocessing use cases, we will evaluate MSK or EventBridge Archive at that point.

## Evaluation Matrix

| Criteria (Weight)               | SQS + SNS | MSK (Kafka) | Status Quo |
|---------------------------------|-----------|-------------|------------|
| Operational complexity (30%)    | 5/5       | 2/5         | 5/5        |
| Team readiness (25%)            | 5/5       | 2/5         | 5/5        |
| Scalability (20%)               | 4/5       | 5/5         | 2/5        |
| PCI compliance alignment (15%)  | 5/5       | 3/5         | 4/5        |
| Cost (10%)                      | 5/5       | 2/5         | 5/5        |
| **Weighted Score**              | **4.80**  | **2.70**    | **4.10**   |

## Consequences

### Positive
- Decoupled authorization pipeline eliminates cascading timeout failures
- Independent scaling per consumer queue handles traffic spikes without over-provisioning
- PCI-compliant encryption and access control with no additional configuration effort
- Dead-letter queues provide clear failure isolation and investigation path
- Platform engineering can publish SQS/SNS Terraform modules and Golden Path templates within 2 weeks

### Negative
- No message replay: debugging production issues requires log correlation rather than re-reading the stream
- Fan-out complexity grows linearly with consumers (one SQS queue per consuming service per topic)
- 256KB message size limit may require a claim-check pattern for future large-payload events
- FIFO queue throughput ceiling (3,000 msg/s with batching) could become a constraint at 3-5x current volume

### Risks
- **Volume growth exceeds FIFO limits**: If transaction volume grows beyond 3x current levels and ordering is required, FIFO queues may bottleneck. Mitigation: use standard queues with application-level idempotency (our current recommendation) and re-evaluate if ordering becomes a hard requirement.
- **Replay requirement emerges**: If audit or compliance requires message replay, SQS cannot satisfy this. Mitigation: evaluate EventBridge Archive or MSK if this requirement materializes. Current audit requirements are met through CloudTrail and application-level logging.

### Technical Debt Introduced
This decision defers investment in event streaming infrastructure. If the organization moves toward event-driven architecture broadly (beyond payments), a centralized streaming platform (MSK or equivalent) will likely be needed. This ADR should be revisited if more than 3 teams adopt async messaging independently.

## Follow-up Actions

- [ ] Publish SQS/SNS Terraform module to platform registry - Owner: Platform Engineering - Target: Sprint 14
- [ ] Create Golden Path template for SQS consumer services - Owner: Platform Engineering - Target: Sprint 15
- [ ] Implement async messaging in authorization pipeline - Owner: Payments Engineering - Target: Sprint 15-16
- [ ] Update PCI CDE network diagram to include SQS/SNS resources - Owner: Information Security - Target: Sprint 14
- [ ] Establish CloudWatch alarms for DLQ depth across payment queues - Owner: SRE - Target: Sprint 15

## References

- [Amazon SQS Developer Guide](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/)
- [Amazon SNS Fan-out Pattern](https://docs.aws.amazon.com/sns/latest/dg/sns-common-scenarios.html)
- ADR-001: Adopt ECS Fargate for Payment Service Runtime
- ADR-002: Use Aurora PostgreSQL for Payment Data Store
