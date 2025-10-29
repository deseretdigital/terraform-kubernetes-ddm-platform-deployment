# Kubernetes Deployment Module

A flexible Terraform module for creating Kubernetes Deployments in any Kubernetes cluster, with optional GKE-specific features like Workload Identity and Network Endpoint Groups (NEG).

## Features

- **Universal Kubernetes Support**: Works with any Kubernetes cluster, not just GKE
- **Optional GCP Integration**: Enable Workload Identity and other GKE features when needed
- **Configurable Observability**: Support for any APM/observability tool (Datadog, OpenTelemetry, etc.)
- **Horizontal Pod Autoscaling**: Automatic scaling based on CPU, memory, or external metrics
- **Rolling Updates**: Zero-downtime deployments with configurable update strategies
- **Health Checks**: Configurable liveness and readiness probes
- **Topology Spread**: Distribute pods across nodes for high availability
- **Secrets Management**: Support for Kubernetes secrets and optional Google Secret Manager via Workload Identity

## Compatibility

- **Terraform**: >= 1.3
- **Kubernetes Provider**: ~> 2.35
- **Google Provider**: ~> 7.0 (optional, only needed for Workload Identity)
- **Workload Identity Module**: ~> 41.0

## Usage

### Basic Kubernetes Deployment

```hcl
module "my_app" {
  source  = "deseretdigital/ddm-platform-deployment/kubernetes"
  version = "~> 3.0"

  # Required
  application_name    = "my-application"
  application_version = "v1.2.3"
  container_image     = "gcr.io/my-project/my-app:v1.2.3"
  team                = "platform"
  
  # Optional
  container_port      = 8080
  min_replicas        = 3
  max_replicas        = 10
  
  resources = {
    requests = {
      cpu    = "100m"
      memory = "128Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "512Mi"
    }
  }
}
```

### With GKE Workload Identity

```hcl
module "my_app" {
  source  = "deseretdigital/ddm-platform-deployment/kubernetes"
  version = "~> 3.0"

  application_name    = "my-application"
  application_version = "v1.2.3"
  container_image     = "gcr.io/my-project/my-app:v1.2.3"
  team                = "platform"

  # Enable Workload Identity
  project             = "my-gcp-project"
  gke_cluster_name    = "my-cluster"
  gke_location        = "us-central1"  # Optional: specify region/zone
  roles               = [
    "roles/secretmanager.secretAccessor",
    "roles/cloudtrace.agent"
  ]
  
  # Optional: Enhanced security - don't automount token
  automount_service_account_token = false
}
```

### With Existing GCP Service Account

```hcl
module "my_app" {
  source  = "deseretdigital/ddm-platform-deployment/kubernetes"
  version = "~> 3.0"

  application_name    = "my-application"
  application_version = "v1.2.3"
  container_image     = "gcr.io/my-project/my-app:v1.2.3"
  team                = "platform"

  # Use existing GCP service account
  project                 = "my-gcp-project"
  gke_cluster_name        = "my-cluster"
  use_existing_gcp_sa     = true
  existing_gcp_sa_email   = "my-existing-sa@my-project.iam.gserviceaccount.com"
}
```

### With Datadog Observability

```hcl
module "my_app" {
  source  = "deseretdigital/ddm-platform-deployment/kubernetes"
  version = "~> 3.0"

  application_name    = "my-application"
  application_version = "v1.2.3"
  container_image     = "gcr.io/my-project/my-app:v1.2.3"
  team                = "platform"

  # Enable Datadog APM
  observability_config = {
    agent_host_env_vars = ["DD_AGENT_HOST", "DD_TRACE_AGENT_HOSTNAME"]
    service_env_var     = "DD_SERVICE"
    version_env_var     = "DD_VERSION"
    service_name_prefix = "prod-"  # Optional: prefix for service name
  }
}
```

### With GKE Ingress (NEG)

```hcl
module "my_app" {
  source  = "deseretdigital/ddm-platform-deployment/kubernetes"
  version = "~> 3.0"

  application_name    = "my-application"
  application_version = "v1.2.3"
  container_image     = "gcr.io/my-project/my-app:v1.2.3"
  team                = "platform"

  # Enable service exposure with NEG annotation for GKE
  expose_as_web_service = true
  enable_neg_annotation = true
}
```

## Cronjobs Submodule

This module also includes a submodule for creating Kubernetes CronJobs. See [modules/cronjobs/README.md](./modules/cronjobs/README.md) for details.

## Migration from v2.x

If you're upgrading from version 2.x, please see [MIGRATION.md](./MIGRATION.md) for a detailed migration guide.

### Key Breaking Changes

1. **Observability**: Datadog environment variables are no longer injected by default
2. **Node Pool**: Default changed from `"standard4"` to `null` (no affinity)
3. **IAM Roles**: Default changed from `["roles/secretmanager.secretAccessor"]` to `[]`
4. **Workload Identity**: Now optional (project and gke_cluster_name can be null)
5. **NEG Annotation**: Now opt-in via `enable_neg_annotation` variable

## Design Principles

### Universal Design
This module is designed to work with any Kubernetes cluster, not just GKE. GCP-specific features are optional and only activated when the necessary variables are provided.

### Sensible Defaults
The module provides sensible defaults that work for most applications while remaining flexible for advanced use cases.

### No Vendor Lock-in
Observability and other tool integrations are configurable, not hardcoded. You can use Datadog, OpenTelemetry, or any other APM tool.

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to the repository.

## License

Apache 2.0 Licensed. See LICENSE for full details.

## Authors

Maintained by the Deseret Digital Media Platform Team.
