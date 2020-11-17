locals {
  preview_vnet_name           = "core-preview-vnet"
  preview_vnet_resource_group = "aks-infra-preview-rg"
}

data "azurerm_subnet" "preview_aks_00_storage_subnet" {
  name                 = "aks-00"
  virtual_network_name = local.preview_vnet_name
  resource_group_name  = local.preview_vnet_resource_group
}

data "azurerm_subnet" "preview_aks_01_storage_subnet" {
  name                 = "aks-01"
  virtual_network_name = local.preview_vnet_name
  resource_group_name  = local.preview_vnet_resource_group
}

