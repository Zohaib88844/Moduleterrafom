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

resource "azurerm_resource_group" "Hub-Central" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = var.azure_virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Hub-Central.location
  resource_group_name = azurerm_resource_group.Hub-Central.name
}

resource "azurerm_subnet" "hub_subnet" {
  name                 = var.azure_hub_subnet_name
  resource_group_name  = azurerm_resource_group.Hub-Central.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.6.0/24"]

}

resource "azurerm_lb" "hub_lb" {
  name                = var.azure_LB_name
  location            = azurerm_resource_group.Hub-Central.location
  resource_group_name = azurerm_resource_group.Hub-Central.name
  sku                 = "Standard"


  frontend_ip_configuration {

    name                          = "frontend1"
    subnet_id                     = azurerm_subnet.hub_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  frontend_ip_configuration {

    name                          = "frontend2"
    subnet_id                     = azurerm_subnet.hub_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Frontend rule for Spoke 1 App on port 7000
resource "azurerm_lb_rule" "hub_rule_spoke1" {
  name                           = var.azure_lb_rule_spok1_name
  protocol                       = "Tcp"
  frontend_port                  = 7000
  backend_port                   = 3000
  frontend_ip_configuration_name = "frontend1"
  loadbalancer_id                = azurerm_lb.hub_lb.id
  probe_id                       = azurerm_lb_probe.hub_probe_spoke1.id

}

resource "azurerm_lb_probe" "hub_probe_spoke1" {
  name            = var.spoke1_probe_name
  protocol        = "Tcp"
  port            = 3000
  loadbalancer_id = azurerm_lb.hub_lb.id


}

# Frontend rule for Spoke 2 App on port 7001
resource "azurerm_lb_rule" "hub_rule_spoke2" {
  name                           = var.azure_lb_rule_spok2_name
  protocol                       = "Tcp"
  frontend_port                  = 7001
  backend_port                   = 3000
  frontend_ip_configuration_name = "frontend2"
  loadbalancer_id                = azurerm_lb.hub_lb.id
  probe_id                       = azurerm_lb_probe.hub_probe_spoke2.id
}

resource "azurerm_lb_probe" "hub_probe_spoke2" {
  name            = var.spoke2_probe_name
  protocol        = "Tcp"
  port            = 3000
  loadbalancer_id = azurerm_lb.hub_lb.id
}

resource "azurerm_subnet" "hub_gateway_subnet" {
  name                 = var.hub_gateway_subnet_name
  resource_group_name  = azurerm_resource_group.Hub-Central.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.255.0/27"]


}

resource "azurerm_public_ip" "vpn_pip" {
  name                = var.Public_ip_name
  location            = azurerm_resource_group.Hub-Central.location
  resource_group_name = azurerm_resource_group.Hub-Central.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_virtual_network_gateway" "hub_vpn_gateway" {
  name                = var.hub_vpn_gateway
  location            = azurerm_resource_group.Hub-Central.location
  resource_group_name = azurerm_resource_group.Hub-Central.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  sku                 = "Basic"


  ip_configuration {
    name                          = "vpngateway-ipconfig"
    public_ip_address_id          = azurerm_public_ip.vpn_pip.id
    subnet_id                     = azurerm_subnet.hub_gateway_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  }
