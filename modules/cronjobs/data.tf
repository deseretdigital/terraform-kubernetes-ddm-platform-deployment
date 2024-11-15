data "kubernetes_namespace" "deployment_namespace" {
  metadata {
    name = var.namespace
  }
}