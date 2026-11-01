include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/databricks-workspace"
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    resource_group_name                  = "mock-rg"
    vnet_id                              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/virtualNetworks/mock-vnet"
    public_subnet_name                   = "mock-public"
    private_subnet_name                  = "mock-private"
    public_subnet_nsg_association_id     = "mock-public-nsg-assoc"
    private_subnet_nsg_association_id    = "mock-private-nsg-assoc"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  workspace_name              = "dbw-dbx-dev"
  managed_resource_group_name = "rg-dbx-dev-databricks-managed"
  sku                         = "premium"

  resource_group_name = dependency.network.outputs.resource_group_name
  virtual_network_id  = dependency.network.outputs.vnet_id
  public_subnet_name  = dependency.network.outputs.public_subnet_name
  private_subnet_name = dependency.network.outputs.private_subnet_name

  public_subnet_nsg_association_id  = dependency.network.outputs.public_subnet_nsg_association_id
  private_subnet_nsg_association_id = dependency.network.outputs.private_subnet_nsg_association_id

  # Set to false only after you have front-end and back-end Private Link in place.
  public_network_access_enabled = true
}
