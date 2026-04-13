# Event Consumer Golden Path

Reference definition for event-driven consumer service scaffolds. Covers SQS consumers, SNS subscribers, Kafka consumers, and EventBridge targets.

## Directory Structure

```
{service-name}/
├── app/
│   ├── src/
│   │   ├── {main entry}         # Consumer bootstrap and event loop
│   │   ├── handlers/            # Event handler functions, one per event type
│   │   ├── models/              # Event schema definitions
│   │   ├── services/            # Business logic layer
│   │   ├── config.{ext}         # Configuration from environment variables
│   │   └── health.{ext}         # Health check (processing status, lag metrics)
│   ├── tests/
│   │   ├── test_handlers.{ext}  # Handler unit tests with sample events
│   │   └── fixtures/            # Sample event payloads for testing
│   ├── Dockerfile
│   └── {dependency manifest}
├── infra/
│   ├── main.tf                  # Queue/topic, DLQ, consumer compute, IAM
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

## Event Source Patterns

### SQS Consumer (Default)
- Long polling with `WaitTimeSeconds = 20`
- Batch processing with configurable batch size (default 10)
- Per-message error handling: failures go to DLQ, successes are deleted
- Visibility timeout set to 6x expected processing time
- DLQ with `maxReceiveCount = 3` and alarm on DLQ depth
- Graceful shutdown: stop polling, finish in-flight batch, then exit

### SNS Subscriber
- SQS subscription to SNS topic (fan-out pattern)
- Subscription filter policy if only specific event types are needed
- Raw message delivery enabled to avoid double-encoding
- Same SQS consumer patterns apply downstream

### Kafka Consumer
- Consumer group with explicit group ID derived from service name
- Manual offset commit after successful processing
- Configurable max poll records and session timeout
- Backpressure handling: pause partitions when processing is slow
- Schema registry integration for Avro/Protobuf deserialization

### EventBridge Target
- Rule matching specific event patterns
- SQS queue as target (buffer between EventBridge and consumer)
- DLQ on the EventBridge rule for delivery failures
- Input transformation if event shape needs normalization

## Infrastructure Patterns (Terraform)

### SQS + ECS Fargate Consumer
```
Resources:
- aws_sqs_queue (main queue) with encryption, visibility timeout
- aws_sqs_queue (DLQ) with message retention
- aws_sqs_queue_redrive_policy linking main to DLQ
- aws_ecs_task_definition (consumer process)
- aws_ecs_service with desired_count based on expected throughput
- aws_appautoscaling_target scaling on ApproximateNumberOfMessagesVisible
- aws_cloudwatch_metric_alarm on DLQ depth
- aws_iam_role with SQS receive/delete permissions only

Key decisions:
- Scale on queue depth, not CPU (event consumers are I/O bound)
- DLQ alarm threshold: alert if > 0 messages (any DLQ message needs investigation)
- Minimum 2 tasks for availability, scale up based on backlog
```

### Lambda Consumer
```
Resources:
- aws_sqs_queue with encryption
- aws_sqs_queue (DLQ)
- aws_lambda_function with SQS event source mapping
- aws_lambda_event_source_mapping with batch size, batching window
- aws_iam_role with SQS permissions
- aws_cloudwatch_metric_alarm on DLQ depth and Lambda errors

Key decisions:
- Batch size tuned to processing time (stay under Lambda timeout)
- Batching window for cost optimization on low-throughput queues
- Partial batch failure reporting enabled
- Reserved concurrency to prevent downstream overload
```

## Reliability Patterns

### Idempotency
- Every handler must be idempotent. Messages can be delivered more than once.
- Use a deduplication key (message ID or business key) stored in DynamoDB or Redis
- Check-before-process pattern: look up dedup key, skip if already processed, process and record if new

### Retry and Backoff
- SQS visibility timeout provides automatic retry on failure
- Application-level retry for transient downstream failures (exponential backoff with jitter)
- Circuit breaker for downstream dependencies that are persistently failing
- After max retries, message moves to DLQ for manual investigation

### Dead Letter Queue Handling
- DLQ messages retain the original body and metadata
- Include a redrive script in the Makefile: `make redrive-dlq` moves messages back to the main queue
- Runbook documents the DLQ investigation and redrive process
- CloudWatch alarm on DLQ depth with notification to the team

### Graceful Shutdown
- Catch SIGTERM signal (ECS sends this before stopping tasks)
- Stop accepting new messages from the queue
- Finish processing the current batch
- Exit cleanly after in-flight work completes
- Shutdown timeout should be less than ECS `stopTimeout` (default 30s)

## Observability

### Structured Logging
- Same JSON format as REST API: `timestamp`, `level`, `message`, `service`, `trace_id`
- Additional fields: `message_id`, `event_type`, `queue_name`, `processing_duration_ms`
- Log at INFO level for each message processed
- Log at ERROR level for processing failures with the message ID (not the full body if it contains sensitive data)

### Metrics
- Messages received count
- Messages processed successfully count
- Messages failed count
- Processing duration histogram
- Queue depth (approximate number of messages visible)
- DLQ depth
- Consumer lag (Kafka only: offset lag per partition)

### Health Check
- Event consumers still expose a health endpoint on a lightweight HTTP server
- `/health`: Process is running and polling
- `/ready`: Can reach the queue and downstream dependencies
- Health check port separate from any application port (e.g., 8081)

### Alerting
- DLQ depth > 0: immediate alert (P2)
- Processing error rate > 5%: alert (P2)
- Consumer lag increasing for > 15 minutes: alert (P3)
- No messages processed in expected window: alert (P3, for scheduled producers)
