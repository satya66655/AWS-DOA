output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "application_url" {
  description = "Full application URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.main.name
}

output "ecs_service_arn" {
  description = "ECS service ARN"
  value       = aws_ecs_service.main.arn
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_name" {
  description = "ALB name"
  value       = aws_lb.main.name
}

output "target_group_wrong" {
  description = "WRONG target group (port 80) - currently used by service"
  value       = {
    arn  = aws_lb_target_group.wrong.arn
    name = aws_lb_target_group.wrong.name
    port = aws_lb_target_group.wrong.port
  }
}

output "target_group_correct" {
  description = "CORRECT target group (port 5000) - to use after fix"
  value       = {
    arn  = aws_lb_target_group.correct.arn
    name = aws_lb_target_group.correct.name
    port = aws_lb_target_group.correct.port
  }
}

output "dynamodb_tables" {
  description = "DynamoDB table names and ARNs"
  value       = {
    students = {
      name = aws_dynamodb_table.students.name
      arn  = aws_dynamodb_table.students.arn
    }
    courses = {
      name = aws_dynamodb_table.courses.name
      arn  = aws_dynamodb_table.courses.arn
    }
    enrollments = {
      name = aws_dynamodb_table.enrollments.name
      arn  = aws_dynamodb_table.enrollments.arn
    }
  }
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.ecs.arn
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "cloudwatch_alarms" {
  description = "CloudWatch alarms created"
  value       = {
    ecs_cpu           = aws_cloudwatch_metric_alarm.ecs_cpu.alarm_name
    ecs_memory        = aws_cloudwatch_metric_alarm.ecs_memory.alarm_name
    ecs_task_count    = aws_cloudwatch_metric_alarm.ecs_task_count.alarm_name
    alb_5xx_errors    = aws_cloudwatch_metric_alarm.alb_5xx.alarm_name
    alb_latency       = aws_cloudwatch_metric_alarm.alb_latency.alarm_name
    alb_unhealthy     = aws_cloudwatch_metric_alarm.alb_unhealthy.alarm_name
    dynamodb_errors   = aws_cloudwatch_metric_alarm.dynamodb_errors.alarm_name
    dynamodb_latency  = aws_cloudwatch_metric_alarm.dynamodb_latency.alarm_name
  }
}

output "ecr_image_current" {
  description = "Current ECR image (failing - ARM64 from Mac)"
  value       = "886436941748.dkr.ecr.${var.aws_region}.amazonaws.com/student-enrollment-api:${var.ecr_image_tag}"
}

output "ecr_image_correct" {
  description = "Correct ECR image (working - x86_64 from Linux)"
  value       = "886436941748.dkr.ecr.${var.aws_region}.amazonaws.com/student-enrollment-api:${var.ecr_correct_image_tag}"
}

output "demo_instructions" {
  description = "Demo flow instructions"
  value       = <<-EOT
    AWS DevOps Agent Demo - Infrastructure Ready!
    
    PHASE 1 - Infrastructure with Intentional Failures:
    ✓ ECS Service using WRONG target group (port 80)
    ✓ Task Definition using FAILING image (latest - ARM64)
    ✓ Tasks will fail to connect to ALB
    
    PHASE 2 - Investigation:
    1. Open AWS DevOps Agent
    2. Ask: "Why are my ECS tasks failing?"
    3. Expected findings:
       - Image architecture mismatch (ARM64 vs x86_64)
       - Port mismatch (ALB:80 → Container:5000)
       - Wrong target group configured
    
    PHASE 3 - Manual Remediation:
    1. Update task definition image: latest → amdx86
    2. Update service target group: wrong → correct
    3. Redeploy and verify in CloudWatch
    
    PHASE 4 - Application Operations:
    1. Access application: ${aws_lb.main.dns_name}
    2. Create students, courses, enrollments
    3. View in DynamoDB console
    
    PHASE 5 - Performance Incident (Optional):
    1. Change DynamoDB billing: PAY_PER_REQUEST → PROVISIONED
    2. Set capacity: 10 RCU/WCU
    3. Generate load and trigger DevOps Agent
  EOT
}

output "demo_date_tag" {
  description = "Demo date used for tagging"
  value       = local.demo_date
}
