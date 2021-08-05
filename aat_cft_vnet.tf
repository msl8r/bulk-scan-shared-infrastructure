locals {
  aat_cft_vnet_name           = "cft-aat-vnet"
  aat_cft_vnet_resource_group = "cft-aat-network-rg"
}

data "azurerm_subnet" "aat_cft_aks_00_subnet" {
  provider             = azurerm.aks
  name                 = "aks-00"
  virtual_network_name = local.aat_cft_vnet_name
  resource_group_name  = local.aat_cft_vnet_resource_group
}

data "azurerm_subnet" "aat_cft_aks_01_subnet" {
  provider             = azurerm.aks
  name                 = "aks-01"
  virtual_network_name = local.aat_cft_vnet_name
  resource_group_name  = local.aat_cft_vnet_resource_group
}

