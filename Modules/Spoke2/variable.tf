
variable "admin_username" {
  description = "User-name for virtual machine"
  type        = string
}

variable "admin_password" {
  description = "password for virtual machine"
  type        = string
}


variable "publisher" {
  description = "Define Publisher"
  type        = string
}

variable "offer" {
  description = "Define offer"
  type        = string
}

variable "sku" {
  description = "Define Sku"
  type        = string
}

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

variable "subnet_name1" {
  description = "Name for the subnet"
  type        = string
}
variable "subnet_name2" {
  description = "Name for the subnet"
  type        = string
}

variable "NIC_name1" {
  description = "Name for the NIC"
  type        = string
}
variable "NIC_name2" {
  description = "Name for the NIC"
  type        = string
}

variable "VM_name" {
  description = "Name for the VM"
  type        = string
}

variable "NSG_name" {
  description = "Name for the NSG"
  type        = string
}

variable "LB_name" {
  description = "Name for the LB"
  type        = string
}

variable "azure_lb_rule_spok2_name" {
  description = "name for the rule of spoke 1 backend"
  type        = string
}

variable "azurerm_lb_backend_address_pool" {
  description = "Name for the lb backend pool address"
  type        = string
}


variable "spoke2_probe_name" {
  description = "Name for the spoke1 health probe"
  type        = string
}