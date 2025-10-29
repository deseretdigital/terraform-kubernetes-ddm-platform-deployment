module "deployment_workload_identity" {
  count = local.enable_workload_identity ? 1 : 0

  source       = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version      = "~> 33.0"
  name         = local.service_account_name
  namespace    = data.kubernetes_namespace.deployment_namespace.id
  cluster_name = var.gke_cluster_name
  project_id   = var.project
  roles        = var.roles
}

# Create a basic Kubernetes service account when workload identity is not enabled
resource "kubernetes_service_account" "basic" {
  count = local.enable_workload_identity ? 0 : 1

  metadata {
    name      = local.service_account_name
    namespace = data.kubernetes_namespace.deployment_namespace.id
    labels    = var.labels
  }
}
