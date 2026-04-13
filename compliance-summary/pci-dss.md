# PCI DSS Controls for Cloud Infrastructure

Controls derived from PCI DSS v4.0 requirements as they apply to infrastructure-as-code definitions. These controls focus on the infrastructure layer; application-layer PCI requirements are out of scope.

Use this framework when reviewing infrastructure that stores, processes, or transmits cardholder data, or infrastructure within the cardholder data environment (CDE).

## Requirement 1: Network Security Controls

### PCI-001: Network Segmentation
- **Applies To**: `aws_security_group`, `aws_vpc`, `aws_subnet`, `AWS::EC2::SecurityGroup`, `AWS::EC2::VPC`
- **Check**: CDE resources are placed in dedicated subnets with security groups that restrict traffic to only necessary flows. No security group allows unrestricted ingress from non-CDE subnets.
- **Severity**: Critical
- **Remediation**: Create dedicated CDE subnets and security groups. Restrict ingress to specific source security groups or CIDR ranges within the CDE. Deny all other traffic by default.

### PCI-002: Deny All Default Rule
- **Applies To**: `aws_security_group`, `AWS::EC2::SecurityGroup`
- **Check**: Security groups do not include overly broad egress rules (`0.0.0.0/0` on all ports). Egress should be scoped to required destinations.
- **Severity**: High
- **Remediation**: Replace blanket egress rules with specific destination CIDR ranges and ports required for the application.

## Requirement 2: Secure Configuration

### PCI-003: No Default Credentials
- **Applies To**: `aws_db_instance`, `aws_rds_cluster`, all resources with `password` or `master_password` attributes
- **Check**: Passwords are not hardcoded. Values reference `aws_secretsmanager_secret`, variables with `sensitive = true`, or SSM parameters.
- **Severity**: Critical
- **Remediation**: Replace literal password values with `aws_secretsmanager_secret_version` data source or a sensitive variable reference.

### PCI-004: Disable Unnecessary Services
- **Applies To**: `aws_db_instance`, `aws_instance`
- **Check**: RDS instances do not enable `publicly_accessible`. EC2 instances do not expose unnecessary ports via security group rules.
- **Severity**: High
- **Remediation**: Set `publicly_accessible = false`. Review attached security groups and remove ingress rules for unused ports.

## Requirement 3: Protect Stored Account Data

### PCI-005: Encryption at Rest for CDE Data Stores
- **Applies To**: `aws_s3_bucket`, `aws_db_instance`, `aws_rds_cluster`, `aws_ebs_volume`, `aws_dynamodb_table`
- **Check**: All data stores within the CDE have encryption at rest enabled using AWS KMS (not just AES-256). KMS key should be customer-managed, not AWS-managed.
- **Severity**: Critical
- **Remediation**: Enable encryption with a customer-managed KMS key. Set `kms_key_id` to a CMK ARN, not the default AWS-managed key.

### PCI-006: KMS Key Policy Restrictions
- **Applies To**: `aws_kms_key`, `aws_kms_key_policy`, `AWS::KMS::Key`
- **Check**: KMS key policy restricts usage to specific IAM roles/principals within the CDE. Key policy does not allow `"Principal": "*"`.
- **Severity**: Critical
- **Remediation**: Restrict `Principal` in the key policy to specific CDE service roles and admin roles. Enable key rotation.

## Requirement 4: Protect Data in Transit

### PCI-007: TLS Enforcement
- **Applies To**: `aws_lb_listener`, `aws_alb_listener`, `aws_api_gateway_stage`, `AWS::ElasticLoadBalancingV2::Listener`
- **Check**: All listeners use HTTPS/TLS. HTTP listeners redirect to HTTPS. API Gateway stages have a minimum TLS version of 1.2.
- **Severity**: Critical
- **Remediation**: Set listener protocol to HTTPS with `ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"` or newer. Add HTTP-to-HTTPS redirect.

### PCI-008: RDS Encryption in Transit
- **Applies To**: `aws_db_instance`, `aws_rds_cluster`, `aws_db_parameter_group`
- **Check**: Parameter group includes `rds.force_ssl = 1` (MySQL/MariaDB) or `ssl = 1` equivalent for the engine
- **Severity**: High
- **Remediation**: Create or modify the DB parameter group to enforce SSL connections

## Requirement 7: Restrict Access by Business Need

### PCI-009: Least Privilege IAM for CDE
- **Applies To**: `aws_iam_policy`, `aws_iam_role_policy`, `AWS::IAM::Policy`
- **Check**: IAM policies attached to CDE roles use specific actions and resource ARNs. No wildcard actions or resources. Policies follow the principle of least privilege.
- **Severity**: Critical
- **Remediation**: Replace `"Action": "*"` with enumerated actions. Replace `"Resource": "*"` with specific ARNs of CDE resources.

### PCI-010: Separate CDE IAM Roles
- **Applies To**: `aws_iam_role`, `AWS::IAM::Role`
- **Check**: Roles used for CDE workloads are distinct from roles used for non-CDE workloads. A single role should not span CDE and non-CDE resources.
- **Severity**: High
- **Remediation**: Create dedicated IAM roles for CDE workloads with trust policies scoped to CDE services only.

## Requirement 10: Log and Monitor Access

### PCI-011: CloudTrail for CDE
- **Applies To**: `aws_cloudtrail`, `AWS::CloudTrail::Trail`
- **Check**: CloudTrail is enabled with multi-region coverage, log file validation, and logs delivered to an encrypted S3 bucket with access logging.
- **Severity**: Critical
- **Remediation**: Create a CloudTrail trail with `is_multi_region_trail = true`, `enable_log_file_validation = true`, and `s3_bucket_name` pointing to an encrypted, access-logged bucket.

### PCI-012: Access Logging on CDE Data Stores
- **Applies To**: `aws_s3_bucket_logging`, `aws_s3_bucket`, `AWS::S3::Bucket`
- **Check**: All S3 buckets in the CDE have access logging enabled
- **Severity**: High
- **Remediation**: Add `aws_s3_bucket_logging` resource for each CDE bucket, targeting a centralized logging bucket.

### PCI-013: VPC Flow Logs
- **Applies To**: `aws_flow_log`, `aws_vpc`, `AWS::EC2::FlowLog`
- **Check**: VPC flow logs are enabled for CDE VPCs with traffic type set to ALL
- **Severity**: High
- **Remediation**: Add `aws_flow_log` resource attached to the CDE VPC with `traffic_type = "ALL"` and delivery to CloudWatch Logs or S3.

## Requirement 12: Organizational Policies (Infrastructure Layer)

### PCI-014: Resource Tagging for CDE Scope
- **Applies To**: All taggable resources
- **Check**: CDE resources include tags identifying them as in-scope: `DataClassification`, `ComplianceScope = "PCI"`, `Environment`, and `Owner`
- **Severity**: Medium
- **Remediation**: Add tags: `DataClassification = "Cardholder"`, `ComplianceScope = "PCI"`, plus `Environment` and `Owner`
