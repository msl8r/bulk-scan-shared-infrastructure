terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  alias           = "cft-mgmt"
  subscription_id = "ed302caf-ec27-4c64-a05e-85731c3ce90e"
  features {}
}

provider "azurerm" {
  features {}
  alias = "aks"
  subscription_id = var.aks_subscription_id
}

provider "azurerm" {
  features {}
  alias = "aks_preview"
  subscription_id = "8a07fdcd-6abd-48b3-ad88-ff737a4b9e3c"
}