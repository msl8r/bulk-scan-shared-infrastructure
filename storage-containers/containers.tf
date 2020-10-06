resource "azurerm_storage_container" "service_containers_stg" {
  name                 = "${local.client_service_names_stg[count.index]}"
  storage_account_name = "${azurerm_storage_account.storage_account_staging.*.name}"
  count                = "${length(local.client_service_names_stg)}"
}

resource "azurerm_storage_container" "service_rejected_containers_stg" {
  name                 = "${local.client_service_names_stg[count.index]}-rejected"
  storage_account_name = "${azurerm_storage_account.storage_account_staging.*.name}"
  count                = "${length(local.client_service_names_stg)}"
}
