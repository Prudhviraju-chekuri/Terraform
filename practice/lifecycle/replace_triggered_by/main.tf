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

variable "instance_type" {
  default = "t3.micro"
}

locals {
  userdata_hash = filesha1("script.sh")
}

resource "null_resource" "userdata_trigger" {
  triggers = {
    hash = local.userdata_hash
  }

}

resource "random_id" "for-replace-instance-type" {
  keepers = {
    instance_type = var.instance_type
  }
  byte_length = 2
}

resource "aws_instance" "replace_triggered_ec2" {
  ami           = "ami-0c398cb65a93047f2"
  instance_type = var.instance_type
  key_name      = "mylinux"
  user_data     = file("script.sh")
  tags = {
    Name = "rep_trigg_by_ec2"
  }
  lifecycle {
    create_before_destroy = true
    replace_triggered_by  = [random_id.for-replace-instance-type.hex, null_resource.userdata_trigger.id]
  }

}