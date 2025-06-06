variable "application_name" {
  description = "The name of the deployment"
  type        = string
}

variable "expose_as_web_service" {
  description = "Indicates if the deployment should be exposed as a web service"
  type        = bool
  default     = true
}

variable "application_version" {
  description = "The version of the deployment. Ideally this is an Autotagged Semver, but we could use the Github run id."
  type        = string
}

variable "container_image" {
  description = "The container image to deploy"
  type        = string
}

variable "container_port" {
  description = "The port the container exposes"
  type        = number
  default     = 8080
}

variable "host_alias" {
  description = "The host aliases to apply to the deployment"
  type = object({
    hostnames = list(string)
    ip        = string
  })
  default = null
}

variable "labels" {
  description = "The labels to apply to the deployment"
  type        = map(string)
  default     = {}
}

variable "namespace" {
  description = "The Kubernetes namespace where the deployment will be created"
  type        = string
  default     = "internal"
}

variable "team" {
  description = "The team that owns the deployment"
  type        = string
}

variable "wait_for_rollout" {
  description = "Wait for the rollout of the deployment to complete."
  type        = bool
  default     = true
}


variable "liveness_probe" {
  description = "Configuration for liveness probe"
  type = object({
    path                  = optional(string)
    port                  = optional(number)
    initial_delay_seconds = optional(number)
    period_seconds        = optional(number)
    timeout_seconds       = optional(number)
    failure_threshold     = optional(number)
    success_threshold     = optional(number)
  })
  default = {
    path                  = "/livez"
    port                  = 8080 # Added this default
    initial_delay_seconds = 10
    period_seconds        = 10
    timeout_seconds       = 2
    failure_threshold     = 3
    success_threshold     = 1
  }
}

variable "readiness_probe" {
  description = "Configuration for readiness probe"
  type = object({
    path                  = optional(string)
    port                  = optional(number)
    initial_delay_seconds = optional(number)
    period_seconds        = optional(number)
    timeout_seconds       = optional(number)
    failure_threshold     = optional(number)
    success_threshold     = optional(number)
  })
  default = {
    path                  = "/readyz"
    port                  = 8080 # Added this default
    initial_delay_seconds = 10
    period_seconds        = 10
    timeout_seconds       = 2
    failure_threshold     = 3
    success_threshold     = 1
  }
}

variable "topology_spread" {
  description = "Configuration for topology spread"
  type = object({
    max_skew           = optional(number)
    topology_key       = optional(string)
    when_unsatisfiable = optional(string)
  })
  default = {
    max_skew           = 1
    topology_key       = "kubernetes.io/hostname"
    when_unsatisfiable = "ScheduleAnyway"
  }
}


variable "resources" {
  description = "Resource requests and limits"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      memory = "64Mi"
      cpu    = "250m"
    }
    limits = {
      memory = "128Mi"
      cpu    = "500m"
    }
  }
}

variable "env_vars" {
  description = "List of environment variables for the deployment"
  type        = map(any)
  default     = {}
}

variable "secret_env_vars" {
  description = "List of environment that are set as secret variables for the deployment. These are stored in K8s and not in GSM"
  type        = map(any)
  default     = {}
}

variable "min_replicas" {
  description = "Minimum number of replicas for the deployment"
  type        = number
  default     = 3
}

variable "max_replicas" {
  description = "Maximum number of replicas for the deployment"
  type        = number
  default     = 5
}

variable "max_surge" {
  description = "Maximum number of pods that can be scheduled above the desired number of pods."
  type        = string
  default     = "25%"
}

variable "max_unavailable" {
  description = "Maximum number of pods that can be unavailable during the update"
  type        = string
  default     = "25%"
}

variable "autoscaler" {
  description = "Configuration for the autoscaler"
  type = object({
    cpu_utilization    = optional(number)
    memory_utilization = optional(number)
    # External Metrics. Example: Google Pubsub
    external_metric = optional(object({
      metric_name     = string
      target_value    = string
      selector_labels = optional(map(string))
    }))
  })
  default = {
    cpu_utilization = 80 # This implies 80%
  }
}

variable "deployment_service_type" {
  description = "The type of service to create for the deployment"
  type        = string
  default     = "ClusterIP"
}

variable "roles" {
  description = "The roles to apply to the service account for the deployment"
  type        = list(string)
  default     = ["roles/secretmanager.secretAccessor"]
}

variable "project" {
  description = "The default project."
  type        = string
}

variable "gke_cluster_name" {
  description = "The name of the GKE cluster where the resources will be deployed"
  type        = string
}

variable "service_account_name" {
  description = "The name of the service account to use for the deployment"
  type        = string
}

variable "node_pool" {
  description = "The pool name the workload will run on."
  type        = string
  default     = "standard4"
}
