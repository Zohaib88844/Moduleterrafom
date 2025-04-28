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

terraform {
  backend "azurerm" {
    resource_group_name  = "Pipeline-RG1"
    storage_account_name = "terraformfilesave1"
    container_name       = "testtffiles"
    key                  = "dev.terraform.tfstate"
  }
}

module "Spoke1" {
  source                          = "./Spoke1"
  resource_group_name             = "Spoke1"
  resource_group_location         = "uaenorth"
  admin_password                  = "Zohaib@12345"
  admin_username                  = "azureadmin"
  publisher                       = "MicrosoftWindowsServer"
  offer                           = "WindowsServer"
  sku                             = "2016-Datacenter"
  azure_virtual_network_name      = "Spoke1"
  subnet_name                     = "Spoke1-subnet"
  NIC_name                        = "Spoke1-NIC"
  VM_name                         = "Spoke1-VM"
  NSG_name                        = "Spoke1-NSG"
  LB_name                         = "Spoke1-lb"
  azure_lb_rule_spok1_name        = "spoke1rule"
  azurerm_lb_backend_address_pool = "spoke1-backendpool"
  spoke1_probe_name               = "Spoke1probe1"
}

module "Spoke2" {
  source                          = "./Spoke2"
  resource_group_name             = "Spoke2"
  resource_group_location         = "uaenorth"
  admin_password                  = "Zohaib@12345"
  admin_username                  = "azureadmin"
  publisher                       = "MicrosoftWindowsServer"
  offer                           = "WindowsServer"
  sku                             = "2016-Datacenter"
  azure_virtual_network_name      = "Spoke2"
  subnet_name1                    = "Spoke2subnet1"
  subnet_name2                    = "Spoke2subnet2"
  NIC_name1                       = "Spoke2NIC1"
  NIC_name2                       = "Spoke2NIC2"
  VM_name                         = "Spoke2-VM"
  NSG_name                        = "Spoke2-NSG"
  LB_name                         = "Spoke2LB"
  azure_lb_rule_spok2_name        = "Spoke2rule"
  azurerm_lb_backend_address_pool = "spoke2-backendpool"
  spoke2_probe_name               = "Spoke2probe1"
}

module "hub" {
  source                     = "./Hub"
  resource_group_location    = "uaenorth"
  resource_group_name        = "Hub-Central"
  azure_virtual_network_name = "Hubvnet"
  azure_hub_subnet_name      = "hub-subnet"
  azure_LB_name              = "hub-lb"
  azure_lb_rule_spok1_name   = "hubtospoke1"
  azure_lb_rule_spok2_name   = "hubtospoke2"
  hub_gateway_subnet_name    = "GatewaySubnet"
  hub_vpn_gateway            = "hubvpngateway"
  Public_ip_name             = "publicip001"
  spoke1_probe_name          = "Spoke1probe"
  spoke2_probe_name          = "Spoke2probe"
}
