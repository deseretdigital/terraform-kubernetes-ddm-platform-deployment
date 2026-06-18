module "deployment_workload_identity" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name         = "${var.application_name}-sa"
  namespace    = data.kubernetes_namespace.deployment_namespace.id
  cluster_name = var.gke_cluster_name
  project_id   = var.project
  roles        = var.roles
}