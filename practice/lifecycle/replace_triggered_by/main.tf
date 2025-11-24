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
    create_before_destroy = true
    replace_triggered_by = [ md5(var.instance_type) ]
  }

  tags = {
    Name = "lifecycle_1"
  }
}