terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.26.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "434e3567-b4e4-45c8-9a4a-8262ec146d2a"
  client_id       = "f1d4d736-1e74-4c3f-8bf5-3681d7b1bdb9"
  client_secret   = "Bwh8Q~WyjVWrijAk-J0s25oBoD_FPt5lRzQvJc0S"
  tenant_id       = "97d50916-320c-43f2-b405-bb0a27ed3905"
  features {}
}

resource "azurerm_resource_group" "Spoke-1" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "Spoke1-vnet" {
  name                = var.azure_virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Spoke-1.location
  resource_group_name = azurerm_resource_group.Spoke-1.name


}

resource "azurerm_subnet" "Spoke1Subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.Spoke-1.name
  virtual_network_name = azurerm_virtual_network.Spoke1-vnet.name
  address_prefixes     = ["10.0.1.0/24"]

}

resource "azurerm_network_interface" "Spoke1-NIC" {
  name                = var.NIC_name
  location            = azurerm_resource_group.Spoke-1.location
  resource_group_name = azurerm_resource_group.Spoke-1.name



  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Spoke1Subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "Spoke-1" {
  name                = var.VM_name
  resource_group_name = azurerm_resource_group.Spoke-1.name
  location            = azurerm_resource_group.Spoke-1.location
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.Spoke1-NIC.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "Spoke1-NSG" {
  name                = var.NSG_name
  location            = azurerm_resource_group.Spoke-1.location
  resource_group_name = azurerm_resource_group.Spoke-1.name



  security_rule {
    name                       = "HTTPAllow"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "Subnet-TO-NSG" {
  subnet_id                 = azurerm_subnet.Spoke1Subnet.id
  network_security_group_id = azurerm_network_security_group.Spoke1-NSG.id
}

resource "azurerm_lb" "spoke1_lb" {
  name                = var.LB_name
  location            = azurerm_resource_group.Spoke-1.location
  resource_group_name = azurerm_resource_group.Spoke-1.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "frontendIP"
    subnet_id                     = azurerm_subnet.Spoke1Subnet.id
    private_ip_address_allocation = "Dynamic"

  }


}

resource "azurerm_lb_backend_address_pool" "spoke1_backend" {
  name            = var.azurerm_lb_backend_address_pool
  loadbalancer_id = azurerm_lb.spoke1_lb.id
}

resource "azurerm_lb_rule" "spoke1_lb_rule" {
  name                           = var.azure_lb_rule_spok1_name
  protocol                       = "Tcp"
  frontend_port                  = 3000
  backend_port                   = 80
  frontend_ip_configuration_name = "frontendIP"
  loadbalancer_id                = azurerm_lb.spoke1_lb.id
  probe_id                       = azurerm_lb_probe.spoke1_probe.id


}

resource "azurerm_lb_probe" "spoke1_probe" {
  name            = var.spoke1_probe_name
  protocol        = "Http"
  port            = 80
  request_path    = "/"
  loadbalancer_id = azurerm_lb.spoke1_lb.id
}