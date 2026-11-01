include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/databricks-config"
}

dependency "workspace" {
  config_path = "../workspace"

  mock_outputs = {
    workspace_url = "https://adb-0000000000000000.0.azuredatabricks.net"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

# The shared cluster uses USER_ISOLATION access mode, which needs Unity Catalog attached first.
dependencies {
  paths = ["../unity-catalog"]
}

inputs = {
  workspace_url = dependency.workspace.outputs.workspace_url

  node_type_id            = "Standard_DS3_v2"
  autotermination_minutes = 30
  min_workers             = 1
  max_workers             = 4

  data_engineers_group_name = "data-engineers"
}
