## Payment Service Infrastructure - ECS Fargate
## Compliance: PCI DSS overlay applied

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

# --- KMS Key for CDE Encryption ---

resource "aws_kms_key" "service" {
  description         = "CMK for ${var.service_name} data encryption"
  enable_key_rotation = true

  tags = local.tags
}

# --- ECR Repository ---

resource "aws_ecr_repository" "service" {
  name                 = var.service_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.service.arn
  }

  tags = local.tags
}

# --- ECS Task Definition ---

resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = "${aws_ecr_repository.service.repository_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "ENVIRONMENT", value = var.environment },
        { name = "LOG_LEVEL", value = var.log_level },
        { name = "PORT", value = "8080" },
        { name = "AWS_REGION", value = var.aws_region },
      ]

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = aws_secretsmanager_secret.db_url.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.service.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = var.service_name
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "python -c \"import urllib.request; urllib.request.urlopen('http://localhost:8080/health')\" || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
    }
  ])

  tags = local.tags
}

# --- ECS Service ---

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.service.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service.arn
    container_name   = var.service_name
    container_port   = 8080
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  tags = local.tags
}

# --- ALB Target Group ---

resource "aws_lb_target_group" "service" {
  name        = var.service_name
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/ready"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = local.tags
}

# --- Security Group ---

resource "aws_security_group" "service" {
  name        = "${var.service_name}-ecs"
  description = "Security group for ${var.service_name} ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
    description     = "Allow traffic from ALB only"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow HTTPS to internal services"
  }

  tags = local.tags
}

# --- Auto Scaling ---

resource "aws_appautoscaling_target" "service" {
  max_capacity       = var.max_count
  min_capacity       = var.desired_count
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service.resource_id
  scalable_dimension = aws_appautoscaling_target.service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.service.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

# --- Secrets Manager ---

resource "aws_secretsmanager_secret" "db_url" {
  name       = "${var.service_name}/database-url"
  kms_key_id = aws_kms_key.service.arn

  tags = local.tags
}

# --- CloudWatch Log Group ---

resource "aws_cloudwatch_log_group" "service" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.service.arn

  tags = local.tags
}

# --- IAM Roles ---

resource "aws_iam_role" "ecs_execution" {
  name = "${var.service_name}-ecs-execution"

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

  tags = local.tags
}

resource "aws_iam_role_policy" "ecs_execution" {
  name = "${var.service_name}-ecs-execution"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
        ]
        Effect   = "Allow"
        Resource = aws_ecr_repository.service.arn
      },
      {
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.service.arn}:*"
      },
      {
        Action   = ["secretsmanager:GetSecretValue"]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.db_url.arn
      },
      {
        Action   = ["kms:Decrypt"]
        Effect   = "Allow"
        Resource = aws_kms_key.service.arn
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.service_name}-ecs-task"

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

  tags = local.tags
}

# --- Tags ---

locals {
  tags = {
    Service         = var.service_name
    Environment     = var.environment
    Owner           = var.owner
    CostCenter      = var.cost_center
    ComplianceScope = var.compliance_scope
    ManagedBy       = "terraform"
  }
}
