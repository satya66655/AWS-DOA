terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      DemoDate    = var.demo_date != "" ? var.demo_date : formatdate("DD-MM-YYYY", timestamp())
      CreatedBy   = "terraform"
      ManagedBy   = "terraform"
    }
  }
}

locals {
  demo_date = var.demo_date != "" ? var.demo_date : formatdate("DD-MM-YYYY", timestamp())
}
