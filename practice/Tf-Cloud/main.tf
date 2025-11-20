terraform {
  cloud {
    organization = "Prudhviraju-chekuri-tf-org"
    workspaces {
      name = "development"
    }
    
  }
  
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
    ami = "ami-0c398cb65a93047f2"
    instance_type = "t3.micro"
    key_name = "mylinux"
    tags = {
      Name = "Tf-cloud-ec2"
    }
  
}