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

# Compute service account name with default
locals {
  service_account_name     = var.service_account_name != null ? var.service_account_name : "${var.application_name}-sa"
  enable_workload_identity = var.project != null && var.gke_cluster_name != null
}