module "deployment_workload_identity" {
  count = local.enable_workload_identity ? 1 : 0

  source  = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version = "~> 41.0"

  # Core configuration
  name         = local.service_account_name
  namespace    = data.kubernetes_namespace.deployment_namespace.id
  cluster_name = var.gke_cluster_name
  project_id   = var.project
  location     = var.gke_location
  roles        = var.roles

  # Optional configurations
  use_existing_gcp_sa             = var.use_existing_gcp_sa
  gcp_sa_name                     = var.use_existing_gcp_sa ? null : local.service_account_name
  annotate_k8s_sa                 = !var.use_existing_gcp_sa
  automount_service_account_token = var.automount_service_account_token
}

# Create a basic Kubernetes service account when workload identity is not enabled
resource "kubernetes_service_account" "basic" {
  count = local.enable_workload_identity ? 0 : 1

  metadata {
    name      = local.service_account_name
    namespace = data.kubernetes_namespace.deployment_namespace.id
    labels    = local.labels
  }

  automount_service_account_token = var.automount_service_account_token
}
