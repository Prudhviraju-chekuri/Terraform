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

/* resource "aws_s3_bucket" "prod-logs" {
  bucket = "pchekuri-prod-logs"
  
} */

resource "aws_s3_bucket" "prod-logs" {
  bucket = "pchekuri-prod-logs"
  lifecycle {
    prevent_destroy = true
  }
  
}

# Error:
/* Error: Instance cannot be destroyed
│
│   on main.tf line 19:
│   19: resource "aws_s3_bucket" "prod-logs" {
│
│ Resource aws_s3_bucket.prod-logs has lifecycle.prevent_destroy set, but the plan calls for this resource to   
│ be destroyed. To avoid this error and continue with the plan, either disable lifecycle.prevent_destroy or     
│ reduce the scope of the plan using the -target option. */