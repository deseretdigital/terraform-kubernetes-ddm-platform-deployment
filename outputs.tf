output "name" {
  description = "The name of the deployment"
  value       = kubernetes_deployment.platform_deployment.metadata[0].name
}
