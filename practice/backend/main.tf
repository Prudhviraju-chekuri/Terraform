terraform {
  required_providers {
    aws ={
        source = "hashicorp/aws"
        version = "~>5.7.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
  
}

module "tf-ec2" {
    source = "../modules/EC2-instance"
    ubuntu2204-ami = "ami-0c398cb65a93047f2"
    instance-type = "t3.micro"
    key-name = "mylinux"
    ec2-name = "tf-backend-ec2"
  
}