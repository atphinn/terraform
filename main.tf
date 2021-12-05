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
    name                 = "GatewaySubnet"
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


resource "azurerm_local_network_gateway" "AnsiCron" {
  name                = "backHomeAnsible"
  resource_group_name = azurerm_resource_group.AnsiCron.name
  location            = azurerm_resource_group.AnsiCron.location
  gateway_address     = "74.71.128.129"
  address_space       = ["192.168.50.0/24"]
}

#Virtual getway to connect to Azure

resource "azurerm_virtual_network_gateway" "AnsiCron" {
  name                = "GatewaySubnet"
  location            = azurerm_resource_group.AnsiCron.location
  resource_group_name = azurerm_resource_group.AnsiCron.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  # ip_configuration {
  #   name                          = "vnetGatewayConfig"
  #   public_ip_address_id          = azurerm_public_ip.AnsiCron.id
  #   private_ip_address_allocation = "Dynamic"
  #   subnet_id                     = azurerm_subnet.AnsiCron.id
  # }

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.AnsiCron.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.AnsiCron.id
  }  
  
}

# Create network interface
resource "azurerm_network_interface" "AnsiCron" {
    name                      = "myNIC"
    location                  = azurerm_resource_group.AnsiCron.location
    resource_group_name       = azurerm_resource_group.AnsiCron.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.AnsiCron.id
        private_ip_address_allocation = "Dynamic"
        #public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = {
        environment = "Ansible cronjob"
    }
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "AnsiCron" {
    name                  = "myVM"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.AnsiCron.name
    network_interface_ids = [azurerm_network_interface.AnsiCron.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }


    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "20.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvm"
    admin_username = "r3tr0"
    disable_password_authentication = true

    tags = {
        environment = "Ansible Cronjob"
    }
}