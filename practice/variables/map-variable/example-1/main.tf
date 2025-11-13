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

variable "instance_tags" {
    type = map(string)
    default = {
      "Name" = "EC2"
      "Environment" = "Dev"
    }
  
}

resource "aws_instance" "map-variable-instace" {
  ami = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  tags = var.instance_tags
  key_name = "mylinux"
  
}

output "enviroment" {
  value = var.instance_tags["Environment"]
  
}
