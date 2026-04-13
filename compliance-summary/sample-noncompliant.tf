# sample-noncompliant.tf
# Deliberately non-compliant Terraform configuration for testing the IaC Compliance Reviewer.
# This file contains multiple violations across security, PCI, and FinOps controls.

provider "aws" {
  region = "us-east-1"
}

# --- S3 Bucket: No encryption, no public access block, no logging, no lifecycle ---

resource "aws_s3_bucket" "cardholder_data" {
  bucket = "acme-cardholder-data-prod"

  tags = {
    Name = "cardholder-data"
  }
}

# --- RDS: Publicly accessible, unencrypted, hardcoded password, no SSL enforcement ---

resource "aws_db_instance" "payments_db" {
  identifier           = "payments-primary"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.m4.xlarge"
  allocated_storage    = 100
  storage_encrypted    = false
  publicly_accessible  = true
  multi_az             = true
  username             = "admin"
  password             = "SuperSecret123!"
  skip_final_snapshot  = true

  tags = {
    Name = "payments-db"
  }
}

# --- IAM: Wildcard actions and resources ---

resource "aws_iam_role" "app_role" {
  name = "payments-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { AWS = "*" }
      }
    ]
  })
}

resource "aws_iam_role_policy" "app_policy" {
  name = "payments-app-policy"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "*"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# --- Security Group: SSH open to the world ---

resource "aws_security_group" "app_sg" {
  name        = "payments-app-sg"
  description = "Security group for payments application"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- EC2: Previous-gen instance, no subnet specified ---

resource "aws_instance" "app_server" {
  ami                    = "ami-0abcdef1234567890"
  instance_type          = "m4.large"
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  monitoring             = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }
}

# --- ALB Listener: HTTP without redirect ---

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# --- CloudWatch Log Group: No retention set ---

resource "aws_cloudwatch_log_group" "app_logs" {
  name = "/app/payments"
}

# --- EBS Volume: Unencrypted, gp2 ---

resource "aws_ebs_volume" "data_volume" {
  availability_zone = "us-east-1a"
  size              = 500
  type              = "gp2"

  tags = {
    Name = "payments-data"
  }
}
