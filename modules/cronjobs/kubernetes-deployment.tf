resource "kubernetes_cron_job_v1" "cron" {
  metadata {
    name      = "${lower(var.application_name)}-cronjob"
    namespace = data.kubernetes_namespace.deployment_namespace.id

    labels = var.labels
  }

  spec {
    schedule                      = var.schedule
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
            service_account_name = module.deployment_workload_identity.k8s_service_account_name

            restart_policy = "Never"

            container {
              name    = lower(var.application_name)
              image   = var.container_image
              command = var.command

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

              # Set the DD_AGENT_HOST environment variable to the host IP address.
              env {
                name = "DD_AGENT_HOST"

                value_from {
                  field_ref {
                    field_path = "status.hostIP"
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