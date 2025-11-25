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

variable "ebs_volumes" {
    type = list(object({
      size = number
      type = string
      name = string
    }))
    default = [ {
        name = "/dev/sdb"
        size = 8
        type = "gp3"
      
    },
    {
        name = "/dev/sdc"
        size = 8
        type = "gp3"
    } ]
  
}

# if we change volume sizes, terraform is not detecting and saying no changes required.
/* You used aws_instance with embedded ebs_block_device.
Terraform does NOT track these volumes separately, meaning:
Terraform cannot detect changes
Terraform cannot modify them
Terraform does NOT recreate the instance */
# so we need to use replace_triggered_by and random_id resource

resource "random_id" "ebs-volme-trigger" {
    keepers = {
      vol_json = jsonencode(var.ebs_volumes)
    }
    byte_length = 2
  
}

resource "aws_instance" "web-app" {
    ami = "ami-0c398cb65a93047f2"
    instance_type = "t3.micro"
    key_name = "mylinux"
    tags = {
      Name = "web-app"
    }
    lifecycle {
      create_before_destroy = true
      replace_triggered_by = [ random_id.ebs-volme-trigger.hex ]
    }
    dynamic "ebs_block_device" {
      for_each = var.ebs_volumes
      content {
        device_name = ebs_block_device.value.name
        volume_size = ebs_block_device.value.size
        volume_type = ebs_block_device.value.type
      }
    }

  
}