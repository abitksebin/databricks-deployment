locals {
  create_metastore = var.existing_metastore_id == null
  metastore_id     = local.create_metastore ? databricks_metastore.this[0].id : var.existing_metastore_id
}

# --- Metastore root storage (ADLS Gen2) -------------------------------------------------------

resource "azurerm_storage_account" "uc" {
  count = local.create_metastore ? 1 : 0

  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = var.storage_replication_type
  account_kind                    = "StorageV2"
  is_hns_enabled                  = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = var.tags
}

resource "azurerm_storage_container" "uc" {
  count = local.create_metastore ? 1 : 0

  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.uc[0].name
  container_access_type = "private"
}

# --- Managed identity Unity Catalog uses to reach the storage ---------------------------------

resource "azurerm_databricks_access_connector" "uc" {
  count = local.create_metastore ? 1 : 0

  name                = var.access_connector_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "uc_storage" {
  count = local.create_metastore ? 1 : 0

  scope                = azurerm_storage_account.uc[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.uc[0].identity[0].principal_id
}

# --- Metastore (account level) ----------------------------------------------------------------

resource "databricks_metastore" "this" {
  count = local.create_metastore ? 1 : 0

  name          = var.metastore_name
  region        = var.location
  storage_root  = format("abfss://%s@%s.dfs.core.windows.net/", azurerm_storage_container.uc[0].name, azurerm_storage_account.uc[0].name)
  owner         = var.metastore_owner
  force_destroy = var.force_destroy
}

resource "databricks_metastore_data_access" "this" {
  count = local.create_metastore ? 1 : 0

  metastore_id = databricks_metastore.this[0].id
  name         = "${var.metastore_name}-root"
  is_default   = true

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.uc[0].id
  }

  depends_on = [azurerm_role_assignment.uc_storage]
}

# --- Attach the workspace ---------------------------------------------------------------------

resource "databricks_metastore_assignment" "this" {
  metastore_id = local.metastore_id
  workspace_id = tonumber(var.workspace_id)

  depends_on = [databricks_metastore_data_access.this]
}
