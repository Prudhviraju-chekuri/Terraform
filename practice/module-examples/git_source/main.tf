terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.7.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
  
}

module "create_ec2" {
  source = "git::https://github.com/Prudhviraju-chekuri/Terraform.git//practice/modules/EC2-instance?ref=1ca083c"
  ubuntu2204-ami = "ami-0c398cb65a93047f2"
  instance-type = "t3.micro"
  key-name = "mylinux"
  ec2-name = "tf-ec2"
  
}