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

output "ecs_service_id" {
  description = "ECS service ARN"
  value       = aws_ecs_service.main.id
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
output "codepipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.main.name
}

output "codepipeline_arn" {
  description = "CodePipeline ARN"
  value       = aws_codepipeline.main.arn
}

output "codepipeline_console_url" {
  description = "AWS Console URL for the CodePipeline"
  value       = "https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.main.name}/view"
}

output "codebuild_project_name" {
  description = "CodeBuild project name for task definition updates"
  value       = aws_codebuild_project.update_task_definition.name
}

output "codebuild_project_arn" {
  description = "CodeBuild project ARN"
  value       = aws_codebuild_project.update_task_definition.arn
}

output "codepipeline_artifacts_bucket" {
  description = "S3 bucket for CodePipeline artifacts"
  value       = aws_s3_bucket.codepipeline_artifacts.bucket
}

output "codepipeline_artifacts_bucket_arn" {
  description = "S3 bucket ARN for CodePipeline artifacts"
  value       = aws_s3_bucket.codepipeline_artifacts.arn
}

output "eventbridge_rule_name" {
  description = "EventBridge rule name for ECR push trigger"
  value       = var.enable_ecr_auto_trigger ? aws_cloudwatch_event_rule.ecr_push[0].name : "N/A - Auto-trigger disabled"
}

output "eventbridge_rule_arn" {
  description = "EventBridge rule ARN"
  value       = var.enable_ecr_auto_trigger ? aws_cloudwatch_event_rule.ecr_push[0].arn : "N/A - Auto-trigger disabled"
}

output "codepipeline_setup_complete" {
  description = "CodePipeline setup summary"
  value       = <<-EOT
    
    ════════════════════════════════════════════════════════════════════════════
    ✓ CodePipeline Setup Complete!
    ════════════════════════════════════════════════════════════════════════════
    
    Pipeline Configuration:
    • Name: ${aws_codepipeline.main.name}
    • Console: https://console.aws.amazon.com/codesuite/codepipeline/
    • Auto-Trigger: ${var.enable_ecr_auto_trigger ? "✓ Enabled (on ECR image push)" : "✗ Disabled (manual trigger)"}
    
    Key Resources:
    • S3 Artifacts Bucket: ${aws_s3_bucket.codepipeline_artifacts.bucket}
    • CodeBuild Project: ${aws_codebuild_project.update_task_definition.name}
    • EventBridge Rule: ${var.enable_ecr_auto_trigger ? aws_cloudwatch_event_rule.ecr_push[0].name : "N/A"}
    
    Pipeline Stages:
    1. Source → GitHub (${var.github_owner}/${var.github_repo}:${var.github_branch})
    2. Build → CodeBuild (Updates ECS Task Definition)
    3. Deploy → ECS Service (${aws_ecs_service.main.name} on cluster ${aws_ecs_cluster.main.name})
    
    GitHub Integration:
    • Owner: ${var.github_owner}
    • Repository: ${var.github_repo}
    • Branch: ${var.github_branch}
    • Token: ✓ Configured (stored securely)
    
    ECR Integration:
    • Repository: ${var.ecr_repository_name}
    • Region: ${var.aws_region}
    • Account: ${var.aws_account_id}
    
    Next Steps for Demo:
    1. ✓ Infrastructure ready (ECS, ALB, DynamoDB)
    2. ✓ CodePipeline ready (auto-triggers on ECR push)
    3. Developer builds image on Mac and pushes to ECR
    4. CodePipeline auto-triggers → Updates task definition → Redeploys
    5. Use AWS DevOps Agent to investigate failures
    
    Test the Pipeline:
    → Build and push image to ECR: 
      docker build -t ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository_name}:latest .
      docker push ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository_name}:latest
    
    → Watch CodePipeline auto-trigger:
      aws codepipeline get-pipeline-state --name ${aws_codepipeline.main.name}
    
    ════════════════════════════════════════════════════════════════════════════
  EOT
}

