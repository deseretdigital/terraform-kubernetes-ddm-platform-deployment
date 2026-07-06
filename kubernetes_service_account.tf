module "deployment_workload_identity" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  # Pin below v44.3.0: that release renamed kubernetes_service_account →
  # kubernetes_service_account_v1 via a cross-resource-type `moved` block, which
  # Terraform rejects ("Move Resource State Not Supported"), breaking plan on the
  # unpinned 3.x line. 44.2.0 is the last release using the original resource.
  version = ">= 44.0, < 44.3.0"

  name         = var.service_account_name
  namespace    = data.kubernetes_namespace.deployment_namespace.id
  cluster_name = var.gke_cluster_name
  project_id   = var.project
  roles        = var.roles
}
