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

/* resource "aws_instance" "example" {
  ami = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  tags = {
    Name = "after-import-ec2"
  }
  
} */

moved {
  to = aws_instance.ec2
  from = aws_instance.example
}

resource "aws_instance" "ec2" {
  ami = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  tags = {
    Name = "-namechanged_ec2"
  }
  
}