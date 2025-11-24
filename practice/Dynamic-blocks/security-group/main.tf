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

variable "web-app-ports" {
  type = list(number)
  default = [ 22, 80, 8080 ]
}

resource "aws_security_group" "web-sg" {
    name = "web-app-sg"
    dynamic "ingress" {
        for_each = var.web-app-ports
        content {
          from_port = ingress.value
          to_port = ingress.value
          protocol = "tcp"
          cidr_blocks = [ "0.0.0.0/0" ]
        }
      
    }
  
}