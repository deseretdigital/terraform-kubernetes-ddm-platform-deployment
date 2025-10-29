# Migration Guide

This guide outlines the breaking changes and migration path when upgrading to version 3.0.0 of this module.

## Summary of Changes

### Provider Updates
- **Kubernetes provider**: Updated from `~> 2.0` to `~> 2.35`
- **Google provider**: Updated from `~> 6.0` to `~> 7.0` (major version upgrade)
- **Workload Identity module**: Updated from unversioned to `~> 41.0`
- **Terraform version**: Now requires `>= 1.3`

### Google Provider v7 Breaking Changes

The Google provider v7 includes several breaking changes. However, since this module only uses the workload-identity submodule (not direct Google resources), **no code changes are required**. The module is fully compatible with Google provider v7.

**Key improvements in v7:**
- Better resource handling and state management
- Improved error messages and validation
- Performance optimizations
- Updated default values for various resources

### Google Provider v7 Breaking Changes

The Google provider v7 includes several breaking changes. However, since this module only uses the workload-identity submodule (not direct Google resources), **no code changes are required**. The module is fully compatible with Google provider v7.

**Key improvements in v7:**
- Better resource handling and state management
- Improved error messages and validation
- Performance optimizations
- Updated default values for various resources

**Upgrade Steps for v7:**
1. Update your root module's Google provider constraint to `~> 7.0`
2. Run `terraform init -upgrade`
3. Review the plan - should show no changes for this module
4. Apply as normal

**If you use direct Google resources elsewhere:**
Review the [Google provider v7 upgrade guide](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/version_7_upgrade) for breaking changes that may affect other parts of your infrastructure.

### Breaking Changes

#### 1. Observability Configuration (Datadog/APM)

**Before:**
Datadog environment variables were automatically injected with hardcoded values:
- `DD_AGENT_HOST` and `DD_TRACE_AGENT_HOSTNAME` always set to host IP
- `DD_SERVICE` always set to `ddm-platform-{application_name}`
- `DD_VERSION` always set to application version

**After:**
Observability configuration is now opt-in via the `observability_config` variable:

```hcl
# To maintain previous behavior (for Datadog users)
observability_config = {
  agent_host_env_vars = ["DD_AGENT_HOST", "DD_TRACE_AGENT_HOSTNAME"]
  service_name_prefix = "ddm-platform-"
  service_env_var     = "DD_SERVICE"
  version_env_var     = "DD_VERSION"
}

# To disable (default)
observability_config = null
```

#### 2. Node Pool Affinity

**Before:**
Node pool was hardcoded to `standard4`:
```hcl
variable "node_pool" {
  default = "standard4"
}
```

**After:**
Node pool affinity is optional (default: `null`):
```hcl
variable "node_pool" {
  default = null  # No node affinity by default
}

# To specify a node pool
node_pool = "standard4"
```

#### 3. GCP Workload Identity

**Before:**
The following variables were required:
- `project`
- `gke_cluster_name`
- `service_account_name`
- `roles` (defaulted to `["roles/secretmanager.secretAccessor"]`)

**After:**
These variables are now optional. Workload identity is only enabled when both `project` and `gke_cluster_name` are provided:

```hcl
# Without workload identity (creates basic K8s service account)
# Don't provide project and gke_cluster_name

# With workload identity
project          = "my-gcp-project"
gke_cluster_name = "my-cluster"
service_account_name = "my-sa"  # Optional, defaults to "{application_name}-sa"
roles            = ["roles/secretmanager.secretAccessor"]  # Optional, defaults to []
```

#### 4. IAM Roles Default

**Before:**
```hcl
variable "roles" {
  default = ["roles/secretmanager.secretAccessor"]
}
```

**After:**
```hcl
variable "roles" {
  default = []  # No default roles
}
```

**Migration:** Explicitly set `roles = ["roles/secretmanager.secretAccessor"]` if you were relying on this default.

#### 5. Google Cloud NEG Annotation

**Before:**
NEG (Network Endpoint Group) annotation was always added to services:
```hcl
annotations = {
  "cloud.google.com/neg" = "{\"ingress\": true}"
}
```

**After:**
NEG annotation is now opt-in:
```hcl
enable_neg_annotation = true  # Default: false
```

#### 6. Topology Spread Constraint Label Selector

**Fixed Bug:**
The label selector in topology spread constraint was using a quoted variable reference which would not work correctly:
```hcl
# Before (incorrect)
match_labels = {
  "app.kubernetes.io/instance" = "var.application_name"
}

# After (fixed)
match_labels = {
  app = var.application_name
}
```

#### 7. Host Aliases

**Before:**
Host aliases block was always present, which would cause errors if `host_alias` was `null`.

**After:**
Host aliases block is now dynamically created only when configured:
```hcl
# No need to provide host_alias if not needed (default: null)

# Or explicitly provide it
host_alias = {
  hostnames = ["example.com"]
  ip        = "192.168.1.1"
}
```

