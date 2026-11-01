output "shared_cluster_id" {
  value = databricks_cluster.shared.id
}

output "cluster_policy_id" {
  value = databricks_cluster_policy.standard.id
}

output "data_engineers_group_id" {
  value = databricks_group.data_engineers.id
}
