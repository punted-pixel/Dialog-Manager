terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Variables
variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository (format: owner/repo)"
  type        = string
  default     = "punted-pixel/Dialog-Manager"
}

variable "github_branch" {
  description = "GitHub branch to deploy"
  type        = string
  default     = "main"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "flask-app"
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc"
}


# App Platform - references .do/app.yaml in your repo
resource "digitalocean_app" "flask_app" {
  spec {
    name   = var.app_name
    region = var.region

    # Use the app.yaml from your repository
    # DigitalOcean will look for .do/app.yaml or app.yaml in repo root
    
    # You only need to specify the GitHub source here
    # All other config comes from app.yaml in your repo
  }
  
  # Alternative: if you want to provide the spec directly from a file
  # Uncomment this and comment out the spec block above:
  # spec = file("${path.module}/app.yaml")
}

# Outputs
output "app_live_url" {
  description = "Live URL of the deployed app"
  value       = "https://${digitalocean_app.flask_app.default_ingress}"
}

output "app_id" {
  description = "App Platform app ID"
  value       = digitalocean_app.flask_app.id
}