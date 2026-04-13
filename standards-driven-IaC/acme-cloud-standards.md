# Acme Financial Services - Cloud Infrastructure Standards
**Version**: 3.1
**Effective Date**: January 2026
**Owner**: Platform Engineering
**Classification**: Internal

---

## 1. Purpose and Scope

This document defines the mandatory cloud infrastructure standards for all AWS resources deployed by Acme Financial Services. These standards apply to all environments (development, staging, production) unless a specific exception is noted. Resources that do not comply with these standards will be flagged by automated compliance scanning and must be remediated within 30 days.

## 2. Resource Naming and Tagging

### 2.1 Naming Convention

All AWS resources must follow the naming pattern:

```
{environment}-{application}-{resource_type}[-{qualifier}]
```

- **environment**: `dev`, `stg`, `prod`
- **application**: Short application identifier, lowercase, no spaces (e.g., `payments`, `auth`, `reports`)
- **resource_type**: Abbreviated resource type (e.g., `s3`, `rds`, `ecs`, `sg`, `vpc`, `lambda`)
- **qualifier**: Optional additional identifier (e.g., `logs`, `primary`, `replica`)

Examples:
- `prod-payments-s3-logs`
- `dev-auth-rds-primary`
- `stg-reports-ecs`

### 2.2 Required Tags

All taggable AWS resources must include the following tags:

| Tag Key | Required | Description | Example Values |
|---------|----------|-------------|----------------|
| Environment | Yes | Deployment environment | dev, stg, prod |
| Owner | Yes | Responsible team or individual | platform-engineering, payments-team |
| CostCenter | Yes | Finance cost allocation code | CC-4200, CC-3100 |
| Application | Yes | Application identifier | payments, auth, reports |
| ManagedBy | Yes | How the resource is managed | terraform, cloudformation, manual |
| DataClassification | Conditional | Required for data stores | Public, Internal, Confidential, Restricted |
| ComplianceScope | Conditional | Required for CDE resources | PCI, SOC2, None |
| ExpirationDate | Conditional | Required for temporary resources | 2026-06-30 |

Tags must use PascalCase for keys. Tag values are case-sensitive and must follow the formats above.

## 3. Encryption Standards

### 3.1 Encryption at Rest

All data stores must be encrypted at rest. This includes S3 buckets, RDS instances, EBS volumes, DynamoDB tables, and any other service that stores persistent data.

- **Production and staging**: Must use AWS KMS with customer-managed keys (CMK). AWS-managed keys are not permitted.
- **Development**: May use AWS-managed keys (aws/s3, aws/rds, etc.) to reduce cost.
- KMS key rotation must be enabled on all customer-managed keys.
- KMS key policies must restrict usage to specific IAM roles. Wildcard principals are prohibited.

### 3.2 Encryption in Transit

All data transmitted over a network must be encrypted using TLS 1.2 or higher.

- Load balancer listeners must use HTTPS with a minimum SSL policy of `ELBSecurityPolicy-TLS13-1-2-2021-06`.
- HTTP listeners are permitted only as redirects to HTTPS.
- RDS instances must enforce SSL connections via parameter group configuration.
- API Gateway endpoints must use TLS 1.2 minimum.
- Inter-service communication within a VPC should use TLS wherever feasible.

## 4. Network Standards

### 4.1 VPC Architecture

- Each environment (dev, stg, prod) must have a dedicated VPC.
- Production VPCs must span a minimum of 3 availability zones.
- Non-production VPCs must span a minimum of 2 availability zones.
- VPC CIDR blocks must be allocated from the corporate IP address plan. Contact the network team for allocation. Standard allocation is /16 per environment.
- All VPCs must have DNS resolution and DNS hostnames enabled.

### 4.2 Subnet Design

- Each VPC must contain at least two subnet tiers: **private** and **public**.
- Compute resources (EC2, ECS, RDS, Lambda) must be placed in **private subnets**.
- Only load balancers and NAT gateways may be placed in public subnets.
- Subnet CIDR blocks should be /24 for standard subnets.

### 4.3 Security Groups

- Security groups must use the naming convention: `{env}-{app}-{purpose}-sg`
- Ingress rules must specify source security groups or specific CIDR ranges. `0.0.0.0/0` ingress is prohibited except for public-facing load balancers on ports 80 (redirect only) and 443.
- SSH (port 22) and RDP (port 3389) ingress from `0.0.0.0/0` is prohibited under all circumstances. Use SSM Session Manager for administrative access.
- Egress rules should be scoped to required destinations. Blanket `0.0.0.0/0` egress is permitted for development but must be restricted in production.
- All security group rules must include a `description` field.

### 4.4 Public Access Restrictions

