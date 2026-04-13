# Generated from: Acme Financial Services - Cloud Infrastructure Standards v3.1
# Resource request: S3 bucket for payment transaction logs + RDS PostgreSQL for payments service
# Environment: Production
# Compliance scope: PCI

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Standard Tags (Section 2.2) ---
# All taggable resources must include these tags per Section 2.2

locals {
  standard_tags = {
    Environment        = var.environment
    Owner              = var.owner
    CostCenter         = var.cost_center
    Application        = var.application
    ManagedBy          = "terraform"
    DataClassification = var.data_classification
    ComplianceScope    = var.compliance_scope
  }

  # Naming convention per Section 2.1: {environment}-{application}-{resource_type}[-{qualifier}]
  name_prefix = "${var.environment}-${var.application}"
}

# --- KMS Key (Section 3.1) ---
# Production must use customer-managed keys; AWS-managed keys are not permitted

resource "aws_kms_key" "data" {
  description         = "CMK for ${local.name_prefix} data encryption"
  enable_key_rotation = true # Per Section 3.1: KMS key rotation must be enabled

  # Per Section 3.1: KMS key policies must restrict usage to specific IAM roles
  # Wildcard principals are prohibited
  tags = merge(local.standard_tags, {
    Name = "${local.name_prefix}-data-key"
  })
}

resource "aws_kms_alias" "data" {
  name          = "alias/${local.name_prefix}-data"
  target_key_id = aws_kms_key.data.key_id
}

# --- S3 Bucket: Transaction Logs (Sections 3.1, 4.4, 7.1, 7.2, 8.1) ---

resource "aws_s3_bucket" "transaction_logs" {
  bucket = "${local.name_prefix}-s3-transaction-logs"

  tags = merge(local.standard_tags, {
    Name    = "${local.name_prefix}-s3-transaction-logs"
    Purpose = "payment-transaction-logs"
  })
}

# Per Section 7.1: All S3 buckets must have versioning enabled
resource "aws_s3_bucket_versioning" "transaction_logs" {
  bucket = aws_s3_bucket.transaction_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Per Section 3.1: Production must use SSE-KMS with customer-managed keys
resource "aws_s3_bucket_server_side_encryption_configuration" "transaction_logs" {
  bucket = aws_s3_bucket.transaction_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.data.arn
    }
    bucket_key_enabled = true
  }
}

# Per Section 4.4 & 7.1: S3 Block Public Access must be enabled
resource "aws_s3_bucket_public_access_block" "transaction_logs" {
  bucket                  = aws_s3_bucket.transaction_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Per Section 7.1: Access logging must be enabled targeting centralized logging bucket
resource "aws_s3_bucket_logging" "transaction_logs" {
  bucket        = aws_s3_bucket.transaction_logs.id
  target_bucket = var.logging_bucket_id
  target_prefix = "${aws_s3_bucket.transaction_logs.id}/"
}

# Per Section 7.1: Lifecycle policy - Glacier after 90 days, expire after 365 days
resource "aws_s3_bucket_lifecycle_configuration" "transaction_logs" {
  bucket = aws_s3_bucket.transaction_logs.id

  rule {
    id     = "standard-lifecycle"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# Per Section 7.2: Bucket policy must enforce TLS (deny non-SecureTransport)
resource "aws_s3_bucket_policy" "transaction_logs_tls" {
  bucket = aws_s3_bucket.transaction_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.transaction_logs.arn,
          "${aws_s3_bucket.transaction_logs.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# --- RDS PostgreSQL: Payments Database (Sections 3.1, 3.2, 4.4, 6.1, 8.1) ---

# Per Section 3.2: RDS must enforce SSL via parameter group
resource "aws_db_parameter_group" "payments" {
  family = "postgres15"
  name   = "${local.name_prefix}-rds-params"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  tags = local.standard_tags
}

resource "aws_db_subnet_group" "payments" {
  name       = "${local.name_prefix}-rds-subnets"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.standard_tags, {
    Name = "${local.name_prefix}-rds-subnets"
  })
}

resource "aws_db_instance" "payments" {
  identifier = "${local.name_prefix}-rds-primary"
  engine     = "postgres"
  engine_version = var.db_engine_version

  # Per Section 6.1: Must use current-generation instance classes (db.m6i, db.r6i, or newer)
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage

  # Per Section 3.1: Production must use SSE-KMS with CMK
  storage_encrypted = true
  kms_key_id        = aws_kms_key.data.arn

  # Per Section 4.4: RDS must not be publicly accessible
  publicly_accessible = false

  # Per Section 6.1: Production must be Multi-AZ
  multi_az = var.environment == "production" ? true : false

  db_subnet_group_name = aws_db_subnet_group.payments.name
  parameter_group_name = aws_db_parameter_group.payments.name

  vpc_security_group_ids = [aws_security_group.rds.id]

  # Per Section 6.1: Backup retention at least 7 days for production
  backup_retention_period = var.environment == "production" ? max(var.backup_retention_days, 7) : max(var.backup_retention_days, 1)

  # Per Section 6.1: Deletion protection must be enabled for production
  deletion_protection = var.environment == "production" ? true : false

  # Per Section 6.1 & 8.1: CloudWatch log exports must be enabled
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Credentials from Secrets Manager per Section 9.2
  username                    = var.db_username
  manage_master_user_password = true
  master_user_secret_kms_key_id = aws_kms_key.data.arn

  skip_final_snapshot       = var.environment != "production"
  final_snapshot_identifier = var.environment == "production" ? "${local.name_prefix}-rds-final" : null

  tags = merge(local.standard_tags, {
    Name = "${local.name_prefix}-rds-primary"
  })
}

# --- Security Group for RDS (Section 4.3) ---
# Per Section 4.3: Must specify source security groups, not 0.0.0.0/0

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Security group for ${local.name_prefix} RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.app_security_group_ids
    description     = "Allow PostgreSQL from application security groups"
  }

  # Per Section 4.3: Production egress should be restricted
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow all traffic within VPC"
  }

  tags = merge(local.standard_tags, {
    Name = "${local.name_prefix}-rds-sg"
  })
}

# --- CloudWatch Log Group for RDS (Section 8.2) ---
# Per Section 8.2: 90 days online retention

resource "aws_cloudwatch_log_group" "rds_logs" {
  name              = "/aws/rds/instance/${local.name_prefix}-rds-primary/postgresql"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.data.arn

  tags = local.standard_tags
}
