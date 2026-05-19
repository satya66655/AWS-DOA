# Terraform AWS DevOps Agent Demo Environment

Complete, repeatable Terraform infrastructure for demonstrating AWS DevOps Agent capabilities.

## 📋 Overview

This Terraform package creates a complete AWS environment with:
- **ECS Cluster** with intentional configuration failures
- **ALB** with 2 target groups (1 wrong, 1 correct)
- **DynamoDB** tables (students, courses, enrollments)
- **CloudWatch** monitoring (8 alarms + dashboard)
- **IAM roles** with proper permissions

## 🎯 Demo Scenarios

### Scenario 1: Image Architecture Mismatch
- **Issue**: Task Definition uses "latest" tag (ARM64 - Mac built)
- **Result**: ECS tasks fail to start
- **Fix**: Update to "amdx86" tag (x86_64 - Linux built)

### Scenario 2: Port Mismatch
- **Issue**: ALB routed to port 80, but app listens on 5000
- **Result**: Connection refused errors
- **Fix**: Switch to correct target group (port 5000)

### Scenario 3: Wrong Target Group
- **Issue**: Service configured with port 80 target group
- **Result**: Tasks never become healthy
- **Fix**: Switch to port 5000 target group

## 🚀 Quick Start

### Prerequisites
```bash
# Install Terraform (>=1.0)
terraform version

# AWS credentials configured
aws sts get-caller-identity

# Your account ID
export AWS_ACCOUNT_ID=886436941748
```

### Deployment

```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan -var="aws_account_id=$AWS_ACCOUNT_ID"

# Deploy infrastructure
terraform apply -var="aws_account_id=$AWS_ACCOUNT_ID"

# With custom date tag
terraform apply \
  -var="aws_account_id=$AWS_ACCOUNT_ID" \
  -var="demo_date=19-05-2026"
```

### Outputs

After deployment, view key information:
```bash
terraform output alb_dns_name
terraform output cloudwatch_dashboard_url
terraform output demo_instructions
```

## 📁 File Structure

```
├── main.tf              # Provider and core config
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── iam.tf              # IAM roles and policies
├── security.tf         # Security groups
├── ecs.tf              # ECS cluster, service, task definition
├── alb.tf              # ALB with 2 target groups
├── dynamodb.tf         # DynamoDB tables
├── cloudwatch.tf       # CloudWatch alarms and dashboard
├── terraform.tfvars    # Example variable values
├── README.md           # This file
├── DEMO_GUIDE.md       # Step-by-step demo guide
├── .gitignore          # Git ignore patterns
├── setup.sh            # One-command setup script
└── destroy.sh          # Cleanup script
```

## 📊 Architecture

```
┌─────────────────────────────────────────┐
│           Internet (Port 80)            │
└────────────────┬────────────────────────┘
                 │
         ┌───────▼────────┐
         │      ALB       │
         │  (Port 80)     │
         └───────┬────────┘
                 │
         ┌───────┴──────────────────┐
         │                          │
   ┌─────▼──────┐          ┌────────▼─────┐
   │  TG (80)   │          │  TG (5000)   │
   │  WRONG     │          │  CORRECT     │
   │  X Used    │          │  ✓ Unused    │
   └─────┬──────┘          └────────┬─────┘
         │                          │
   ┌─────▼────────────────┐         │
   │  ECS Service         │         │ After fix
   │  (Port 80 target)    │◄────────┘
   │  ✗ Tasks fail        │
   └─────┬────────────────┘
         │
   ┌─────▼────────────────┐
   │  ECS Tasks           │
   │  Container: 5000     │
   │  ✗ Connection refused│
   └─────────────────────┘
         │
   ┌─────▼────────────────────────┐
   │    Application Pod           │
   │   (student-enrollment-api)   │
   │   Port: 5000                 │
   └─────┬───────────────┬────────┘
         │               │
    ┌────▼───┐      ┌────▼───┐
    │DynamoDB│      │CloudWatch
    │ Tables │      │  Logs
    └────────┘      └────────┘
```

## 🎬 Demo Flow

### Step 1: Initial State (Intentional Failures)
- Application URL: Inaccessible
- ECS Tasks: Failed
- Target Group: Wrong (port 80)
- Image Tag: latest (ARM64 - failing)

### Step 2: Investigation with DevOps Agent
1. Open AWS DevOps Agent
2. Ask: "Why are my ECS tasks failing?"
3. DevOps Agent identifies:
   - Image architecture mismatch
   - Port/target group mismatch
   - CloudWatch log analysis

### Step 3: Remediation
1. Update task definition: latest → amdx86
2. Update service: wrong target group → correct target group
3. Redeploy service
4. Verify in CloudWatch

### Step 4: Application Testing
1. Access ALB URL
2. Create students
3. Create courses
4. Create enrollments
5. Verify in DynamoDB

### Step 5: Performance Incident (Optional)
1. Change DynamoDB to PROVISIONED with 10 RCU/WCU
2. Generate load
3. Trigger DevOps Agent for throttling investigation

## 📋 Variables

### Required
- `aws_account_id` - Your AWS account ID

### Optional (with defaults)
- `aws_region` - Default: us-east-1
- `project_name` - Default: student-enrollment
- `environment` - Default: demo
- `demo_date` - Default: auto-generated (dd-mm-yyyy)
- `ecr_image_tag` - Default: latest (failing image)
- `ecr_correct_image_tag` - Default: amdx86 (working image)
- `ecs_task_cpu` - Default: 256
- `ecs_task_memory` - Default: 512
- `ecs_desired_count` - Default: 2

## 🏷️ Tagging

All resources are tagged with:
- `Environment`: demo
- `Project`: student-enrollment
- `DemoDate`: dd-mm-yyyy
- `CreatedBy`: terraform
- `ManagedBy`: terraform

## 📊 Monitoring

### CloudWatch Alarms (8 total)
1. ECS CPU High
2. ECS Memory High
3. ECS Task Count Mismatch
4. ALB 5XX Errors
5. ALB High Latency
6. ALB Unhealthy Targets
7. DynamoDB Errors
8. DynamoDB High Latency

### CloudWatch Dashboard
Professional 8-widget dashboard showing:
- ECS metrics
- ALB metrics
- DynamoDB metrics
- Real-time monitoring

## 🗑️ Cleanup

```bash
# Destroy all infrastructure
terraform destroy -var="aws_account_id=$AWS_ACCOUNT_ID"

# Remove Terraform state files
rm -rf .terraform terraform.tfstate*
```

## 📚 Additional Documentation

- `DEMO_GUIDE.md` - Step-by-step demo walkthrough
- `DEVOPS_AGENT_GUIDE.md` - Investigation queries
- `terraform.tfvars` - Example configuration

## 🔗 Resources

- [AWS DevOps Agent Documentation](https://docs.aws.amazon.com/devops-agent/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [ECS Fargate Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)

## 💡 Tips

- Use `terraform plan` before applying to review changes
- Export `AWS_REGION` environment variable for consistency
- Save outputs to a file: `terraform output > deployment.txt`
- Use `-target` for granular deployments
- Enable debug logging: `TF_LOG=DEBUG terraform apply`

## 🤝 Support

For issues or questions:
1. Check CloudWatch logs
2. Verify IAM permissions
3. Review Terraform state: `terraform state show`
4. Use `terraform refresh` to sync state

---

**Ready to demo AWS DevOps Agent! 🚀**
