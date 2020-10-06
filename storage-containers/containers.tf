variable "storage_account_name" {
  type = string
}

variable "client_service_names" {
  type = list(string)
}

resource "azurerm_storage_container" "service_containers_stg" {
  name                 = "${local.client_service_names_stg[count.index]}"
  storage_account_name = "${var.storage_account_name}"
  count                = "${length(var.client_service_names_stg)}"
}

resource "azurerm_storage_container" "service_rejected_containers_stg" {
  name                 = "${var.client_service_names_stg[count.index]}-rejected"
  storage_account_name = "${var.storage_account_name}"
  count                = "${length(var.client_service_names_stg)}"
}
