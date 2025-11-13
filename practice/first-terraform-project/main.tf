provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  
}
resource "azurerm_resource_group" "Terraform-rg" {
  name = "TF-rg"
  location = "West US 2"  
}
resource "azurerm_network_interface" "NIC" {
  name = "TF-NIC"
  location = azurerm_resource_group.Terraform-rg.location
  resource_group_name = azurerm_resource_group.Terraform-rg.name
  ip_configuration {
    name = "internal"
    private_ip_address_allocation = "Dynamic"
  }
  
}
resource "azurerm_linux_virtual_machine" "az-tf-vm" {
  name = "tf-vm"
  resource_group_name = azurerm_resource_group.Terraform-rg.name
  location = azurerm_resource_group.Terraform-rg.location
  network_interface_ids = [ azurerm_network_interface.NIC.id ]
  size = "Stansard_D1s_v3"
  os_disk {
    disk_size_gb = "30"
    storage_account_type = "Standard_LRS"
    caching = "ReadWrite"
  }
  admin_username = "azureuser"
  admin_password = "Parnika@1276"
  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  }

}

data "aws_ami" "Ubuntu" {
    most_recent = true
    owners = [ "amazon" ]
    
    filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
      
    }
    filter {
      name = "virtualization-type"
      values = [ "hvm" ]
    }
  
}

resource "aws_instance" "ec2instance" {
    ami = data.aws_ami.Ubuntu.id
    instance_type = "t3.micro"
    key_name = "mylinux"
    tags = {
        Name = "TFM-EC2"
      
    }
  
}

output "ubuntu-ami-id" {
    value = data.aws_ami.Ubuntu.id
  
}

output "public-ip" {
    value = aws_instance.ec2instance.public_ip
  
}


