output "metastore_id" {
  description = "ID of the metastore the workspace is assigned to."
  value       = local.metastore_id
}

output "storage_account_name" {
  description = "Metastore root storage account (null when an existing metastore is used)."
  value       = local.create_metastore ? azurerm_storage_account.uc[0].name : null
}

output "access_connector_id" {
  description = "Access connector used by the default metastore credential (null when an existing metastore is used)."
  value       = local.create_metastore ? azurerm_databricks_access_connector.uc[0].id : null
}
