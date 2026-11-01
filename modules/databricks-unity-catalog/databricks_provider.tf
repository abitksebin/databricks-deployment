# Account-level provider: metastores are account-scoped objects.
# The identity running Terraform (Azure CLI login locally, or ARM_CLIENT_ID / ARM_CLIENT_SECRET /
# ARM_TENANT_ID in CI) must be a Databricks ACCOUNT ADMIN. Being a workspace admin is not enough.
provider "databricks" {
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}
