terraform {
  required_providers {
    aws ={
        source = "hashicorp/aws"
        version = "~>5.7.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
  
}

variable "is_production" {
    type = bool
  
}

locals {
  instance_type = var.is_production ? "t3.micro" : "t3.small"
}

output "instance_type" {
    value = local.instance_type
  
}