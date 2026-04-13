# General Cloud Security Controls

Baseline security controls for AWS infrastructure. Apply by default when no specific framework is requested.

## Encryption

### SEC-001: S3 Bucket Encryption at Rest
- **Applies To**: `aws_s3_bucket`, `aws_s3_bucket_server_side_encryption_configuration`, `AWS::S3::Bucket`
- **Check**: Bucket has server-side encryption configured with AES-256 or AWS KMS
- **Severity**: High
- **Remediation**: Add `server_side_encryption_configuration` block with `sse_algorithm = "aws:kms"` or `"AES256"`

### SEC-002: RDS Encryption at Rest
- **Applies To**: `aws_db_instance`, `aws_rds_cluster`, `AWS::RDS::DBInstance`, `AWS::RDS::DBCluster`
- **Check**: `storage_encrypted = true` is explicitly set
- **Severity**: Critical
- **Remediation**: Set `storage_encrypted = true` and specify a `kms_key_id`

### SEC-003: EBS Volume Encryption
- **Applies To**: `aws_ebs_volume`, `aws_launch_template`, `AWS::EC2::Volume`
- **Check**: `encrypted = true` is explicitly set
- **Severity**: High
- **Remediation**: Set `encrypted = true` and optionally specify `kms_key_id`

### SEC-004: Encryption in Transit
- **Applies To**: `aws_lb_listener`, `aws_alb_listener`, `AWS::ElasticLoadBalancingV2::Listener`
- **Check**: Listener protocol is HTTPS or TLS, not HTTP. If HTTP listener exists, it should redirect to HTTPS.
- **Severity**: High
- **Remediation**: Set `protocol = "HTTPS"` and configure `ssl_policy` and `certificate_arn`

## Access Control

### SEC-005: S3 Public Access Block
- **Applies To**: `aws_s3_bucket_public_access_block`, `aws_s3_bucket`, `AWS::S3::Bucket`
- **Check**: All four public access block settings are `true`: `block_public_acls`, `block_public_policy`, `ignore_public_acls`, `restrict_public_buckets`
- **Severity**: Critical
- **Remediation**: Add `aws_s3_bucket_public_access_block` resource with all four settings set to `true`

### SEC-006: IAM Policy Least Privilege
- **Applies To**: `aws_iam_policy`, `aws_iam_role_policy`, `aws_iam_policy_document`, `AWS::IAM::Policy`
- **Check**: No statement uses `"Action": "*"` or `"Resource": "*"` in combination. Wildcard actions are acceptable only when scoped to specific resources, and wildcard resources only with specific actions.
- **Severity**: Critical
- **Remediation**: Replace `"*"` with specific actions and resource ARNs. Use separate statements for different permission scopes.

### SEC-007: IAM Role Trust Policy Scope
- **Applies To**: `aws_iam_role`, `AWS::IAM::Role`
- **Check**: `assume_role_policy` does not allow `"Principal": "*"` or `"Principal": {"AWS": "*"}`
- **Severity**: Critical
- **Remediation**: Restrict the principal to specific accounts, services, or ARNs

### SEC-008: Security Group Ingress Restrictions
- **Applies To**: `aws_security_group`, `aws_security_group_rule`, `AWS::EC2::SecurityGroup`
- **Check**: No ingress rule allows `0.0.0.0/0` or `::/0` on ports other than 80 and 443. SSH (22) and RDP (3389) must not be open to the internet.
- **Severity**: Critical
- **Remediation**: Restrict source CIDR to known IP ranges or reference security groups. Use a bastion host or SSM Session Manager for administrative access.

## Logging and Monitoring

### SEC-009: S3 Bucket Logging
- **Applies To**: `aws_s3_bucket_logging`, `aws_s3_bucket`, `AWS::S3::Bucket`
- **Check**: Access logging is enabled with a target bucket specified
- **Severity**: Medium
- **Remediation**: Add `aws_s3_bucket_logging` resource pointing to a dedicated logging bucket

### SEC-010: CloudTrail Enabled
- **Applies To**: `aws_cloudtrail`, `AWS::CloudTrail::Trail`
- **Check**: If infrastructure includes IAM roles, S3 buckets, or databases, a CloudTrail trail should be present in the configuration
- **Severity**: High
- **Remediation**: Add an `aws_cloudtrail` resource with `is_multi_region_trail = true` and log file validation enabled

### SEC-011: RDS Audit Logging
- **Applies To**: `aws_db_instance`, `aws_rds_cluster`, `AWS::RDS::DBInstance`
- **Check**: `enabled_cloudwatch_logs_exports` includes audit or general logs
- **Severity**: Medium
- **Remediation**: Add `enabled_cloudwatch_logs_exports = ["audit", "general"]`

## Networking

### SEC-012: No Default VPC Usage
- **Applies To**: `aws_instance`, `aws_db_instance`, `aws_lambda_function`
- **Check**: Resource explicitly specifies `subnet_id` or `vpc_id` rather than relying on default VPC
- **Severity**: Medium
- **Remediation**: Explicitly assign resources to a purpose-built VPC and subnet

### SEC-013: RDS Not Publicly Accessible
- **Applies To**: `aws_db_instance`, `aws_rds_cluster`, `AWS::RDS::DBInstance`
- **Check**: `publicly_accessible = false` is explicitly set
- **Severity**: Critical
- **Remediation**: Set `publicly_accessible = false` and place the instance in a private subnet

## Tagging

### SEC-014: Required Tags Present
- **Applies To**: All taggable resources
- **Check**: Resource includes tags for `Environment`, `Owner`, and `Application`
- **Severity**: Low
- **Remediation**: Add a `tags` block with at minimum `Environment`, `Owner`, and `Application` keys

## Secrets Management

### SEC-015: No Hardcoded Secrets
- **Applies To**: All resources
- **Check**: No property values appear to contain hardcoded passwords, API keys, or secret strings. Watch for properties named `password`, `secret`, `api_key`, `token`, `credentials` with literal string values (not variable references).
- **Severity**: Critical
- **Remediation**: Use `aws_secretsmanager_secret` or variable references with sensitive flag. Never commit secrets to IaC templates.

### SEC-016: KMS Key Rotation
- **Applies To**: `aws_kms_key`, `AWS::KMS::Key`
- **Check**: `enable_key_rotation = true` is set
- **Severity**: Medium
- **Remediation**: Set `enable_key_rotation = true`
