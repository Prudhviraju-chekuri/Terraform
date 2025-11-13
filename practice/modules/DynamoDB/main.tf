terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
    }
  }
}
variable "dynamodb-table-name" {
    type = string
  
}

variable "hash-key-name" {
    type = string
  
}
variable "hash-key-name-type" {
    type = string
  
}
variable "billing-mode" {
    type = string
  
}
resource "aws_dynamodb_table" "dynamoDB_state_locking" {
    name = var.dynamodb-table-name
    hash_key = var.hash-key-name
    attribute {
      name = var.hash-key-name
      type = var.hash-key-name-type
    }
    billing_mode = var.billing-mode
  
}

output "tableName" {
  value = aws_dynamodb_table.dynamoDB_state_locking.name
}