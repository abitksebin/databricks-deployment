include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/databricks-unity-catalog"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    resource_group_name = "mock-rg"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "workspace" {
  config_path = "../workspace"

  mock_outputs = {
    workspace_id = "1234567890123456"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  databricks_account_id = local.env_vars.locals.databricks_account_id
  workspace_id          = dependency.workspace.outputs.workspace_id

  # One metastore per region per account. If one already exists in this region,
  # uncomment the next line and delete the "create" block below.
  # existing_metastore_id = "00000000-0000-0000-0000-000000000000"

  # --- create a new metastore ---
  resource_group_name  = dependency.network.outputs.resource_group_name
  storage_account_name = "stdbxucdev001" # globally unique, 3-24 lowercase alphanumerics
  access_connector_name = "dbac-dbx-uc-dev"
  metastore_name       = "metastore-uksouth"
  # metastore_owner    = "uc-admins"     # a group is recommended over an individual
}
