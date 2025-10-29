terraform {
  required_version = ">= 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

# Merge labels from the user with the labels we need to apply to the deployment
locals {
  labels = merge(
    {
      app  = var.application_name
      team = var.team
    },
    var.labels
  )

  # Compute service account name with default
  service_account_name = var.service_account_name != null ? var.service_account_name : "${var.application_name}-sa"

  # Determine if workload identity should be enabled
  enable_workload_identity = var.project != null && var.gke_cluster_name != null
}

