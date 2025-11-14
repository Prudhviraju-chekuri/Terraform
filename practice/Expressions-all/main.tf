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

#####################################
# 1. Variables (maps, lists, object)
#####################################

variable "subnet_cidrs" {
    type = map(string)
    default = {
      subnet-a = "10.0.1.0/24"
      subnet-b = "10.0.2.0/24"
    }
  
}

variable "app_config" {
    type = object({
      env = string
      instance_type = string
      tags_enabled = bool
    })
    default = {
      env = "dev"
      instance_type = "t3.micro"
      tags_enabled = true
    }
  
}

variable "ports" {
    type = list(number)
    default = [ 22, 80 ]
  
}

#####################################
# 2. Locals (reusable expressions)
#####################################

locals {
  name_prefix = "${var.app_config.env}-webapp"
  upper_env = upper(var.app_config.env)
  instance_type = var.app_config.env == "Prod" ? "t3.small" : var.app_config.instance_type
}

#####################################
# 3. Create subnets using for_each
#####################################
resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "VPC-Expressions"
    }
  
}

resource "aws_subnet" "subnets" {
    for_each = var.subnet_cidrs
    cidr_block = each.value
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "${local.name_prefix}-${each.key}"
    }
 
}

####################################
# 4. Security group using dynamic block
####################################

resource "aws_security_group" "sg" {
    name = "${local.name_prefix}-sg"
    vpc_id = aws_vpc.vpc.id
    dynamic "ingress" {
        for_each = var.ports
        content {
          to_port = ingress.value
          from_port = ingress.value
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      
    }
  
}

#####################################
# 5. EC2 with count + depends_on
#####################################

resource "aws_instance" "instance" {
    count = length(var.subnet_cidrs)
    ami = "ami-0c398cb65a93047f2"
    instance_type = local.instance_type
    subnet_id = values(aws_subnet.subnets)[count.index].id
    depends_on = [ aws_security_group.sg ]

    tags = var.app_config.tags_enabled ? {
       Name     = "${local.name_prefix}-${count.index}"
       Env      = lower(local.upper_env)
       Subnet   = element(keys(var.subnet_cidrs), count.index)
     } : null
}

#####################################
# 6. Outputs (splat + for expression)
#####################################
output "instance_ids" {
  value = aws_instance.instance[*].id                       # Splat expression
}

output "instance_private_ips" {
  value = [for i in aws_instance.instance : i.private_ip]   # For-expression
}