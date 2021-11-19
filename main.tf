# COnfigure the Microsoft Azure Provider
terraform{
    required_providers{
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~>2.65"
        }
    }
}

provider "azurerm" {
    features {}
}

# Create a resource group if it doesn't exsist
resource "azurerm_resource_group" "AnsiCron" {
    name     = "myResourceGroup"
    location = "eastus"

    tags = {
        environment = "Ansible Cronjob"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "AnsiCron" {
    name                = "myVnet"
    address_space       = ["10.1.0.0/24"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.AnsiCron.name

    tags = {
        environment = "Ansible Cronjob"
    }
}