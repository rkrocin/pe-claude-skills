# sample-compliant.tf
# Well-architected Terraform configuration demonstrating compliance with
# general security, PCI DSS, and FinOps controls.

provider "aws" {
  region = "us-east-1"
}

# --- KMS Key with rotation enabled ---

resource "aws_kms_key" "cde_key" {
  description         = "CMK for CDE data encryption"
  enable_key_rotation = true

  tags = {
    Environment        = "production"
    Application        = "payments"
    Owner              = "platform-engineering"
    CostCenter         = "CC-4200"
    DataClassification = "Cardholder"
    ComplianceScope    = "PCI"
  }
}

# --- S3 Bucket: Encrypted, access-blocked, logged, lifecycled ---

resource "aws_s3_bucket" "cardholder_data" {
  bucket = "acme-cardholder-data-prod"

  tags = {
    Environment        = "production"
    Application        = "payments"
    Owner              = "platform-engineering"
    CostCenter         = "CC-4200"
    DataClassification = "Cardholder"
    ComplianceScope    = "PCI"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cardholder_data" {
  bucket = aws_s3_bucket.cardholder_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.cde_key.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cardholder_data" {
  bucket = aws_s3_bucket.cardholder_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "cardholder_data" {
  bucket        = aws_s3_bucket.cardholder_data.id
  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "cardholder-data/"
}

resource "aws_s3_bucket_lifecycle_configuration" "cardholder_data" {
  bucket = aws_s3_bucket.cardholder_data.id

  rule {
    id     = "archive-old-data"
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

# --- RDS: Encrypted, private, no hardcoded creds, SSL enforced ---

resource "aws_db_instance" "payments_db" {
  identifier           = "payments-primary"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.m6i.xlarge"
  allocated_storage    = 100
  storage_encrypted    = true
  kms_key_id           = aws_kms_key.cde_key.arn
  publicly_accessible  = false
  multi_az             = true
  subnet_group_name    = aws_db_subnet_group.cde.name
  username             = "admin"
  password             = data.aws_secretsmanager_secret_version.db_password.secret_string
  skip_final_snapshot  = false
  parameter_group_name = aws_db_parameter_group.ssl_enforced.name

  enabled_cloudwatch_logs_exports = ["audit", "general"]

  tags = {
    Environment        = "production"
    Application        = "payments"
    Owner              = "platform-engineering"
    CostCenter         = "CC-4200"
    DataClassification = "Cardholder"
    ComplianceScope    = "PCI"
  }
}

resource "aws_db_parameter_group" "ssl_enforced" {
  family = "mysql8.0"
  name   = "payments-ssl-enforced"

  parameter {
    name  = "require_secure_transport"
    value = "1"
  }
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "payments-db-master-password"
}

# --- IAM: Scoped role with least-privilege policy ---

resource "aws_iam_role" "app_role" {
  name = "payments-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })

  tags = {
    Environment     = "production"
    Application     = "payments"
    Owner           = "platform-engineering"
    CostCenter      = "CC-4200"
    ComplianceScope = "PCI"
  }
}

resource "aws_iam_role_policy" "app_policy" {
  name = "payments-app-policy"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.cardholder_data.arn,
          "${aws_s3_bucket.cardholder_data.arn}/*"
        ]
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Effect   = "Allow"
        Resource = aws_kms_key.cde_key.arn
      }
    ]
  })
}

# --- Security Group: Scoped ingress, no SSH from internet ---

resource "aws_security_group" "app_sg" {
  name        = "payments-app-sg"
  description = "Security group for payments application"
  vpc_id      = aws_vpc.cde.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  tags = {
    Environment     = "production"
    Application     = "payments"
    Owner           = "platform-engineering"
    CostCenter      = "CC-4200"
    ComplianceScope = "PCI"
  }
}

# --- EC2: Current-gen, explicit subnet, gp3 ---

resource "aws_instance" "app_server" {
  ami                    = "ami-0abcdef1234567890"
  instance_type          = "m6i.large"
  subnet_id              = aws_subnet.cde_private_a.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  monitoring             = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
    encrypted   = true
    kms_key_id  = aws_kms_key.cde_key.arn
  }

  tags = {
    Environment     = "production"
    Application     = "payments"
    Owner           = "platform-engineering"
    CostCenter      = "CC-4200"
    ComplianceScope = "PCI"
  }
}

# --- ALB Listener: HTTPS with TLS 1.3, HTTP redirects ---

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.app.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# --- CloudTrail: Multi-region, validated, encrypted ---

resource "aws_cloudtrail" "cde_trail" {
  name                          = "cde-audit-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.cde_key.arn
  include_global_service_events = true

  tags = {
    Environment     = "production"
    Application     = "security"
    Owner           = "platform-engineering"
    CostCenter      = "CC-4200"
    ComplianceScope = "PCI"
  }
}

# --- VPC Flow Logs ---

resource "aws_flow_log" "cde_vpc" {
  vpc_id               = aws_vpc.cde.id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn
  iam_role_arn         = aws_iam_role.flow_log_role.arn

  tags = {
    Environment     = "production"
    Application     = "security"
    Owner           = "platform-engineering"
    CostCenter      = "CC-4200"
    ComplianceScope = "PCI"
  }
}

# --- CloudWatch Log Group: Explicit retention ---

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/app/payments"
  retention_in_days = 90

  tags = {
    Environment     = "production"
    Application     = "payments"
    Owner           = "platform-engineering"
    CostCenter      = "CC-4200"
    ComplianceScope = "PCI"
  }
}
