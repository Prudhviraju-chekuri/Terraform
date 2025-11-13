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

module "dynamoDB-table" {
    source = "../../modules/DynamoDB"
    dynamodb-table-name = "prudhvi-terraform-lock"
    hash-key-name = "LockID"
    hash-key-name-type = "S"
    billing-mode = "PAY_PER_REQUEST"
  
}

output "table-name" {
  value = module.dynamoDB-table.tableName
}