#Create 1 or 2 VPCs using count.
#Inside each VPC, create multiple subnets using for_each.
#Ensure subnets are created after the VPCs using depends_on.

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

variable "two_vpc_needed" {
    type = bool
    default = true
  
}

variable "subnets_CIDR" {
    type = map(string)
    default = {
      subnet-1 = "10.0.1.0/24"
      subnet-2 = "10.0.2.0/24"
      subnet-3 = "10.0.3.0/24"
    }
  
}

resource "aws_vpc" "vpc" {
    count = var.two_vpc_needed ? 2 : 1
    tags = {
      Name = "VPC-${count.index + 1}"
    }
    cidr_block = "10.${count.index}.0.0/16"
  
}

resource "aws_subnet" "subnets" {
    for_each = var.subnets_CIDR
    vpc_id = aws_vpc.vpc[0].id
    cidr_block = each.value
    tags = {
      Name = each.key
    }
    depends_on = [ aws_vpc.vpc ]
  
}