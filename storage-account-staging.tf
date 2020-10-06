locals {
  stage                    ="${var.env == "aat" ? "1": "0"}"
  external_hostname_suffix = "platform.hmcts.net"
  stripped_product_stg     = "${replace(var.product, "-", "")}"
  account_name_stg         = "${local.stripped_product_stg}${var.env}staging"
  mgmt_network_name_stg    = "core-cftptl-intsvc-vnet"
  mgmt_network_rg_name_stg = "aks-infra-cftptl-intsvc-rg"
  prod_hostname_stg        = "${local.stripped_product_stg}stg.${local.external_hostname_suffix}"
  nonprod_hostname_stg     = "${local.stripped_product_stg}stg.${var.env}.${local.external_hostname_suffix}"
  external_hostname_stg    = "${ var.env == "prod" ? local.prod_hostname_stg : local.nonprod_hostname_stg}"

  // for each client service two containers are created: one named after the service
  // and another one, named {service_name}-rejected, for storing envelopes rejected by bulk-scan
  client_service_names_stg = ["bulkscanauto", "bulkscan", "sscs", "divorce", "probate", "finrem", "cmc"]
}

data "azurerm_subnet" "jenkins_subnet_stg" {
  provider             = "azurerm.mgmt"
  name                 = "iaas"
  virtual_network_name = "${local.mgmt_network_name_stg}"
  resource_group_name  = "${local.mgmt_network_rg_name_stg}"
}

data "azurerm_subnet" "aks_00_subnet_stg" {
  provider             = "azurerm.mgmt"
  name                 = "aks-00"
  virtual_network_name = "${local.mgmt_network_name_stg}"
  resource_group_name  = "${local.mgmt_network_rg_name_stg}"
}

data "azurerm_subnet" "aks_01_subnet_stg" {
  provider             = "azurerm.mgmt"
  name                 = "aks-01"
  virtual_network_name = "${local.mgmt_network_name_stg}"
  resource_group_name  = "${local.mgmt_network_rg_name_stg}"
}

resource "azurerm_storage_account" "storage_account_staging" {
  count               = "${var.env == "aat" ? "1": "0"}"
  name                = "${local.account_name_stg}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  location                 = "${azurerm_resource_group.rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "BlobStorage"

  custom_domain {
    name          = "${local.external_hostname_stg}"
    use_subdomain = "false"
  }

  network_rules {
    virtual_network_subnet_ids = ["${data.azurerm_subnet.scan_storage_subnet.id}", "${data.azurerm_subnet.jenkins_subnet_stg.id}", "${data.azurerm_subnet.aks_00_subnet_stg.id}", "${data.azurerm_subnet.aks_01_subnet_stg.id}"]
    bypass                     = ["Logging", "Metrics", "AzureServices"]
    default_action             = "Deny"
  }

  tags = "${local.tags}"
}
    
module "storage_containers_stage" {
  count               = "${var.env == "aat" ? "1": "0"}"
  source              = "storage-containers"    
  storage_account_name = "${azurerm_storage_account.storage_account_staging[count.index]"
  client_service_names = "${local.client_service_names_stg}"
}

resource "azurerm_key_vault_secret" "storage_account_staging_primary_key" {
  count        = local.stage
  key_vault_id = "${module.vault.key_vault_id}"
  name         = "storage-account-staging-primary-key"
  value        = "${azurerm_storage_account.storage_account_staging[count.index].primary_access_key}"
}

# this secret is used by blob-router-service for uploading blobs
resource "azurerm_key_vault_secret" "storage_account_staging_connection_string" {
  count        = local.stage
  key_vault_id = "${module.vault.key_vault_id}"
  name         = "storage-account-staging-connection-string"
  value        = "${azurerm_storage_account.storage_account_staging[count.index].primary_connection_string}"
}
