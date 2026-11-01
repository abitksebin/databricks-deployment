# Root Terragrunt configuration. Every unit includes this file.
# Provides: remote state (Azure Storage), azurerm provider generation, shared inputs.

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  project         = local.env_vars.locals.project
  env             = local.env_vars.locals.env
  location        = local.env_vars.locals.location
  subscription_id = local.env_vars.locals.subscription_id

  tags = merge(
    {
      project     = local.project
      environment = local.env
      managed_by  = "terragrunt"
    },
    local.env_vars.locals.extra_tags
  )
}

# Remote state in Azure Blob Storage (create it first with scripts/bootstrap-state.sh).
remote_state {
  backend = "azurerm"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    subscription_id      = local.subscription_id
    resource_group_name  = local.env_vars.locals.state_resource_group
    storage_account_name = local.env_vars.locals.state_storage_account
    container_name       = local.env_vars.locals.state_container
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    use_azuread_auth     = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
  subscription_id = "${local.subscription_id}"
}
EOF
}

# Inputs available to every module (modules declare the ones they use).
inputs = {
  project     = local.project
  environment = local.env
  location    = local.location
  tags        = local.tags
}
