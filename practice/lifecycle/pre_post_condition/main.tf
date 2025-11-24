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

variable "instance_type" {
  default = "t3.micro"
}

resource "aws_instance" "lifecycle_EC2" {
  ami           = "ami-0c398cb65a93047f2"
  instance_type = var.instance_type
  key_name      = "mylinux"

  lifecycle {
    precondition {
      condition = var.instance_type != "c7i-flex.large"
      error_message = "flex large is too expensive"
    }
    postcondition {
      condition = self.public_ip != ""
      error_message = "EC2 did not receive a public IP!"
    }
  }

  tags = {
    Name = "lifecycle_1"
  }
}