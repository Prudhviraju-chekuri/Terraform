terraform {
  required_providers {
    vault = {
        source = "hashicorp/vault"
        version = "~>3.0"
    }
    aws ={
        source = "hashicorp/aws"
        version = "~>5.7.0"
    }
  }
}

provider "vault" {
    address = "http://52.91.249.223:8200"
    auth_login {
      path = "auth/approle/login"
      parameters = {
        role_id = "81611a4d-d035-19e2-5ba9-4a2ee895b88a"
        secret_id = "c3aa5cbf-a25a-7196-5df7-247804564e0d"
      }
      
    }
    
  
}

data "vault_kv_secret_v2" "tf-secret" {
    mount = "secret"
    name = "Terraform"
  
}

locals {
  myazure-password = data.vault_kv_secret_v2.tf-secret.data["prudhvi_password"]
}

output "myaz-password" {
    value = local.myazure-password
    sensitive = true
  
}