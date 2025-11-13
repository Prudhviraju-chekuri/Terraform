terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# -----------------------------
# AWS Provider
# -----------------------------
provider "aws" {
  alias  = "aws-useast1"
  region = "us-east-1"
}

# -----------------------------
# Azure Provider
# -----------------------------
provider "azurerm" {
  alias    = "azure-prod"
  features {}
}

# -----------------------------
# AWS EC2 Instance
# -----------------------------
resource "aws_instance" "aws-ec2" {
  provider      = aws.aws-useast1
  ami           = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  key_name      = "mylinux"

  tags = {
    Name = "tf-ec2-t1"
  }
}

# -----------------------------
# Azure Resources
# -----------------------------
resource "azurerm_resource_group" "rg" {
  provider = azurerm.azure-prod
  name     = "TF-rg"
  location = "West US 2"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  provider            = azurerm.azure-prod
  name                = "TF-VNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  provider             = azurerm.azure-prod
  name                 = "TF-Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "public_ip" {
  provider            = azurerm.azure-prod
  name                = "TF-PublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Security Group (with SSH rule)
resource "azurerm_network_security_group" "nsg" {
  provider            = azurerm.azure-prod
  name                = "TF-NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "0.0.0.0/0"
    destination_address_prefix  = "*"
  }

}

# Network Interface
resource "azurerm_network_interface" "nic" {
  provider            = azurerm.azure-prod
  name                = "TF-NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  provider                     = azurerm.azure-prod
  network_interface_id          = azurerm_network_interface.nic.id
  network_security_group_id     = azurerm_network_security_group.nsg.id
  
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  provider            = azurerm.azure-prod
  name                = "tf-vm-t1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  network_interface_ids = [azurerm_network_interface.nic.id]
  size = "Standard_D2s_v3"
  disable_password_authentication = false
  admin_username = "azureuser"
  admin_password = "Parnika@1276" # ⚠️ Use SSH key in production

  os_disk {
    disk_size_gb         = 30
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    Name = "TF-Azure-VM"
  }
}

# -----------------------------
# Outputs
# -----------------------------
output "aws_ec2_public_ip" {
  value = aws_instance.aws-ec2.public_ip
}

output "azure_vm_public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}
