# Standards Compliance Map

**Standards Document**: Acme Financial Services - Cloud Infrastructure Standards v3.1
**Generated Resources**: S3 bucket (transaction logs), RDS PostgreSQL (payments database)
**Environment**: Production
**Compliance Scope**: PCI

---

## Policy Extraction Summary

27 policies extracted from the standards document across 9 categories. 25 policies are applicable to the requested resources. 2 policies are not applicable (auto scaling, instance type for EC2 - no EC2 instances in this request).

---

## Resource-Level Compliance Map

### S3 Bucket: transaction-logs

| Configuration | Policy | Standards Reference |
|--------------|--------|-------------------|
| Bucket name: `prod-payments-s3-transaction-logs` | Naming convention: `{env}-{app}-{resource_type}[-{qualifier}]` | Section 2.1 |
| Tags: Environment, Owner, CostCenter, Application, ManagedBy, DataClassification, ComplianceScope | Required tags with PascalCase keys | Section 2.2 |
| SSE-KMS with customer-managed key | Production must use CMK, not AWS-managed keys | Section 3.1 |
| KMS key rotation enabled | Key rotation must be enabled on all CMKs | Section 3.1 |
| S3 Block Public Access: all four settings true | No public S3 access permitted | Section 4.4, 7.1 |
| Versioning enabled | All S3 buckets must have versioning enabled | Section 7.1 |
| Access logging to centralized bucket | All S3 buckets must have access logging enabled | Section 7.1, 8.1 |
| Lifecycle: Glacier at 90 days, expire at 365 days | Non-archival buckets must transition to Glacier at 90 days, expire at 365 | Section 7.1 |
| Bucket policy: deny non-SecureTransport | Bucket policies must enforce TLS | Section 7.2 |
| Bucket key enabled | Cost optimization for KMS-encrypted S3 | Best practice (not in standards) |

### RDS PostgreSQL: payments-primary

| Configuration | Policy | Standards Reference |
|--------------|--------|-------------------|
| Instance name: `prod-payments-rds-primary` | Naming convention | Section 2.1 |
| Tags: full standard tag set | Required tags | Section 2.2 |
| storage_encrypted = true with CMK | Production encryption at rest with CMK | Section 3.1 |
| Parameter group: rds.force_ssl = 1 | RDS must enforce SSL connections | Section 3.2 |
| publicly_accessible = false | RDS must not be publicly accessible | Section 4.4, 6.1 |
| Placed in private subnets | Compute resources must be in private subnets | Section 4.2 |
| Security group: ingress from app SGs only, port 5432 | Must specify source security groups, not 0.0.0.0/0 | Section 4.3 |
| Security group rules include description | All SG rules must include description | Section 4.3 |
| Instance class: db.m6i.large | Must use current-generation instance classes | Section 5.1, 6.1 |
| multi_az = true (production) | Production RDS must be Multi-AZ | Section 6.1 |
| backup_retention_period >= 7 | Production backup retention at least 7 days | Section 6.1 |
| deletion_protection = true (production) | Deletion protection required for production | Section 6.1 |
| CloudWatch log exports enabled | RDS must have log exports enabled | Section 6.1, 8.1 |
| Master password via Secrets Manager | Service credentials must use Secrets Manager | Section 9.2 |
| Secrets Manager secret encrypted with CMK | Production secrets must use CMK | Section 9.2 |
| Variable validation: blocks previous-gen instances | Previous-generation types prohibited | Section 5.1 |

### Security Group: rds-sg

| Configuration | Policy | Standards Reference |
|--------------|--------|-------------------|
| Name: `prod-payments-rds-sg` | Naming: `{env}-{app}-{purpose}-sg` | Section 4.3 |
| Ingress from security groups only | Must specify source SGs, not 0.0.0.0/0 | Section 4.3 |
| Ingress rule has description | All rules must include description | Section 4.3 |
| Egress scoped to VPC CIDR | Production egress must be restricted | Section 4.3 |
| Tags: standard tag set | Required tags | Section 2.2 |

### KMS Key

| Configuration | Policy | Standards Reference |
|--------------|--------|-------------------|
| Customer-managed key | Production must use CMK | Section 3.1 |
| enable_key_rotation = true | Key rotation required | Section 3.1 |
| Tags: standard tag set | Required tags | Section 2.2 |

### CloudWatch Log Group: RDS Logs

| Configuration | Policy | Standards Reference |
|--------------|--------|-------------------|
| retention_in_days = 90 | CloudWatch Logs: 90 days online | Section 8.2 |
| KMS encryption | Logs with sensitive data must use KMS | Section 8.3 |
| Tags: standard tag set | Required tags | Section 2.2 |

---

## Deviation Report

No deviations from the standards document were generated for this resource set. All requested resources comply with all applicable policies.

### Standards Not Addressed (Out of Scope for This Request)

| Policy | Standards Reference | Reason Not Addressed |
|--------|-------------------|---------------------|
| CloudTrail multi-region | Section 8.1 | Account-level resource, not part of application-level IaC |
| VPC Flow Logs | Section 8.1 | VPC is referenced, not created. Flow logs should be on the VPC module. |
| Auto Scaling | Section 5.3 | No compute resources (EC2/ECS) in this request |
| S3 Intelligent-Tiering | Section 10.2 | Transaction logs have predictable access; standard lifecycle is appropriate |
| Non-production scale-down scheduling | Section 10.1 | This is a production deployment |

---

## Variable Validation Summary

The generated `variables.tf` includes validation rules that enforce standards at plan time:

| Variable | Validation | Standards Reference |
|----------|-----------|-------------------|
| environment | Must be dev, stg, or prod | Section 2.1 |
| application | Must be lowercase alphanumeric with hyphens | Section 2.1 |
| cost_center | Must follow CC-NNNN format | Section 2.2 |
| data_classification | Must be Public, Internal, Confidential, or Restricted | Section 2.2 |
| compliance_scope | Must be PCI, SOC2, or None | Section 2.2 |
| db_instance_class | Blocks previous-generation instance types (m4, r4, t2) | Section 5.1 |
