# Environment-level settings for "dev". Copy this folder to live/<env> for staging/prod.

locals {
  project  = "dbx"
  env      = "dev"
  location = "uksouth"

  # Fill these in.
  subscription_id = "00000000-0000-0000-0000-000000000000"

  # Databricks account ID (account console -> top-right menu). Needed by the unity-catalog unit.
  databricks_account_id = "00000000-0000-0000-0000-000000000000"

  # Remote state backend (created by scripts/bootstrap-state.sh).
  # The storage account name must be globally unique, 3-24 chars, lowercase alphanumerics.
  state_resource_group  = "rg-tfstate-dev"
  state_storage_account = "stdbxtfstatedev001"
  state_container       = "tfstate"

  extra_tags = {
    owner       = "platform-team"
    cost_centre = "data"
  }
}
