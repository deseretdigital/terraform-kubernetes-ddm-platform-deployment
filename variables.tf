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

variable "team" {
  description = "The team that owns the deployment"
  type        = string
}

variable "labels" {
  description = "The labels to apply to the deployment"
  type        = map(string)
}

variable "namespace" {
  description = "The Kubernetes namespace where the deployment will be created"
  type        = string
  default     = "internal"
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
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secret_env_vars" {
  description = "List of environment that are set as secret variables for the deployment. These are stored in K8s and not in GSM"
  type = list(object({
    name  = string
    value = string
  }))
  default   = []
  sensitive = true
}

variable "min_replicas" {
  description = "Minimum number of replicas for the deployment"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of replicas for the deployment"
  type        = number
  default     = 1
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
