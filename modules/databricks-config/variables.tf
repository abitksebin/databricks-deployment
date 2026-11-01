variable "workspace_url" {
  type        = string
  description = "Databricks workspace URL (https://adb-....azuredatabricks.net)."
}

variable "environment" {
  type        = string
  description = "Environment name (supplied by root.hcl)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags used as custom_tags on clusters."
}

variable "node_type_id" {
  type        = string
  default     = "Standard_DS3_v2"
  description = "Azure VM size for cluster nodes."
}

variable "autotermination_minutes" {
  type        = number
  default     = 30
  description = "Idle minutes before the shared cluster terminates."
}

variable "min_workers" {
  type    = number
  default = 1
}

variable "max_workers" {
  type    = number
  default = 4
}

variable "data_engineers_group_name" {
  type        = string
  default     = "data-engineers"
  description = "Workspace-local group granted access to the shared cluster."
}
