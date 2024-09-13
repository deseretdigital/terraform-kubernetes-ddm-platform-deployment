terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
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
}

