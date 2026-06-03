variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "project_name" {
  description = "Project name - used for resource naming"
  type        = string
  default     = "student-enrollment"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "demo_date" {
  description = "Demo date in dd-mm-yyyy format (auto-generated if not provided)"
  type        = string
  default     = ""
}

# ECR Configuration
variable "ecr_image_tag" {
  description = "ECR image tag to use (failing - built on Mac, ARM64)"
  type        = string
  default     = "latest"
}

variable "ecr_correct_image_tag" {
  description = "ECR correct image tag (working - built on Linux, x86_64)"
  type        = string
  default     = "amdx86"
}

# ECS Configuration
variable "ecs_task_cpu" {
  description = "ECS task CPU units"
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "ECS task memory in MB"
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "ecs_container_port" {
  description = "Port the container application listens on"
  type        = number
  default     = 5000
}

# ALB Configuration
variable "alb_port" {
  description = "ALB listening port"
  type        = number
  default     = 80
}

variable "wrong_target_group_port" {
  description = "WRONG target group port (port 80 - app on 5000, mismatch)"
  type        = number
  default     = 80
}

variable "correct_target_group_port" {
  description = "CORRECT target group port (port 5000 - where app listens)"
  type        = number
  default     = 5000
}

# DynamoDB Configuration
variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "enable_point_in_time_recovery" {
  description = "Enable DynamoDB point-in-time recovery"
  type        = bool
  default     = true
}

variable "enable_ttl" {
  description = "Enable DynamoDB TTL"
  type        = bool
  default     = false
}

# Tags Configuration
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
# GitHub Configuration for CodePipeline
variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "satya66655"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "AWS-DOA"
}

variable "github_branch" {
  description = "GitHub branch to deploy from"
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "GitHub personal access token for CodePipeline authentication"
  type        = string
  sensitive   = true
  # Pass via: export TF_VAR_github_token="ghp_xxxxx"
  # Or via terraform apply -var="github_token=ghp_xxxxx"
}

# ECR Configuration for CodePipeline
variable "ecr_repository_name" {
  description = "ECR repository name for Docker images"
  type        = string
  default     = "student-enrollment-api"
}

# CodePipeline Feature Flags
variable "enable_ecr_auto_trigger" {
  description = "Auto-trigger CodePipeline when new image is pushed to ECR"
  type        = bool
  default     = true
}

variable "enable_codepipeline" {
  description = "Enable CodePipeline deployment automation"
  type        = bool
  default     = true
}

