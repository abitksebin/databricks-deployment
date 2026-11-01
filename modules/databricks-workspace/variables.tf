variable "location" {
  type        = string
  description = "Azure region."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources."
}

variable "workspace_name" {
  type        = string
  description = "Azure Databricks workspace name."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group in which the workspace resource is created."
}

variable "managed_resource_group_name" {
  type        = string
  description = "Name of the Databricks-managed resource group (must not already exist)."
}

variable "sku" {
  type        = string
  default     = "premium"
  description = "Workspace SKU: standard, premium or trial. Premium is required for RBAC, Unity Catalog and Private Link."

  validation {
    condition     = contains(["standard", "premium", "trial"], var.sku)
    error_message = "sku must be standard, premium or trial."
  }
}

variable "virtual_network_id" {
  type        = string
  description = "ID of the VNet the workspace is injected into."
}

variable "public_subnet_name" {
  type        = string
  description = "Name of the host (public) subnet."
}

variable "private_subnet_name" {
  type        = string
  description = "Name of the container (private) subnet."
}

variable "public_subnet_nsg_association_id" {
  type        = string
  description = "ID of the NSG association on the host subnet."
}

variable "private_subnet_nsg_association_id" {
  type        = string
  description = "ID of the NSG association on the container subnet."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Allow access to the workspace UI/API over the public internet. Disable only once Private Link is configured."
}
