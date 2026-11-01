variable "project" {
  type        = string
  description = "Project short name (supplied by root.hcl)."
}

variable "environment" {
  type        = string
  description = "Environment name (supplied by root.hcl)."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to create for networking."
}

variable "vnet_name" {
  type        = string
  description = "Virtual network name."
}

variable "vnet_cidr" {
  type        = string
  description = "Address space of the VNet."
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR of the Databricks host (public) subnet."
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR of the Databricks container (private) subnet."
}

variable "private_endpoints_subnet_cidr" {
  type        = string
  description = "CIDR of the subnet reserved for private endpoints (Private Link, storage, Key Vault, ...)."
}
