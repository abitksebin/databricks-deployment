data "databricks_spark_version" "lts" {
  long_term_support = true
}

# --- Cluster policy: caps cost and enforces auto-termination for non-admins

resource "databricks_cluster_policy" "standard" {
  name = "standard-${var.environment}"

  definition = jsonencode({
    "autotermination_minutes" = {
      type   = "range"
      maxValue = 120
      defaultValue = var.autotermination_minutes
    }
    "node_type_id" = {
      type  = "allowlist"
      values = [var.node_type_id, "Standard_DS4_v2", "Standard_E4ds_v5"]
      defaultValue = var.node_type_id
    }
    "autoscale.max_workers" = {
      type     = "range"
      maxValue = 20
      defaultValue = var.max_workers
    }
    "custom_tags.environment" = {
      type  = "fixed"
      value = var.environment
    }
  })
}

# --- Group

resource "databricks_group" "data_engineers" {
  display_name          = var.data_engineers_group_name
  workspace_access      = true
  databricks_sql_access = true
}

# --- Shared autoscaling cluster

resource "databricks_cluster" "shared" {
  cluster_name            = "shared-${var.environment}"
  spark_version           = data.databricks_spark_version.lts.id
  node_type_id            = var.node_type_id
  policy_id               = databricks_cluster_policy.standard.id
  autotermination_minutes = var.autotermination_minutes
  data_security_mode      = "USER_ISOLATION"

  autoscale {
    min_workers = var.min_workers
    max_workers = var.max_workers
  }

  custom_tags = var.tags
}

resource "databricks_permissions" "shared_cluster" {
  cluster_id = databricks_cluster.shared.id

  access_control {
    group_name       = databricks_group.data_engineers.display_name
    permission_level = "CAN_RESTART"
  }
}

resource "databricks_permissions" "policy" {
  cluster_policy_id = databricks_cluster_policy.standard.id

  access_control {
    group_name       = databricks_group.data_engineers.display_name
    permission_level = "CAN_USE"
  }
}
