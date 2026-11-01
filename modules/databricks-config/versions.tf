terraform {
  required_version = ">= 1.6.0"

  required_providers {
    # root.hcl generates an azurerm provider block for every unit, so it must be declared here.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.50"
    }
  }
}
