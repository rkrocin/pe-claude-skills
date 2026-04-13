# Batch Job Golden Path

Reference definition for batch processing service scaffolds. Covers scheduled ETL jobs, data pipelines, report generators, and periodic maintenance tasks.

## Directory Structure

```
{service-name}/
├── app/
│   ├── src/
│   │   ├── {main entry}         # Job entry point with argument parsing
│   │   ├── steps/               # Individual job steps, one file per step
│   │   ├── models/              # Data models for input/output
│   │   ├── services/            # Shared logic (data access, transformations)
│   │   ├── config.{ext}         # Configuration from environment variables
│   │   └── checkpoint.{ext}     # Checkpoint/resume logic for long-running jobs
│   ├── tests/
│   │   ├── test_steps.{ext}     # Step unit tests with sample data
│   │   └── fixtures/            # Sample input data files
│   ├── Dockerfile
│   └── {dependency manifest}
├── infra/
│   ├── main.tf                  # Step Functions / ECS task / Lambda + EventBridge
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

## Runtime Patterns

### ECS Fargate Task (Default for long-running jobs)
- Standalone ECS task (not a service) triggered by EventBridge schedule or Step Functions
- Exit code 0 on success, non-zero on failure
- CloudWatch log group with retention
- Timeout configuration to prevent runaway jobs
- Appropriate for jobs running minutes to hours

### Step Functions (Multi-step workflows)
- State machine definition with step orchestration
- Error handling per step with retry and catch
- Parallel execution for independent steps
- Map state for processing collections
- Appropriate when steps have different failure modes or need independent retry

### Lambda + EventBridge (Short jobs)
- EventBridge rule with cron expression
- Lambda function with appropriate timeout (max 15 minutes)
- Appropriate for quick, frequent jobs (data syncs, health checks, cleanup)

## Job Patterns

### Checkpoint and Resume
- For jobs processing large datasets, checkpoint progress periodically
- Store checkpoint in DynamoDB or S3: `{job_id, last_processed_key, timestamp}`
- On restart, read checkpoint and resume from last position
- Checkpoint interval: every N records or every M minutes, whichever comes first
- Final checkpoint marks job as complete

### Idempotent Execution
- Job should produce the same result if run multiple times for the same input period
- Use "replace" semantics (truncate-and-load or upsert) rather than "append"
- Include the processing window (date range, batch ID) in output metadata

### Input/Output Contract
- Input source and format documented in config (S3 path pattern, database query, API endpoint)
- Output destination and format documented in config
- Validate input before processing: schema check, row count sanity, freshness check
- Write output atomically: write to temp location, validate, then move to final location

## Infrastructure Patterns (Terraform)

### Scheduled ECS Task
```
Resources:
- aws_ecs_task_definition (job container)
- aws_cloudwatch_event_rule with schedule_expression (cron or rate)
- aws_cloudwatch_event_target pointing to ECS task
- aws_iam_role for task execution and task role
- aws_iam_role for EventBridge to run ECS tasks
- aws_cloudwatch_log_group with retention
- aws_cloudwatch_metric_alarm on task failures

Key decisions:
- EventBridge cron over ECS scheduled tasks for better visibility
- Task CPU/memory sized for peak processing, not average
- No auto scaling (single execution per trigger)
- Alarm on FailedInvocations metric
```

### Step Functions Workflow
```
Resources:
- aws_sfn_state_machine with definition
- aws_cloudwatch_event_rule triggering the state machine
- aws_iam_role for Step Functions execution
- Individual Lambda functions or ECS tasks per step
- aws_cloudwatch_metric_alarm on ExecutionsFailed

Key decisions:
- Standard workflow for jobs under 1 year (not Express)
- Retry configuration per step: maxAttempts 3, backoffRate 2.0
- Catch blocks route failures to notification step
- Execution input includes processing window parameters
```

## Observability

### Structured Logging
- JSON format: `timestamp`, `level`, `message`, `service`, `job_id`, `step`
- Log at INFO: job start, step start/complete, checkpoint, job complete
- Log at ERROR: step failure, validation failure, timeout
- Include record counts: `records_processed`, `records_skipped`, `records_failed`
- Duration logging: `step_duration_ms`, `total_duration_ms`

### Metrics
- Job execution count (success/failure)
- Job duration
- Records processed per execution
- Records failed per execution
- Checkpoint count per execution

### Alerting
- Job failure: immediate alert (P2)
- Job duration exceeds 2x historical average: alert (P3)
- Job did not run in expected window: alert (P2, for scheduled jobs)
- Records failed > 1% of total: alert (P3)

### Runbook Content
Batch job runbooks should cover:
- How to trigger a manual run (with specific date range)
- How to resume a failed job from checkpoint
- How to reprocess a specific date range
- How to validate output after a run
- Known failure modes and resolution steps
