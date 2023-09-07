resource "kubernetes_horizontal_pod_autoscaler_v2" "deployment_hpa" {
  # Only createa an autoscaler if the max_replicas is greater than the min_replicas.
  count = var.max_replicas > var.min_replicas ? 1 : 0

  metadata {
    name      = "${var.application_name}-autoscaler"
    namespace = data.kubernetes_namespace.deployment_namespace.id
    labels    = local.labels
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.platform_deployment.metadata[0].name
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    dynamic "metric" {
      for_each = var.autoscaler.cpu_utilization != null ? [var.autoscaler.cpu_utilization] : []
      content {
        type = "Resource"
        resource {
          name = "cpu"
          target {
            type                = "Utilization"
            average_utilization = metric.value
          }
        }
      }
    }

    dynamic "metric" {
      for_each = var.autoscaler.memory_utilization != null ? [var.autoscaler.memory_utilization] : []
      content {
        type = "Resource"
        resource {
          name = "memory"
          target {
            type                = "Utilization"
            average_utilization = metric.value
          }
        }
      }
    }

    # External Metric (Most common use is Google Pubsub in this case)
    # An Example metric name is: pubsub.googleapis.com|{SUBSCRIPTION_NAME}|num_undelivered_messages
    dynamic "metric" {
      for_each = var.autoscaler.external_metric != null ? [var.autoscaler.external_metric] : []
      content {
        type = "External"
        external {
          metric {
            name = metric.value.metric_name
            selector {
              match_labels = {
                for k, v in metric.value.selector_labels : k => v
              }
            }
          }
          target {
            type          = "AverageValue"
            average_value = metric.value.target_value
          }
        }
      }
    }
  }
}
