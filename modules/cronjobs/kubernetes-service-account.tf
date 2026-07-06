module "deployment_workload_identity" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version      = ">= 44.0, < 44.3.0" # pinned: v44.3.0 renamed SA via cross-type moved block, breaks plan
  name         = "${var.application_name}-sa"
  namespace    = data.kubernetes_namespace.deployment_namespace.id
  cluster_name = var.gke_cluster_name
  project_id   = var.project
  roles        = var.roles
}