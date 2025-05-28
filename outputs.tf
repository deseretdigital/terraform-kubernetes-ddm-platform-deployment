output "name" {
  description = "The name of the deployment"
  value       = kubernetes_deployment.platform_deployment.metadata[0].name
}

output "service_account" {
  description = "The name of the service account"
  value       = module.deployment_workload_identity.gcp_service_account
}

output "service_account_fqn"{
  description = "The fully qualified name of the service account"
  value       = module.deployment_workload_identity.gcp_service_account_fqn
}