- No EC2 instances may have public IP addresses. Use a load balancer or NAT gateway for internet access.
- No RDS instances may have `publicly_accessible` set to `true`.
- S3 buckets must have S3 Block Public Access enabled at both the bucket and account level.
- All subnets with compute resources must have `map_public_ip_on_launch` set to `false`.

## 5. Compute Standards

### 5.1 Instance Types

- Only current-generation instance types are permitted (m6i, c6i, r6i, t3, or newer). Previous-generation types (m4, c4, r4, t2) are prohibited.
- Graviton-based instances (m7g, c7g, r7g, t4g) are preferred where application compatibility allows due to superior price-performance.
- Instance sizing must be justified. Oversized instances will be flagged in monthly FinOps reviews.

### 5.2 EBS Volumes

- All EBS volumes must use GP3. GP2 is prohibited (GP3 offers better price-performance with configurable IOPS).
- All EBS volumes must be encrypted (see Section 3.1).
- EBS volumes attached to terminated instances must be cleaned up within 7 days.

### 5.3 Auto Scaling

- Production workloads must use auto scaling unless explicitly exempted.
- Auto scaling policies must define both scale-up and scale-down thresholds.
- Scale-down cooldown period must be at least 300 seconds to prevent oscillation.

## 6. Database Standards

### 6.1 RDS Configuration

- Production RDS instances must be Multi-AZ.
- Non-production instances may be single-AZ to reduce cost.
- RDS instances must use current-generation instance classes (db.m6i, db.r6i, or newer).
- Backup retention must be at least 7 days for production and 1 day for non-production.
- Deletion protection must be enabled for production instances.
- All RDS instances must have CloudWatch log exports enabled (at minimum: audit).
- RDS instances must not be publicly accessible (see Section 4.4).

### 6.2 Connection Management

- Application connection pools must be sized appropriately. Maximum connections should not exceed 80% of the RDS instance max_connections parameter.
- For high-concurrency workloads, use RDS Proxy or PgBouncer for connection pooling.

## 7. Storage Standards

### 7.1 S3 Buckets

- All S3 buckets must have versioning enabled.
- All S3 buckets must have server-side encryption enabled (see Section 3.1).
- All S3 buckets must have S3 Block Public Access enabled (see Section 4.4).
- All S3 buckets must have access logging enabled, targeting the centralized logging bucket.
- Buckets storing non-archival data must have a lifecycle policy that transitions objects to Glacier after 90 days and expires objects after 365 days. Archival buckets may have longer retention but must still have a lifecycle policy.

### 7.2 S3 Bucket Policies

- Bucket policies must enforce TLS by denying requests where `aws:SecureTransport` is `false`.
- Bucket policies must not allow public access (`Principal: "*"` without appropriate conditions).

## 8. Logging and Monitoring

### 8.1 Required Logging

- CloudTrail must be enabled in all regions with log file validation.
- VPC Flow Logs must be enabled on all VPCs with traffic type set to ALL.
- S3 access logging must be enabled on all buckets (see Section 7.1).
- All application workloads must send structured logs to CloudWatch Logs.

### 8.2 Log Retention

- CloudWatch Logs: 90 days online, archived to S3 for 12 months total retention.
- CloudTrail logs: 12 months minimum retention in S3 with Glacier transition after 90 days.
- VPC Flow Logs: 90 days retention.

### 8.3 Monitoring and Alerting

- All production services must have CloudWatch alarms for key health metrics (CPU, memory, error rate, latency).
- All CloudWatch Log Groups must have the KMS key associated if the logs contain sensitive data.

## 9. IAM Standards

### 9.1 Role-Based Access

- All workloads must use IAM roles, not IAM users with access keys.
- IAM policies must follow the principle of least privilege: specific actions on specific resources.
- Wildcard actions (`Action: "*"`) and wildcard resources (`Resource: "*"`) in the same statement are prohibited.
- IAM role names must follow the naming convention: `{env}-{app}-{purpose}-role`

### 9.2 Service Accounts

- Service-to-service authentication must use IAM roles (not static credentials).
- Where static credentials are unavoidable (third-party integrations), they must be stored in AWS Secrets Manager with automatic rotation enabled.
- Secrets Manager secrets must be encrypted with a customer-managed KMS key in production.

## 10. Cost Governance

### 10.1 Resource Lifecycle

- All temporary resources must have an ExpirationDate tag.
- Resources without the ExpirationDate tag that are unused for 30 days will be flagged for cleanup.
- Non-production environments should be scheduled to scale down outside business hours (8 PM - 6 AM CT and weekends).

### 10.2 Instance Optimization

- Use Graviton instances where possible (see Section 5.1).
- Use GP3 instead of GP2 for all EBS volumes (see Section 5.2).
- Use S3 Intelligent-Tiering for buckets with unpredictable access patterns.
- Monitor and rightsize instances quarterly using AWS Compute Optimizer recommendations.
