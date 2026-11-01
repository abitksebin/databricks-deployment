resource "azurerm_databricks_workspace" "this" {
  name                        = var.workspace_name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  sku                         = var.sku
  managed_resource_group_name = var.managed_resource_group_name
  tags                        = var.tags

  public_network_access_enabled = var.public_network_access_enabled

  # "AllRules" lets Databricks add its control-plane rules to the NSG.
  # With public access disabled, use "NoAzureDatabricksRules" and back-end Private Link.
  network_security_group_rules_required = var.public_network_access_enabled ? "AllRules" : "NoAzureDatabricksRules"

  custom_parameters {
    no_public_ip        = true # secure cluster connectivity (SCC)
    virtual_network_id  = var.virtual_network_id
    public_subnet_name  = var.public_subnet_name
    private_subnet_name = var.private_subnet_name

    public_subnet_network_security_group_association_id  = var.public_subnet_nsg_association_id
    private_subnet_network_security_group_association_id = var.private_subnet_nsg_association_id
  }
}
