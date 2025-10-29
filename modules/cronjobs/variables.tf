variable "application_name" {
  description = "The name of the deployment"
  type        = string
}

variable "application_version" {
  description = "The version of the deployment. Ideally this is an Autotagged Semver, but we could use the Github run id."
  type        = string
}

variable "container_image" {
  description = "The container image to deploy"
  type        = string
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
  description = "The IAM roles to apply to the service account for the deployment. Only used when workload identity is enabled."
  type        = list(string)
  default     = []
}

variable "project" {
  description = "The GCP project ID. Required when using workload identity."
  type        = string
  default     = null
}

variable "gke_cluster_name" {
  description = "The name of the GKE cluster. Required when using workload identity."
  type        = string
  default     = null
}

variable "service_account_name" {
  description = "The name of the service account to use for workload identity. If not provided, defaults to '{application_name}-sa'."
  type        = string
  default     = null
}

variable "schedule" {
  description = "The schedule for the cronjob"
  type        = string
}

variable "timezone" {
  type    = string
  default = "UTC"
}

variable "observability_config" {
  description = "Configuration for observability integrations (e.g., Datadog). Set to null to disable."
  type = object({
    agent_host_env_vars = optional(list(string), ["DD_AGENT_HOST", "DD_TRACE_AGENT_HOSTNAME"])
    service_name_prefix = optional(string, "")
    service_env_var     = optional(string, "DD_SERVICE")
    version_env_var     = optional(string, "DD_VERSION")
  })
  default = null
}

variable "gcp_service_account_description" {
  description = "Description for the GCP service account created by workload identity"
  type        = string
  default     = null
}

variable "automount_service_account_token" {
  description = "Whether to automount the service account token in pods. Set to false for enhanced security when using workload identity."
  type        = bool
  default     = true
}

variable "use_existing_gcp_sa" {
  description = "Use an existing GCP service account instead of creating a new one. Provide the email in 'existing_gcp_sa_email'."
  type        = bool
  default     = false
}

variable "existing_gcp_sa_email" {
  description = "Email of existing GCP service account to use with workload identity (when use_existing_gcp_sa is true)"
  type        = string
  default     = null
}

variable "gke_location" {
  description = "The location (region or zone) of the GKE cluster. Used for regional/zonal workload identity configuration."
  type        = string
  default     = null
}
