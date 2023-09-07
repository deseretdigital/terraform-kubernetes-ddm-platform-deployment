
resource "kubernetes_service" "web_servce" {
  # Only expose the service as a web service if the variable is set to true.
  count = var.expose_as_web_service ? 1 : 0

  metadata {
    name      = "${var.application_name}-svc"
    namespace = data.kubernetes_namespace.deployment_namespace.id
    annotations = {
      "cloud.google.com/neg" = "{\"ingress\": true}"
    }
    labels = local.labels
  }

  spec {
    port {
      name     = "${var.application_name}-port"
      protocol = "TCP"
      # Assume all containers expose port 80 to the ingress for now.
      port        = 80
      target_port = var.container_port
    }

    selector = {
      app = var.application_name
    }

    type = var.deployment_service_type
  }
}