## Migration Steps

### For Existing Deployments with Default Behavior

If you were using the module with mostly default values:

```hcl
# Before (v2.x)
module "deployment" {
  source = "..."
  
  application_name    = "myapp"
  application_version = "1.0.0"
  container_image     = "gcr.io/project/image:tag"
  gke_cluster_name    = "my-cluster"
  project             = "my-project"
  service_account_name = "myapp-sa"
  team                = "platform"
}

# After (v3.x) - to maintain similar behavior
module "deployment" {
  source = "..."
  
  application_name    = "myapp"
  application_version = "1.0.0"
  container_image     = "gcr.io/project/image:tag"
  gke_cluster_name    = "my-cluster"
  project             = "my-project"
  service_account_name = "myapp-sa"
  team                = "platform"
  
  # Add these to maintain v2.x behavior
  node_pool = "standard4"
  roles     = ["roles/secretmanager.secretAccessor"]
  
  observability_config = {
    agent_host_env_vars = ["DD_AGENT_HOST", "DD_TRACE_AGENT_HOSTNAME"]
    service_name_prefix = "ddm-platform-"
    service_env_var     = "DD_SERVICE"
    version_env_var     = "DD_VERSION"
  }
  
  enable_neg_annotation = true
}
```

### For New Deployments (Recommended Configuration)

```hcl
module "deployment" {
  source = "..."
  
  # Required
  application_name    = "myapp"
  application_version = "1.0.0"
  container_image     = "gcr.io/project/image:tag"
  team                = "platform"
  
  # Optional: Enable workload identity
  project             = "my-project"
  gke_cluster_name    = "my-cluster"
  roles               = ["roles/secretmanager.secretAccessor"]
  
  # Optional: Add node affinity
  node_pool = "standard4"
  
  # Optional: Enable observability (customize for your APM tool)
  observability_config = {
    agent_host_env_vars = ["DD_AGENT_HOST"]  # Or your APM agent env var
    service_env_var     = "DD_SERVICE"       # Or your service name env var
    version_env_var     = "DD_VERSION"       # Or your version env var
  }
  
  # Optional: Enable NEG for GKE ingress
  enable_neg_annotation = true
}
```

## New Features

### 1. Universal Observability Support

The module now supports any APM/observability tool, not just Datadog:

```hcl
# For Datadog
observability_config = {
  agent_host_env_vars = ["DD_AGENT_HOST", "DD_TRACE_AGENT_HOSTNAME"]
  service_env_var     = "DD_SERVICE"
  version_env_var     = "DD_VERSION"
}

# For another APM tool
observability_config = {
  agent_host_env_vars = ["OTEL_AGENT_HOST"]
  service_env_var     = "OTEL_SERVICE_NAME"
  version_env_var     = "OTEL_SERVICE_VERSION"
}

# Disable observability injection
observability_config = null
```

### 2. Kubernetes-Only Mode

You can now use this module without GCP workload identity:

```hcl
module "deployment" {
  source = "..."
  
  application_name    = "myapp"
  application_version = "1.0.0"
  container_image     = "gcr.io/project/image:tag"
  team                = "platform"
  
  # No project or gke_cluster_name needed
  # Uses basic Kubernetes service account
}
```

### 3. Flexible Service Account Naming

The `service_account_name` now has a computed default:

```hcl
# Automatically becomes "myapp-sa"
service_account_name = null  # or omit

# Or specify custom name
service_account_name = "custom-sa-name"
```

### 4. Enhanced GCP Workload Identity

New features for better GCP integration:

```hcl
# Use existing GCP service account
module "deployment" {
  source = "..."
  
  project                 = "my-project"
  gke_cluster_name        = "my-cluster"
  use_existing_gcp_sa     = true
  existing_gcp_sa_email   = "existing-sa@project.iam.gserviceaccount.com"
}

# Enhanced security - don't automount service account token
module "deployment" {
  source = "..."
  
  automount_service_account_token = false
}

# Regional/zonal cluster support
module "deployment" {
  source = "..."
  
  gke_location = "us-central1"  # Specify region or zone
}
```

**Benefits:**
- Reuse existing service accounts with pre-configured permissions
- Better security with optional token mounting
- Proper support for regional and zonal GKE clusters
- More efficient permission management

## Checklist

- [ ] Update provider version constraints in your root module
- [ ] Review and update `observability_config` if using Datadog or other APM
- [ ] Explicitly set `node_pool` if you need node affinity
- [ ] Explicitly set `roles` if using Secret Manager
- [ ] Set `enable_neg_annotation = true` if using GKE Ingress
- [ ] Remove `host_alias` if set to a default empty value
- [ ] Run `terraform plan` to review changes
- [ ] Test in a non-production environment first

## Support

For questions or issues with the migration, please open an issue in the repository.
