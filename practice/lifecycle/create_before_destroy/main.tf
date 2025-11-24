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

# created ec2 instance
/* resource "aws_instance" "lifecycle_EC2" {
  ami = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  key_name = "mylinux"
  tags = {
    Name = "lifecycle_1"
  }
} */

# changed key name so that existing ec2 is terminated first and then new ec2 will be created.

/* resource "aws_instance" "lifecycle_EC2" {
  ami = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  key_name = "app-server"
  tags = {
    Name = "lifecycle_2"
  }
} */

# using create_before_destroy and key name change so that ec2 will be created first and old one is terminated

resource "aws_instance" "lifecycle_EC2" {
  ami = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  key_name = "mylinux"
  tags = {
    Name = "lifecycle_3"
  }
  lifecycle {
    create_before_destroy = true
  }
}