output "workspace_id" {
  description = "Numeric workspace ID (needed for Unity Catalog metastore assignment)."
  value       = azurerm_databricks_workspace.this.workspace_id
}

output "workspace_resource_id" {
  description = "Azure resource ID of the workspace."
  value       = azurerm_databricks_workspace.this.id
}

output "workspace_url" {
  description = "Workspace URL including scheme."
  value       = "https://${azurerm_databricks_workspace.this.workspace_url}"
}

output "managed_resource_group_id" {
  value = azurerm_databricks_workspace.this.managed_resource_group_id
}
