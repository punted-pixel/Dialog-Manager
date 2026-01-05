terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
provider "digitalocean" {
  token = var.do_token
}

# Variables
variable "do_token" {
  description = "DigitalOcean API Token (optional if using DIGITALOCEAN_TOKEN env var)"
  type        = string
  sensitive   = true
  default     = "andrew"
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

variable "registry_name" {
  default = "recs-registry"
  type = string
}

variable "image_name" {
  type = string
  default = "dialog-system-repo"
}

variable "image_tag" {
  type = string
  default = "latest"
}

# resource "digitalocean_container_registry" "registry"{
#   name = var.registry_name
#   subscription_tier_slug = "basic"
# }

# App Platform - references .do/app.yaml in your repo
resource "digitalocean_app" "flask_app" {
  spec {
    name   = var.app_name
    region = var.region

    service {
      name = "dialog-manager-service"
      instance_count = 1
      instance_size_slug = "apps-s-1vcpu-1gb"
      image {
        registry_type = "DOCR"
        registry = var.registry_name
        repository = var.image_name
        tag = var.image_tag
        deploy_on_push {
          enabled = true
        }
      }
    }
  }
  
}

resource "digitalocean_container_registry_docker_credentials" "app_registry_creds" {
  registry_name = var.registry_name 

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