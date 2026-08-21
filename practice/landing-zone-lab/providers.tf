terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Local state on purpose for this lab. For a production landing zone
  # you would point this at an S3 backend + DynamoDB lock table instead.
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "secure-landing-zone-lab"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
