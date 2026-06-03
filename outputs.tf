# ════════════════════════════════════════════════════════════════════════════
# ADD THESE OUTPUTS TO YOUR EXISTING outputs.tf
# ════════════════════════════════════════════════════════════════════════════

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

