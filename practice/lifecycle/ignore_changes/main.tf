terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.7.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

/* resource "aws_instance" "lifecycle_EC2" {
  ami = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  key_name = "mylinux"
  tags = {
    Name = "Ignore_changes"
    env = "Prod"
  }
} */

resource "aws_instance" "lifecycle_EC2" {
  ami           = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  key_name      = "mylinux"
  tags = {
    Name = "Ignore_changes"
    env  = "Prod"
  }
  /*   lifecycle {
    ignore_changes = [ tags ]
  } */

  lifecycle {
    ignore_changes = [tags["env"]]
  }
}

