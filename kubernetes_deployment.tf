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

  topology_spread_defaults = {
    max_skew           = 1
    topology_key       = "kubernetes.io/hostname"
    when_unsatisfiable = "ScheduleAnyway"
  }
  # Merge Local values with user provided values
  topology_spread = merge(local.topology_spread_defaults, var.topology_spread)
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

    # Change the strategy to RollingUpdate to avoid downtime by ensuring max_surge or min_relicas are available before killing the old ones. The defaults are 25%
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = var.max_surge
        max_unavailable = var.max_unavailable
      }
    }
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
        service_account_name = local.enable_workload_identity ? module.deployment_workload_identity[0].k8s_service_account_name : kubernetes_service_account.basic[0].metadata[0].name

        dynamic "host_aliases" {
          for_each = var.host_alias != null ? [var.host_alias] : []
          content {
            hostnames = host_aliases.value.hostnames
            ip        = host_aliases.value.ip
          }
        }

        dynamic "affinity" {
          for_each = var.node_pool != null ? [1] : []
          content {
            node_affinity {
              required_during_scheduling_ignored_during_execution {
                node_selector_term {
                  match_expressions {
                    key      = "pool"
                    operator = "In"
                    values   = [var.node_pool]
                  }
                }
              }
            }
          }
        }

        topology_spread_constraint {
          max_skew           = local.topology_spread.max_skew
          topology_key       = local.topology_spread.topology_key
          when_unsatisfiable = local.topology_spread.when_unsatisfiable
          label_selector {
            match_labels = {
              app = var.application_name
            }
          }
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

          # Observability agent host configuration (e.g., Datadog)
          dynamic "env" {
            for_each = var.observability_config != null ? var.observability_config.agent_host_env_vars : []
            content {
              name = env.value
              value_from {
                field_ref {
                  field_path = "status.hostIP"
                }
              }
            }
          }

          # Observability service name
          dynamic "env" {
            for_each = var.observability_config != null && var.observability_config.service_env_var != null ? [1] : []
            content {
              name  = var.observability_config.service_env_var
              value = var.observability_config.service_name_prefix != "" ? "${var.observability_config.service_name_prefix}${var.application_name}" : var.application_name
            }
          }

          # Observability version
          dynamic "env" {
            for_each = var.observability_config != null && var.observability_config.version_env_var != null ? [1] : []
            content {
              name  = var.observability_config.version_env_var
              value = var.application_version
            }
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
