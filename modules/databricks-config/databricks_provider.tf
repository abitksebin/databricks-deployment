# Workspace-level provider. Authenticates with Azure CLI locally, or with
# ARM_CLIENT_ID / ARM_CLIENT_SECRET / ARM_TENANT_ID (service principal) in CI.
# The identity needs to be a workspace admin (the identity that created the workspace is by default).
provider "databricks" {
  host = var.workspace_url
}
