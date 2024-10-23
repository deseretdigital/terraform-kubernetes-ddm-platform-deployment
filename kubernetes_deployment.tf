locals {
  # Set the default values for the health check
  # We set the defaults as a local so that we can merge them with the user 
  # provided values. This allows uses to only overide the some values on 
  # the resource object. It also allows us to use the container_port, to avoid
  # setting redundant values in our code.
  liveness_probe_defaults = {
    path                  = "/livez"
    port                  = var.container_port
    initial_delay_seconds = 10
    period_seconds        = 10
    timeout_seconds       = 2
    failure_threshold     = 3
    success_threshold     = 1
  }
  # Merge Local values with user provided values
  liveness_probe = merge(local.liveness_probe_defaults, var.liveness_probe)

  readiness_probe_defaults = {
    path                  = "/readyz"
    port                  = var.container_port
    initial_delay_seconds = 10
    period_seconds        = 10
    timeout_seconds       = 2
    failure_threshold     = 3
    success_threshold     = 1
  }
  # Merge Local values with user provided values
  readiness_probe = merge(local.readiness_probe_defaults, var.readiness_probe)
}


resource "kubernetes_deployment" "platform_deployment" {
  metadata {
    name      = "${var.application_name}-deployment"
    namespace = data.kubernetes_namespace.deployment_namespace.id

    labels = var.labels
  }

  wait_for_rollout = var.wait_for_rollout

  spec {
    replicas = var.min_replicas

    selector {
      match_labels = {
        app = var.application_name
      }
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        service_account_name = module.deployment_workload_identity.k8s_service_account_name

        host_aliases {
          hostnames = ["api3.ksl.com", "cars.ksl.com"]
          ip        = "10.13.20.184"
        }

        container {
          name  = var.application_name
          image = var.container_image

          ########################################## 
          # Dynamic environment variables
          ##########################################
          dynamic "env" {
            for_each = var.env_vars
            content {
              name  = env.key
              value = env.value
            }
          }

          ########################################## 
          # Dynamic secret environment variables
          ##########################################
          dynamic "env" {
            for_each = var.secret_env_vars
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = kubernetes_secret.kubernetes_secrets[0].metadata[0].name
                  key  = env.key
                }
              }
            }
          }

          ##########################################
          # Static environment variables
          ##########################################

          # Set the DD_AGENT_HOST environment variable to the host IP address.
          env {
            name = "DD_AGENT_HOST"

            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }

          # Nodejs uses the DD_TRACE_AGENT_HOSTNAME environment variable to set 
          # the agent instead of DD_AGENT_HOST. We can set both without any negative effects.
          env {
            name = "DD_TRACE_AGENT_HOSTNAME"

            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }

          env {
            name  = "DD_SERVICE"
            value = "ddm-platform-${var.application_name}"
          }

          env {
            name  = "DD_VERSION"
            value = var.application_version
          }

          port {
            container_port = var.container_port
            protocol       = "TCP"
          }

          # Resource limits and requests for the container. This is used by
          # Kubernetes to schedule the container on a node. It is also used by
          # the Horizontal Pod Autoscaler to determine when to scale the workload.
          resources {
            limits = {
              cpu    = var.resources.limits.cpu
              memory = var.resources.limits.memory
            }

            requests = {
              cpu    = var.resources.requests.cpu
              memory = var.resources.requests.memory
            }
          }


          # Health Checks probes for the container. Currently limited to http 
          # health checks only and expects the port to be the same as the 
          # container port. This is intentional to simplify the configuration.
          liveness_probe {
            http_get {
              path = local.liveness_probe.path
              port = local.liveness_probe.port
            }

            initial_delay_seconds = local.liveness_probe.initial_delay_seconds
            period_seconds        = local.liveness_probe.period_seconds
            timeout_seconds       = local.liveness_probe.timeout_seconds
            failure_threshold     = local.liveness_probe.failure_threshold
            success_threshold     = local.liveness_probe.success_threshold
          }

          readiness_probe {
            http_get {
              path = local.readiness_probe.path
              port = local.readiness_probe.port
            }

            initial_delay_seconds = local.readiness_probe.initial_delay_seconds
            period_seconds        = local.readiness_probe.period_seconds
            timeout_seconds       = local.readiness_probe.timeout_seconds
            failure_threshold     = local.readiness_probe.failure_threshold
            success_threshold     = local.readiness_probe.success_threshold
          }
        }

      }
    }

    min_ready_seconds = 60
  }
}
