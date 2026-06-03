# ════════════════════════════════════════════════════════════════════════════
# File: codepipeline.tf
# Purpose: Create CodePipeline for automated ECS deployment
# Integration: Add to your existing AWS-DOA Terraform directory
# Naming: Follows existing ${var.project_name} convention
# ════════════════════════════════════════════════════════════════════════════

# ════════════════════════════════════════════════════════════════════════════
# S3 Bucket for Pipeline Artifacts
# ════════════════════════════════════════════════════════════════════════════

resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "${var.project_name}-codepipeline-artifacts-${var.aws_account_id}"

  tags = {
    Name        = "${var.project_name}-pipeline-artifacts"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ════════════════════════════════════════════════════════════════════════════
# IAM Role for CodePipeline
# ════════════════════════════════════════════════════════════════════════════

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.project_name}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-codepipeline-role"
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.project_name}-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          aws_s3_bucket.codepipeline_artifacts.arn,
          "${aws_s3_bucket.codepipeline_artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = aws_codebuild_project.update_task_definition.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTask",
          "ecs:ListTasks"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = [
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# ════════════════════════════════════════════════════════════════════════════
# IAM Role for CodeBuild
# ════════════════════════════════════════════════════════════════════════════

resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-codebuild-role"
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.project_name}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/codebuild/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.codepipeline_artifacts.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ]
        Resource = "arn:aws:ecs:${var.aws_region}:${var.aws_account_id}:task-definition/*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:DescribeImages",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories"
        ]
        Resource = "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${var.ecr_repository_name}"
      }
    ]
  })
}

# ════════════════════════════════════════════════════════════════════════════
# CodeBuild Project - Updates Task Definition
# ════════════════════════════════════════════════════════════════════════════

resource "aws_codebuild_project" "update_task_definition" {
  name           = "${var.project_name}-update-task-definition"
  service_role   = aws_iam_role.codebuild_role.arn
  build_timeout  = 10
  queued_timeout = 480

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variables = [
      {
        name  = "AWS_ACCOUNT_ID"
        value = var.aws_account_id
        type  = "PLAINTEXT"
      },
      {
        name  = "AWS_DEFAULT_REGION"
        value = var.aws_region
        type  = "PLAINTEXT"
      },
      {
        name  = "ECR_REPOSITORY_NAME"
        value = var.ecr_repository_name
        type  = "PLAINTEXT"
      },
      {
        name  = "TASK_DEFINITION_FAMILY"
        value = var.project_name
        type  = "PLAINTEXT"
      },
      {
        name  = "ECS_CLUSTER_NAME"
        value = aws_ecs_cluster.main.name
        type  = "PLAINTEXT"
      },
      {
        name  = "ECS_SERVICE_NAME"
        value = aws_ecs_service.main.name
        type  = "PLAINTEXT"
      }
    ]
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<-EOT
      version: 0.2
      phases:
        install:
          runtime-versions:
            python: 3.11
          commands:
            - pip install boto3 --quiet
        pre_build:
          commands:
            - |
              echo "Getting the latest image URI from ECR..."
              IMAGE_URI=$(aws ecr describe-images \
                --repository-name $ECR_REPOSITORY_NAME \
                --region $AWS_DEFAULT_REGION \
                --query 'imageDetails[0].imageUri' \
                --output text)
              echo "Image URI: $IMAGE_URI"
              echo "IMAGE_URI=$IMAGE_URI" >> /tmp/image.env
        build:
          commands:
            - |
              source /tmp/image.env
              echo "Registering new task definition with image: $IMAGE_URI"
              
              # Get current task definition
              TASK_DEF=$(aws ecs describe-task-definition \
                --task-definition $TASK_DEFINITION_FAMILY \
                --region $AWS_DEFAULT_REGION \
                --query 'taskDefinition' \
                --output json)
              
              # Update image in container definition
              NEW_TASK_DEF=$(echo "$TASK_DEF" | jq \
                --arg IMAGE "$IMAGE_URI" \
                '.containerDefinitions[0].image = $IMAGE | 
                 del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)')
              
              # Register new task definition
              aws ecs register-task-definition \
                --cli-input-json "$(echo "$NEW_TASK_DEF")" \
                --region $AWS_DEFAULT_REGION
      artifacts:
        files:
          - /tmp/image.env
        name: BuildArtifact
    EOT
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.project_name}-pipeline"
      stream_name = "build"
    }
  }

  tags = {
    Name = "${var.project_name}-codebuild"
  }
}

# ════════════════════════════════════════════════════════════════════════════
# IAM Role for EventBridge
# ════════════════════════════════════════════════════════════════════════════

resource "aws_iam_role" "eventbridge_role" {
  count = var.enable_ecr_auto_trigger ? 1 : 0
  name  = "${var.project_name}-eventbridge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-eventbridge-role"
  }
}

resource "aws_iam_role_policy" "eventbridge_policy" {
  count = var.enable_ecr_auto_trigger ? 1 : 0
  name  = "${var.project_name}-eventbridge-policy"
  role  = aws_iam_role.eventbridge_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codepipeline:StartPipelineExecution"
        ]
        Resource = aws_codepipeline.main.arn
      }
    ]
  })
}

# ════════════════════════════════════════════════════════════════════════════
# EventBridge Rule - Auto-trigger on ECR Image Push
# ════════════════════════════════════════════════════════════════════════════

resource "aws_cloudwatch_event_rule" "ecr_push" {
  count           = var.enable_ecr_auto_trigger ? 1 : 0
  name            = "${var.project_name}-ecr-image-push"
  description     = "Trigger CodePipeline when new image is pushed to ECR"
  is_enabled      = true

  event_pattern = jsonencode({
    source      = ["aws.ecr"]
    detail-type = ["ECR Image Action"]
    detail = {
      action = ["PUSH"]
      result = ["SUCCESS"]
    }
  })

  tags = {
    Name = "${var.project_name}-ecr-push-rule"
  }
}

resource "aws_cloudwatch_event_target" "codepipeline" {
  count      = var.enable_ecr_auto_trigger ? 1 : 0
  rule       = aws_cloudwatch_event_rule.ecr_push[0].name
  target_id  = "CodePipeline"
  arn        = aws_codepipeline.main.arn
  role_arn   = aws_iam_role.eventbridge_role[0].arn

  depends_on = [aws_iam_role_policy.eventbridge_policy]
}

# ════════════════════════════════════════════════════════════════════════════
# CodePipeline
# ════════════════════════════════════════════════════════════════════════════

resource "aws_codepipeline" "main" {
  name       = "${var.project_name}-pipeline"
  role_arn   = aws_iam_role.codepipeline_role.arn
  depends_on = [aws_iam_role_policy.codepipeline_policy]

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
    type     = "S3"
  }

  # Stage 1: Source from GitHub
  stage {
    name = "Source"

    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "GitHub"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        Owner  = var.github_owner
        Repo   = var.github_repo
        Branch = var.github_branch
        OAuthToken = var.github_token
      }
    }
  }

  # Stage 2: Update Task Definition
  stage {
    name = "UpdateTaskDefinition"

    action {
      name            = "UpdateECSTaskDef"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]

      configuration = {
        ProjectName = aws_codebuild_project.update_task_definition.name
      }
    }
  }

  # Stage 3: Deploy to ECS
  stage {
    name = "DeployToECS"

    action {
      name            = "DeployAction"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["SourceOutput"]

      configuration = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.main.name
        FileName    = "imagedefinitions.json"
      }
    }
  }

  tags = {
    Name        = "${var.project_name}-pipeline"
    Environment = var.environment
  }
}
