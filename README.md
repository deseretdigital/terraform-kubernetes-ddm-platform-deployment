# Kubernetes Deployment

Creates a Kubernetes Deployment, Service, Secrets Store, Service Account, and Horizontal Pod Autoscaler in a Google Kubernetes Engine cluster.

## Usage

### Basic Configuration 

```hcl
module "ddm-platform-deployment" {
  source  = "deseretdigital/ddm-platform-deployment/kubernetes"
  version = "~> 2.0.0"

  # Required
  application_name    = {YOUR_APP_NAME}
  application_version = {YOUR_APP_VERSION}
  container_image     = {CONTAINER_IMAGE}
  gke_cluster_name    = {YOUR_CLUSTER_NAME}
  project             = {YOUR_GCP_PROJECT}

  
}
```