terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.26.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "Spoke-2" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "Spoke2-vnet" {
  name                = var.azure_virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Spoke-2.location
  resource_group_name = azurerm_resource_group.Spoke-2.name


}

resource "azurerm_subnet" "Spoke2Subnet" {
  name                 = var.subnet_name1
  resource_group_name  = azurerm_resource_group.Spoke-2.name
  virtual_network_name = azurerm_virtual_network.Spoke2-vnet.name
  address_prefixes     = ["10.0.2.0/24"]


}
resource "azurerm_subnet" "Spoke2Subnet2" {
  name                 = var.subnet_name2
  resource_group_name  = azurerm_resource_group.Spoke-2.name
  virtual_network_name = azurerm_virtual_network.Spoke2-vnet.name
  address_prefixes     = ["10.0.3.0/24"]

}

resource "azurerm_network_interface" "Spoke2-NIC" {
  name                = var.NIC_name1
  location            = azurerm_resource_group.Spoke-2.location
  resource_group_name = azurerm_resource_group.Spoke-2.name




  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Spoke2Subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "Spoke2-NIC2" {
  name                = var.NIC_name2
  location            = azurerm_resource_group.Spoke-2.location
  resource_group_name = azurerm_resource_group.Spoke-2.name



  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Spoke2Subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "Spoke-2" {
  name                = var.VM_name
  resource_group_name = azurerm_resource_group.Spoke-2.name
  location            = azurerm_resource_group.Spoke-2.location
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.Spoke2-NIC.id,
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

resource "azurerm_network_security_group" "Spoke2-NSG" {
  name                = var.NSG_name
  location            = azurerm_resource_group.Spoke-2.location
  resource_group_name = azurerm_resource_group.Spoke-2.name



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
  subnet_id                 = azurerm_subnet.Spoke2Subnet.id
  network_security_group_id = azurerm_network_security_group.Spoke2-NSG.id
}

resource "azurerm_lb" "spoke2_lb" {
  name                = var.LB_name
  location            = azurerm_resource_group.Spoke-2.location
  resource_group_name = azurerm_resource_group.Spoke-2.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                          = "frontend"
    subnet_id                     = azurerm_subnet.Spoke2Subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "spoke2_backend" {
  name            = var.azurerm_lb_backend_address_pool
  loadbalancer_id = azurerm_lb.spoke2_lb.id
}

resource "azurerm_lb_rule" "spoke2_lb_rule" {
  name                           = var.azure_lb_rule_spok2_name
  protocol                       = "Tcp"
  frontend_port                  = 3000
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend"
  loadbalancer_id                = azurerm_lb.spoke2_lb.id
  probe_id                       = azurerm_lb_probe.spoke2_probe.id
}

resource "azurerm_lb_probe" "spoke2_probe" {
  name            = var.spoke2_probe_name
  protocol        = "Http"
  port            = 80
  request_path    = "/"
  loadbalancer_id = azurerm_lb.spoke2_lb.id
}
