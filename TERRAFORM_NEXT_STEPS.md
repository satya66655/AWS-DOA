# Terraform DevOps Agent Demo - Next Steps

## ✅ WHAT'S BEEN CREATED

I've successfully created the foundational Terraform files for your AWS DevOps Agent demo:

### ✅ Complete Files (Ready to Use)
```
✅ main.tf         - AWS provider + backend config
✅ variables.tf    - All input variables with defaults
✅ outputs.tf      - Complete output values  
✅ iam.tf          - IAM roles and policies
✅ README.md       - Setup and usage guide
```

### 📝 Files You Need to Create (Template Structure Provided)

I'll provide the complete code for these files below. You need to create them:

```
⏳ security.tf      - Security groups (ALB + containers)
⏳ ecs.tf           - ECS cluster, service, task definition
⏳ alb.tf           - ALB with 2 target groups
⏳ dynamodb.tf      - 3 DynamoDB tables
⏳ cloudwatch.tf    - 8 alarms + dashboard
⏳ terraform.tfvars - Configuration values
⏳ .gitignore       - Git ignore patterns
```

---

## 📝 CREATE THESE FILES NOW

### **1. Create security.tf**

```hcl
# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = var.alb_port
    to_port     = var.alb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# ECS Task Security Group
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = var.ecs_container_port
    to_port         = var.ecs_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-tasks-sg"
  }
}

# Data source for default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source for default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "ecs_tasks_security_group_id" {
  value = aws_security_group.ecs_tasks.id
}
```

### **2. Create ecs.tf**

```hcl
# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-api"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-logs"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

# ECS Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = var.project_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container"
      image     = "886436941748.dkr.ecr.${var.aws_region}.amazonaws.com/student-enrollment-api:${var.ecr_image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = var.ecs_container_port
          hostPort      = var.ecs_container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "DYNAMODB_ENROLLMENTS_TABLE"
          value = "student-enrollment-enrollments"
        },
        {
          name  = "DYNAMODB_STUDENTS_TABLE"
          value = "student-enrollment-students"
        },
        {
          name  = "DYNAMODB_COURSES_TABLE"
          value = "student-enrollment-courses"
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.ecs_container_port}/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-task"
  }
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-api-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = data.aws_subnets.default.ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.wrong.arn
    container_name   = "${var.project_name}-container"
    container_port   = var.ecs_container_port
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy.ecs_task_dynamodb_policy
  ]

  tags = {
    Name = "${var.project_name}-service"
  }
}

# Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = var.ecs_desired_count
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${var.project_name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "ecs_service_id" {
  value = aws_ecs_service.main.id
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.main.arn
}
```

### **3. Create alb.tf**

```hcl
# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Target Group 1: WRONG (Port 80) - causes failure
resource "aws_lb_target_group" "wrong" {
  name        = "${var.project_name}-wrong-tg"
  port        = var.wrong_target_group_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-wrong-tg"
  }
}

# Target Group 2: CORRECT (Port 5000) - to use after fix
resource "aws_lb_target_group" "correct" {
  name        = "${var.project_name}-correct-tg"
  port        = var.correct_target_group_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-correct-tg"
  }
}

# ALB Listener (routes to WRONG target group initially)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.alb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wrong.arn
  }
}

output "alb_id" {
  value = aws_lb.main.id
}

output "wrong_target_group_arn" {
  value = aws_lb_target_group.wrong.arn
}

output "correct_target_group_arn" {
  value = aws_lb_target_group.correct.arn
}
```

### **4. Create dynamodb.tf**

```hcl
# Students Table
resource "aws_dynamodb_table" "students" {
  name           = "student-enrollment-students"
  billing_mode   = var.dynamodb_billing_mode
  hash_key       = "student_id"

  attribute {
    name = "student_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = var.enable_ttl
  }

  tags = {
    Name = "student-enrollment-students"
  }
}

# Courses Table
resource "aws_dynamodb_table" "courses" {
  name           = "student-enrollment-courses"
  billing_mode   = var.dynamodb_billing_mode
  hash_key       = "course_id"

  attribute {
    name = "course_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = var.enable_ttl
  }

  tags = {
    Name = "student-enrollment-courses"
  }
}

# Enrollments Table with GSI
resource "aws_dynamodb_table" "enrollments" {
  name           = "student-enrollment-enrollments"
  billing_mode   = var.dynamodb_billing_mode
  hash_key       = "enrollment_id"

  attribute {
    name = "enrollment_id"
    type = "S"
  }

  attribute {
    name = "student_id"
    type = "S"
  }

  global_secondary_index {
    name            = "student-id-index"
    hash_key        = "student_id"
    projection_type = "ALL"

    # For PROVISIONED billing mode (if needed for incident testing)
    # provisioned_throughput {
    #   read_capacity_units  = 10
    #   write_capacity_units = 10
    # }
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = var.enable_ttl
  }

  tags = {
    Name = "student-enrollment-enrollments"
  }
}

output "students_table_arn" {
  value = aws_dynamodb_table.students.arn
}

output "courses_table_arn" {
  value = aws_dynamodb_table.courses.arn
}

output "enrollments_table_arn" {
  value = aws_dynamodb_table.enrollments.arn
}
```

### **5. Create cloudwatch.tf** (Next message due to size)

Would you like me to continue with cloudwatch.tf and the remaining files?

---

## 🚀 TO GET EVERYTHING WORKING:

1. **Create the 5 .tf files above** in your terraform directory
2. **Create terraform.tfvars**:
```hcl
aws_account_id = "886436941748"
demo_date      = "19-05-2026"
```

3. **Run**:
```bash
terraform init
terraform plan
terraform apply
```

---

**Ready to continue with cloudwatch.tf and remaining files?**
