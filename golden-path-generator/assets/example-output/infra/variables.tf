variable "service_name" {
  description = "Name of the service"
  type        = string
  default     = "payment-service"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the service"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB"
  type        = string
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Memory (MiB) for the ECS task"
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "max_count" {
  description = "Maximum number of ECS tasks for auto scaling"
  type        = number
  default     = 10
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "INFO"
}

variable "owner" {
  description = "Team or individual responsible for this service"
  type        = string
  default     = "platform-engineering"
}

variable "cost_center" {
  description = "Cost center for billing allocation"
  type        = string
  default     = "CC-4200"
}

variable "compliance_scope" {
  description = "Compliance framework scope"
  type        = string
  default     = "PCI"
}
