terraform {
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.99.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "1.6.0"
    }
  }
}
