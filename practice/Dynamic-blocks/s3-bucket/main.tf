terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>5.7.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
  
}

resource "aws_s3_bucket" "s3-bucket" {
    bucket = "Poorvika-s3-bucket-123456"
    
  
}

variable "my-bucket-lifecycle-rules" {
    type = list(object({
      id = string
      days = number
      status = string
    }))
    default = [ {
      id = "logs"
      days = 2
      status = "Enabled"
    },
    {
        id = "tests"
        days = 3
        status = "Enabled"
    } ]
  
}

resource "aws_s3_bucket" "my-bucket" {
    bucket = "poorvika-storage9989555"
    force_destroy = true
  
}


resource "aws_s3_bucket_lifecycle_configuration" "my-bucket-lifecycle" {
    bucket = "poorvika-storage9989555"
    dynamic "rule" {
      for_each = var.my-bucket-lifecycle-rules
      content {
        id = rule.value.id
        expiration {
          days = rule.value.days
        }
        status = rule.value.status
      }
    }

  
}