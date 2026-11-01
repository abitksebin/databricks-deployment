include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/network"
}

inputs = {
  resource_group_name = "rg-dbx-network-dev"
  vnet_name           = "vnet-dbx-dev"
  vnet_cidr           = "10.10.0.0/16"

  # Databricks host (public) and container (private) subnets. Size for your max cluster nodes:
  # a /24 gives ~250 IPs, i.e. roughly 125 nodes per subnet pair after Azure's reserved addresses.
  public_subnet_cidr            = "10.10.0.0/24"
  private_subnet_cidr           = "10.10.1.0/24"
  private_endpoints_subnet_cidr = "10.10.2.0/27"
}
