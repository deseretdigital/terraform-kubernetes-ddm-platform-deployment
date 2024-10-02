## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.32.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.32.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_deployment_workload_identity"></a> [deployment\_workload\_identity](#module\_deployment\_workload\_identity) | terraform-google-modules/kubernetes-engine/google//modules/workload-identity | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_deployment.platform_deployment](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_horizontal_pod_autoscaler_v2.deployment_hpa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/horizontal_pod_autoscaler_v2) | resource |
| [kubernetes_secret.kubernetes_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.web_servce](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_namespace.deployment_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/namespace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of the deployment | `string` | n/a | yes |
| <a name="input_application_version"></a> [application\_version](#input\_application\_version) | The version of the deployment. Ideally this is an Autotagged Semver, but we could use the Github run id. | `string` | n/a | yes |
| <a name="input_autoscaler"></a> [autoscaler](#input\_autoscaler) | Configuration for the autoscaler | <pre>object({<br>    cpu_utilization    = optional(number)<br>    memory_utilization = optional(number)<br>    # External Metrics. Example: Google Pubsub<br>    external_metric = optional(object({<br>      metric_name     = string<br>      target_value    = string<br>      selector_labels = optional(map(string))<br>    }))<br>  })</pre> | <pre>{<br>  "cpu_utilization": 80<br>}</pre> | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | The container image to deploy | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The port the container exposes | `number` | `8080` | no |
| <a name="input_deployment_service_type"></a> [deployment\_service\_type](#input\_deployment\_service\_type) | The type of service to create for the deployment | `string` | `"ClusterIP"` | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | List of environment variables for the deployment | `map(any)` | `{}` | no |
| <a name="input_expose_as_web_service"></a> [expose\_as\_web\_service](#input\_expose\_as\_web\_service) | Indicates if the deployment should be exposed as a web service | `bool` | `true` | no |
| <a name="input_gke_cluster_name"></a> [gke\_cluster\_name](#input\_gke\_cluster\_name) | The name of the GKE cluster where the resources will be deployed | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | The labels to apply to the deployment | `map(string)` | n/a | yes |
| <a name="input_liveness_probe"></a> [liveness\_probe](#input\_liveness\_probe) | Configuration for liveness probe | <pre>object({<br>    path                  = optional(string)<br>    port                  = optional(number)<br>    initial_delay_seconds = optional(number)<br>    period_seconds        = optional(number)<br>    timeout_seconds       = optional(number)<br>    failure_threshold     = optional(number)<br>    success_threshold     = optional(number)<br>  })</pre> | <pre>{<br>  "failure_threshold": 3,<br>  "initial_delay_seconds": 10,<br>  "path": "/livez",<br>  "period_seconds": 10,<br>  "port": 8080,<br>  "success_threshold": 1,<br>  "timeout_seconds": 2<br>}</pre> | no |
| <a name="input_max_replicas"></a> [max\_replicas](#input\_max\_replicas) | Maximum number of replicas for the deployment | `number` | `5` | no |
| <a name="input_min_replicas"></a> [min\_replicas](#input\_min\_replicas) | Minimum number of replicas for the deployment | `number` | `3` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The Kubernetes namespace where the deployment will be created | `string` | `"internal"` | no |
| <a name="input_project"></a> [project](#input\_project) | The default project. | `string` | n/a | yes |
| <a name="input_readiness_probe"></a> [readiness\_probe](#input\_readiness\_probe) | Configuration for readiness probe | <pre>object({<br>    path                  = optional(string)<br>    port                  = optional(number)<br>    initial_delay_seconds = optional(number)<br>    period_seconds        = optional(number)<br>    timeout_seconds       = optional(number)<br>    failure_threshold     = optional(number)<br>    success_threshold     = optional(number)<br>  })</pre> | <pre>{<br>  "failure_threshold": 3,<br>  "initial_delay_seconds": 10,<br>  "path": "/readyz",<br>  "period_seconds": 10,<br>  "port": 8080,<br>  "success_threshold": 1,<br>  "timeout_seconds": 2<br>}</pre> | no |
| <a name="input_resources"></a> [resources](#input\_resources) | Resource requests and limits | <pre>object({<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | <pre>{<br>  "limits": {<br>    "cpu": "500m",<br>    "memory": "128Mi"<br>  },<br>  "requests": {<br>    "cpu": "250m",<br>    "memory": "64Mi"<br>  }<br>}</pre> | no |
| <a name="input_roles"></a> [roles](#input\_roles) | The roles to apply to the service account for the deployment | `list(string)` | <pre>[<br>  "roles/secretmanager.secretAccessor"<br>]</pre> | no |
| <a name="input_secret_env_vars"></a> [secret\_env\_vars](#input\_secret\_env\_vars) | List of environment that are set as secret variables for the deployment. These are stored in K8s and not in GSM | `map(any)` | `{}` | no |
| <a name="input_team"></a> [team](#input\_team) | The team that owns the deployment | `string` | n/a | yes |
| <a name="input_wait_for_rollout"></a> [wait\_for\_rollout](#input\_wait\_for\_rollout) | Wait for the rollout of the deployment to complete. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | The name of the deployment |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | The name of the service account |