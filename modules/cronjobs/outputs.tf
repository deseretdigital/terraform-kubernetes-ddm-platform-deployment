output "service_account" {
  description = "The name of the service account"
  value       = module.deployment_workload_identity.gcp_service_account
}
