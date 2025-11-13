terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.7.0"
    }
  }
}

provider "aws" {
    alias = "UsEast1"
    region = "us-east-1"
  
}

provider "aws" {
    alias = "UsWest1"
    region = "us-west-1"
  
}

resource "aws_instance" "tf-multiregion-east1" {
    provider = aws.UsEast1
    ami = "ami-0c398cb65a93047f2"
    instance_type = "t3.micro"
    key_name = "mylinux"
    tags = {
      Name = "EC2-EAST1"
    }
  
}

resource "aws_instance" "tf-multiregion-west1" {
    provider = aws.UsWest1
    ami = "ami-04f34746e5e1ec0fe"
    instance_type = "t3.micro"
    key_name = "mylinux"
    tags = {
      Name = "EC2-WEST1"
    }
  
}

output "EAST1-ec2-ip-address" {
    value = aws_instance.tf-multiregion-east1.public_ip
  
}

output "WEST1-ec2-ip-address" {
    value = aws_instance.tf-multiregion-west1.public_ip
  
}