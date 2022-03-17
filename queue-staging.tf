locals {
  staging_resource_count = var.env == "aat" ? "1" : "0"
}

module "envelopes-staging-queue" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-queue?ref=master"
  name                = "envelopes-staging"
  namespace_name      = module.queue-namespace.name
  resource_group_name = azurerm_resource_group.rg.name

  requires_duplicate_detection            = "true"
  duplicate_detection_history_time_window = "PT59M"
  lock_duration                           = "PT5M"
  max_delivery_count                      = var.envelope_queue_max_delivery_count
}

module "processed-envelopes-staging-queue" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-queue?ref=master"
  name                = "processed-envelopes-staging"
  namespace_name      = module.queue-namespace.name
  resource_group_name = azurerm_resource_group.rg.name
  lock_duration       = "PT5M"
}

module "payments-staging-queue" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-queue?ref=master"
  name                = "payments-staging"
  namespace_name      = module.queue-namespace.name
  resource_group_name = azurerm_resource_group.rg.name
  lock_duration       = "PT5M"
  max_delivery_count  = var.payment_queue_max_delivery_count

  duplicate_detection_history_time_window = "PT15M"
}

# region connection strings and other shared queue information as Key Vault secrets
resource "azurerm_key_vault_secret" "envelopes_staging_queue_send_conn_str" {
  name         = "envelopes-staging-queue-send-connection-string"
  value        = module.envelopes-staging-queue.primary_send_connection_string
  key_vault_id = module.vault.key_vault_id
  count        = local.staging_resource_count
}

resource "azurerm_key_vault_secret" "envelopes_staging_queue_listen_conn_str" {
  name         = "envelopes-staging-queue-listen-connection-string"
  value        = module.envelopes-staging-queue.primary_listen_connection_string
  key_vault_id = module.vault.key_vault_id
  count        = local.staging_resource_count
}

resource "azurerm_key_vault_secret" "processed_envelopes_staging_queue_send_conn_str" {
  name         = "processed-envelopes-staging-queue-send-connection-string"
  value        = module.processed-envelopes-staging-queue.primary_send_connection_string
  key_vault_id = module.vault.key_vault_id
  count        = local.staging_resource_count
}

resource "azurerm_key_vault_secret" "processed_envelopes_staging_queue_listen_conn_str" {
  name         = "processed-envelopes-staging-queue-listen-connection-string"
  value        = module.processed-envelopes-staging-queue.primary_listen_connection_string
  key_vault_id = module.vault.key_vault_id
  count        = local.staging_resource_count
}

resource "azurerm_key_vault_secret" "payments_staging_queue_send_conn_str" {
  name         = "payments-staging-queue-send-connection-string"
  value        = module.payments-staging-queue.primary_send_connection_string
  key_vault_id = module.vault.key_vault_id
  count        = local.staging_resource_count
}

resource "azurerm_key_vault_secret" "payments_staging_queue_listen_conn_str" {
  name         = "payments-staging-queue-listen-connection-string"
  value        = module.payments-staging-queue.primary_listen_connection_string
  key_vault_id = module.vault.key_vault_id
  count        = local.staging_resource_count
}

resource "azurerm_key_vault_secret" "envelopes_staging_queue_send_access_key" {
  name         = "envelopes-staging-queue-send-shared-access-key"
  value        = module.envelopes-staging-queue.primary_send_shared_access_key
  key_vault_id = module.vault.key_vault_id
}

resource "azurerm_key_vault_secret" "envelopes_staging_queue_listen_access_key" {
  name         = "envelopes-staging-queue-listen-shared-access-key"
  value        = module.envelopes-staging-queue.primary_listen_shared_access_key
  key_vault_id = module.vault.key_vault_id
}

resource "azurerm_key_vault_secret" "processed_envelopes_staging_queue_send_access_key" {
  name         = "processed-envelopes-staging-queue-send-shared-access-key"
  value        = module.processed-envelopes-staging-queue.primary_send_shared_access_key
  key_vault_id = module.vault.key_vault_id
}

resource "azurerm_key_vault_secret" "processed_envelopes_staging_queue_listen_access_key" {
  name         = "processed-envelopes-staging-queue-listen-shared-access-key"
  value        = module.processed-envelopes-staging-queue.primary_listen_shared_access_key
  key_vault_id = module.vault.key_vault_id
}


resource "azurerm_key_vault_secret" "payments_staging_queue_send_access_key" {
  name         = "payments-staging-queue-send-shared-access-key"
  value        = module.payments-staging-queue.primary_send_shared_access_key
  key_vault_id = module.vault.key_vault_id
}

resource "azurerm_key_vault_secret" "payments_staging_queue_listen_access_key" {
  name         = "payments-staging-queue-listen-shared-access-key"
  value        = module.payments-staging-queue.primary_listen_shared_access_key
  key_vault_id = module.vault.key_vault_id
}

# endregion
