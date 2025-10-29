output "service_account" {
  description = "The name of the GCP service account (only available when workload identity is enabled)"
  value       = local.enable_workload_identity ? module.deployment_workload_identity[0].gcp_service_account : null
}

output "service_account_fqn" {
  description = "The fully qualified name of the GCP service account (only available when workload identity is enabled)"
  value       = local.enable_workload_identity ? module.deployment_workload_identity[0].gcp_service_account_fqn : null
}

output "k8s_service_account_name" {
  description = "The name of the Kubernetes service account"
  value       = local.enable_workload_identity ? module.deployment_workload_identity[0].k8s_service_account_name : kubernetes_service_account.basic[0].metadata[0].name
}
