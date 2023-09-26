# # Kuberenets Secrets
# 
# Each secret is a key/value pair used by the application to access secrets.
# The secrets are sourced from GitHub secrets and stored in Kubernetes secrets.
# To update a secret's value, visit the GitHub repository and navigate to: 
# Settings > Secrets and variables > Actions.
#
# Example: For APP_SECRET, the key would be "APP_SECRET", and the value would be 
# the secret within GitHub Actions.
#
# Note: We don't want to use these types of secrets in most cases. This exists 
# to handle legacy applications that are not yet ready to use Google Secret Manager

// We need to always create a secret, even if there are no secret env vars
// This is so we
resource "kubernetes_secret" "kubernetes_secrets" {
  # Create Secrets block only when we have secrets
  count = length(var.secret_env_vars) > 0 ? 1 : 0

  metadata {
    name      = "${var.application_name}-secrets"
    namespace = data.kubernetes_namespace.deployment_namespace.id
  }

  data = var.secret_env_vars
}
