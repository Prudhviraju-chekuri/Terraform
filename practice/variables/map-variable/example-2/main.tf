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

variable "environment_tags" {
    type = map(map(string))
    default = {
      dev ={
        Environment = "Development"
        owner = "Satish"
      }

      stage = {
        Environment = "Staging"
        Project = "website"

      }
      prod = {
        Name = "Prod-EC2"
        Environment = "Production"
        owner = "Admin"
        cost_center = "FN_001-004"

      }
    }  
}

variable "env" {
    type = string
    default = "dev"
  
}

resource "aws_instance" "example" {
    ami = "ami-0c398cb65a93047f2"
    instance_type = "t3.micro"
    tags = {
      Name = lookup(var.environment_tags[var.env], "Name", "DefaultName")
      Environment = lookup(var.environment_tags[var.env], "Environment", "Unknown")
      owner = lookup(var.environment_tags[var.env], "owner", "No owner")
      project = lookup(var.environment_tags[var.env], "Project", "General")
      cost_center = lookup(var.environment_tags[var.env], "cost_center", "NA")
    }
  
}