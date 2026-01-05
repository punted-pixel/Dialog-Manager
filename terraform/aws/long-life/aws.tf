terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Change to your preferred region
  profile = "terraform"
}


resource "aws_iam_role" "apprunner_ecr_access" {
  name = "apprunner-ecr-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = "dev"
    project     = "Dialog-Manager"
  }
}

resource "aws_iam_role_policy" "apprunner_ecr_access" {
  name = "apprunner-ecr-access"
  role = aws_iam_role.apprunner_ecr_access.id

  # Minimal set commonly required for pulling from ECR
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # NOTE: GetAuthorizationToken must be Resource="*" per AWS guidance :contentReference[oaicite:1]{index=1}
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeImages",
        ]
        Resource = "arn:aws:ecr:us-east-1:148290534445:repository/dialog-system-repo"
      }
    ]
  })
}

resource "aws_apprunner_service" "dialog-manager-apprunner-service"{
  service_name = "dialog-manager-apprunner-service"
  source_configuration {

    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_ecr_access.arn
    }

    image_repository {
      image_configuration {
        port = "8080"
      } 

      image_identifier = "148290534445.dkr.ecr.us-east-1.amazonaws.com/dialog-system-repo:latest"
      image_repository_type = "ECR"

    }
    auto_deployments_enabled = true
  }

  health_check_configuration {
    protocol = "HTTP"
    path = "/health"
    interval = 10
    timeout = 5
    healthy_threshold = 1
    unhealthy_threshold = 5
  }

  tags  = {
    Name = "dialog-manager-apprunner-service"
  }
}

output "apprunner_service_arn" {
  description = "ARN of the App Runner service"
  value       = aws_apprunner_service.dialog-manager-apprunner-service.arn
}

output "apprunner_service_id" {
  description = "ID of the App Runner service"
  value       = aws_apprunner_service.dialog-manager-apprunner-service.service_id
}

output "apprunner_service_url" {
  description = "Default public URL for the App Runner service"
  value       = aws_apprunner_service.dialog-manager-apprunner-service.service_url
}

output "apprunner_service_status" {
  description = "Current service status"
  value       = aws_apprunner_service.dialog-manager-apprunner-service.status
}

output "apprunner_ecr_access_role_arn" {
  description = "IAM role App Runner assumes to pull the private ECR image"
  value       = aws_iam_role.apprunner_ecr_access.arn
}

output "apprunner_image_identifier" {
  description = "Image identifier configured for the service (useful for debugging / visibility)"
  value       = aws_apprunner_service.dialog-manager-apprunner-service.source_configuration[0].image_repository[0].image_identifier
}