terraform {
  backend "s3" {
    bucket = "tf-prudhviraju-488-s3bucket"
    key = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "prudhvi-terraform-lock"
    
  }
}

/* terraform {
  backend "azurerm" {
    key = "value"
    resource_group_name = "value"
    container_name = "value"
    storage_account_name = "value"
    
  }
} */