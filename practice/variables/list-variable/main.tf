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

variable "availabilty_zones" {
    type = list(string)
    default = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
  
}

resource "aws_instance" "aws-ec2" {
    count = length(var.availabilty_zones)
    ami = "ami-0c398cb65a93047f2"
    instance_type = "t3.micro"
    availability_zone = var.availabilty_zones[count.index]
    tags = {
      Name = "EC2-Zone${count.index + 1}"
    }

  
}
