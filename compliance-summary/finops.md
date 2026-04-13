# FinOps Controls for Cloud Infrastructure

Controls focused on cost governance, tagging for billing visibility, rightsizing, and lifecycle management. Use this framework when the user is concerned with cloud spend optimization, budget governance, or cost allocation accuracy.

## Cost Allocation Tagging

### FIN-001: Billing Tags Present
- **Applies To**: All taggable resources
- **Check**: Resource includes tags for `CostCenter`, `Application`, and `Environment`. These are the minimum required for cost allocation reporting.
- **Severity**: High
- **Remediation**: Add `tags` block with `CostCenter`, `Application`, and `Environment` keys. Values should follow organizational naming conventions.

### FIN-002: Owner Tag for Accountability
- **Applies To**: All taggable resources
- **Check**: Resource includes an `Owner` tag with a team or individual identifier
- **Severity**: Medium
- **Remediation**: Add `Owner` tag with the responsible team or engineering lead's identifier

### FIN-003: Tag Propagation on Auto Scaling
- **Applies To**: `aws_autoscaling_group`, `aws_launch_template`, `AWS::AutoScaling::AutoScalingGroup`
- **Check**: Auto scaling groups propagate tags to launched instances (`propagate_at_launch = true`)
- **Severity**: Medium
- **Remediation**: Set `propagate_at_launch = true` on each tag in the auto scaling group configuration

## Compute Rightsizing

### FIN-004: Instance Type Appropriateness
- **Applies To**: `aws_instance`, `aws_launch_template`, `AWS::EC2::Instance`
- **Check**: Instance type is not in the previous generation family (e.g., `m4`, `c4`, `r4`, `t2`). Current generation equivalents (`m6i`, `c6i`, `r6i`, `t3`) offer better price-performance.
- **Severity**: Low
- **Remediation**: Replace previous-generation instance types with current-generation equivalents. Example: `m4.xlarge` to `m6i.xlarge`

### FIN-005: RDS Instance Generation
- **Applies To**: `aws_db_instance`, `AWS::RDS::DBInstance`
- **Check**: RDS instance class is not previous generation (e.g., `db.m4`, `db.r4`). Current generation classes (`db.m6i`, `db.r6i`) offer better price-performance.
- **Severity**: Low
- **Remediation**: Upgrade to current-generation RDS instance class

### FIN-006: GP2 to GP3 Migration
- **Applies To**: `aws_ebs_volume`, `aws_launch_template`, `AWS::EC2::Volume`
- **Check**: EBS volume type is `gp3`, not `gp2`. GP3 is cheaper and offers configurable IOPS/throughput.
- **Severity**: Medium
- **Remediation**: Change `type = "gp2"` to `type = "gp3"`. Adjust `iops` and `throughput` if needed.

## Storage Lifecycle

### FIN-007: S3 Lifecycle Policy
- **Applies To**: `aws_s3_bucket_lifecycle_configuration`, `aws_s3_bucket`, `AWS::S3::Bucket`
- **Check**: Buckets have lifecycle rules that transition objects to cheaper storage classes (Glacier, Intelligent-Tiering) or expire them after a defined period
- **Severity**: Medium
- **Remediation**: Add `aws_s3_bucket_lifecycle_configuration` with transition rules (e.g., to `GLACIER` after 90 days) and/or expiration rules for temporary data

### FIN-008: EBS Snapshot Lifecycle
- **Applies To**: `aws_ebs_volume`, `aws_dlm_lifecycle_policy`
- **Check**: If EBS volumes are present, a Data Lifecycle Manager policy exists to manage snapshot retention and cleanup
- **Severity**: Low
- **Remediation**: Create an `aws_dlm_lifecycle_policy` targeting the relevant volumes with appropriate retention rules

## Reserved Capacity and Commitments

### FIN-009: RDS Multi-AZ Justification
- **Applies To**: `aws_db_instance`, `aws_rds_cluster`, `AWS::RDS::DBInstance`
- **Check**: If `multi_az = true` is set, verify the environment tag suggests production. Multi-AZ in dev/test environments doubles cost without meaningful benefit.
- **Severity**: Medium
- **Remediation**: Set `multi_az = false` for non-production environments. Reserve Multi-AZ for production workloads.

### FIN-010: NAT Gateway Count
- **Applies To**: `aws_nat_gateway`, `AWS::EC2::NatGateway`
- **Check**: If multiple NAT gateways exist, verify they correspond to multiple availability zones in production. Redundant NAT gateways in dev/test add cost.
- **Severity**: Low
- **Remediation**: Use a single NAT gateway in non-production environments. Reserve per-AZ NAT gateways for production.

## Monitoring Cost Awareness

### FIN-011: CloudWatch Log Retention
- **Applies To**: `aws_cloudwatch_log_group`, `AWS::Logs::LogGroup`
- **Check**: Log group has an explicit `retention_in_days` set. Without this, logs are retained indefinitely, accumulating cost.
- **Severity**: Medium
- **Remediation**: Set `retention_in_days` to an appropriate value (e.g., 30, 60, 90) based on operational and compliance needs

### FIN-012: Detailed Monitoring Awareness
- **Applies To**: `aws_instance`, `AWS::EC2::Instance`
- **Check**: If `monitoring = true` (detailed monitoring) is enabled, note that this incurs additional CloudWatch charges. Acceptable for production, may be unnecessary for dev/test.
- **Severity**: Low
- **Remediation**: Set `monitoring = false` for non-production instances unless detailed 1-minute metrics are required
