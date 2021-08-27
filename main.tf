provider "azurerm" {
  version = "=2.49.0"
  features {}
}

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "1.6.0"
    }
  }
}

locals {
  product = "bulk-scan"
  tags = "${
    merge(
      var.common_tags,
      map(
        "Team Contact", "#rbs",
        "Team Name", "Bulk Scan"
      )
    )}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = "${var.location}"

  tags = "${local.tags}"
}
