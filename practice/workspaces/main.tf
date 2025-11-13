terraform {
  backend "s3" {
    bucket = "tf-prudhviraju-488-s3bucket"
    key = "terraform.tfstate"
    region = "us-east-1"
    
  }  
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

variable "ami" {
    type = string
  
}

variable "instance-type" {
    type = map(string)
  
}

variable "key-name" {
    type = string
  
}

module "tf-ec2" {
    source = "../modules/EC2-instance"
    ubuntu2204-ami = var.ami
    instance-type = lookup(var.instance-type, terraform.workspace, "t3.micro")
    key-name = var.key-name
    ec2-name =  "${terraform.workspace}-ec2"
  
}

output "ec2-ip-address" {
    value = module.tf-ec2.ec2-pub-ip
  
}