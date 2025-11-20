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

/* moved {
  from = aws_instance.ec2
  to = aws_instance.renamed_ec2

} */

/* resource "aws_instance" "ec2" {
  ami = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  tags = {
    Name = "removed-ec2"
  }
  
} */

/* resource "aws_instance" "renamed_ec2" {
  ami = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  tags = {
    Name = "removed-ec2"
  }
  
} */

# used removed block and destroy to false. the resource ec2 wont be managed by terraform, but wont destroy the real infrastructure.
removed {
  from = aws_instance.renamed_ec2
  lifecycle {
    destroy = false
  }
}