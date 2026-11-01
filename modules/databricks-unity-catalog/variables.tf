variable "location" {
  type        = string
  description = "Azure region. The metastore region must match the workspace region."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to Azure resources."
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID (GUID shown in the account console)."
}

variable "workspace_id" {
  type        = string
  description = "Numeric workspace ID to assign the metastore to (output of the workspace unit)."
}

variable "existing_metastore_id" {
  type        = string
  default     = null
  description = <<-EOT
    Only one metastore is allowed per region per account. If one already exists in this region,
    set its ID here to skip creating the storage, access connector and metastore and only
    assign the workspace to it.
  EOT
}

variable "resource_group_name" {
  type        = string
  default     = null
  description = "Resource group for the metastore storage account and access connector. Required when creating a metastore."
}

variable "storage_account_name" {
  type        = string
  default     = null
  description = "ADLS Gen2 storage account for the metastore root (globally unique, 3-24 lowercase alphanumerics). Required when creating a metastore."
}

variable "storage_replication_type" {
  type        = string
  default     = "GRS"
  description = "Replication for the metastore root storage account."
}

variable "container_name" {
  type        = string
  default     = "uc-metastore"
  description = "Container holding the metastore root."
}

variable "access_connector_name" {
  type        = string
  default     = null
  description = "Name of the Azure Databricks access connector (managed identity). Required when creating a metastore."
}

variable "metastore_name" {
  type        = string
  default     = null
  description = "Metastore name. Required when creating a metastore."
}

variable "metastore_owner" {
  type        = string
  default     = null
  description = "Owner of the metastore (user, service principal or group name). Defaults to the creator; a group is recommended."
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "Allow destroying the metastore even if it contains catalogs. Keep false outside throwaway environments."
}
