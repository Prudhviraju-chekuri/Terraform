terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.7.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
  
}

variable "app_config" {
  type = object({
    name           = string
    instance_type  = string
    port_number    = number
    two_instances_needed    = bool
  })

}

resource "aws_instance" "example" {
  count = var.app_config.two_instances_needed? 2:1
  instance_type = var.app_config.instance_type
  ami = "ami-0c398cb65a93047f2"
  tags = {
    Name = "${var.app_config.name}-instance-${count.index + 1}"
  }
  
}







