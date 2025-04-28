variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "resource_group_location" {
  description = "Resource Group location"
  type        = string
}
variable "azure_virtual_network_name" {
  description = "Name for the virtual network"
  type        = string
}

variable "azure_hub_subnet_name" {
  description = "Name for the subnet"
  type        = string
}

variable "azure_LB_name" {
  description = "Name for the LB"
  type        = string
}

variable "azure_lb_rule_spok1_name" {
  description = "name for the rule of spoke 1"
  type        = string
}

variable "azure_lb_rule_spok2_name" {
  description = "name for the rule of spoke 2 "
  type        = string
}

variable "hub_gateway_subnet_name" {
  description = "name for hub subnet gateway"
  type        = string
}

variable "Public_ip_name" {
  description = "Name for the public ip for vpn"
  type        = string
}

variable "hub_vpn_gateway" {
  description = "Name for the Vpn gateway"
  type        = string
}

variable "spoke1_probe_name" {
  description = "Name for the spoke1 health probe"
  type        = string
}

variable "spoke2_probe_name" {
  description = "Name for the spoke2 health probe"
  type        = string
}
