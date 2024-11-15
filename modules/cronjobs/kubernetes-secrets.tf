resource "kubernetes_secret" "kubernetes_secrets" {
  # Create Secrets block only when we have secrets
  count = length(var.secret_env_vars) > 0 ? 1 : 0

  metadata {
    name      = "${var.application_name}-secrets"
    namespace = data.kubernetes_namespace.deployment_namespace.id
  }

  data = var.secret_env_vars
}