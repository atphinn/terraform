# COnfigure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
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
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.AnsiCron.name

  tags = {
    environment = "Ansible Cronjob"
  }
}

# Create subnet
resource "azurerm_subnet" "AnsiCron" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.AnsiCron.name
    virtual_network_name = azurerm_virtual_network.AnsiCron.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "AnsiCron" {
    name                         = "myPublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.AnsiCron.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Cron"
    }
}



resource "azurerm_virtual_wan" "AnsiCron" {
  name                = "example-vwan"
  resource_group_name = azurerm_resource_group.AnsiCron.name
  location            = azurerm_resource_group.AnsiCron.location
}

resource "azurerm_virtual_hub" "AnsiCron" {
  name                = "example-hub"
  resource_group_name = azurerm_resource_group.AnsiCron.name
  location            = azurerm_resource_group.AnsiCron.location
  virtual_wan_id      = azurerm_virtual_wan.AnsiCron.id
  address_prefix      = "10.0.1.0/24"
}

resource "azurerm_vpn_gateway" "AnsiCron" {
  name                = "example-vpng"
  location            = azurerm_resource_group.AnsiCron.location
  resource_group_name = azurerm_resource_group.AnsiCron.name
  virtual_hub_id      = azurerm_virtual_hub.AnsiCron.id
}


