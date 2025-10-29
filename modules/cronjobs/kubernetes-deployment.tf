resource "kubernetes_cron_job_v1" "cron" {
  metadata {
    name      = "${lower(var.application_name)}-cronjob"
    namespace = data.kubernetes_namespace.deployment_namespace.id

    labels = var.labels
  }

  spec {
    schedule                      = var.schedule
    timezone                      = var.timezone
    concurrency_policy            = "Forbid"
    starting_deadline_seconds     = 100
    successful_jobs_history_limit = 5
    failed_jobs_history_limit     = 1

    job_template {
      metadata {}

      spec {
        backoff_limit = 0

        template {
          metadata {}

          spec {
            service_account_name = local.enable_workload_identity ? module.deployment_workload_identity[0].k8s_service_account_name : kubernetes_service_account.basic[0].metadata[0].name

            restart_policy = "Never"

            container {
              name  = lower(var.application_name)
              image = var.container_image

              # Set the DD_AGENT_HOST environment variable to the host IP address.
              dynamic "env" {
                for_each = var.env_vars
                content {
                  name  = env.key
                  value = env.value
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
            }
          }
        }
      }
    }
  }
}