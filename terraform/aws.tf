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
}

# IAM role for App Runner service
resource "aws_iam_role" "apprunner_service_role" {
  name = "apprunner-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

# IAM role for App Runner instance (runtime)
resource "aws_iam_role" "apprunner_instance_role" {
  name = "apprunner-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

# GitHub connection for App Runner
resource "aws_apprunner_connection" "github" {
  connection_name = "github-connection"
  provider_type   = "GITHUB"
}

# App Runner service
resource "aws_apprunner_service" "flask_app" {
  service_name = "flask-app"

  source_configuration {
    authentication_configuration {
      connection_arn = aws_apprunner_connection.github.arn
    }

    code_repository {
      repository_url = "https://github.com/your-username/your-repo"  # Update this

      source_code_version {
        type  = "BRANCH"
        value = "main"  # or your default branch
      }

      code_configuration {
        configuration_source = "API"
        
        code_configuration_values {
          runtime              = "PYTHON_3"
          build_command        = "pip install -r requirements.txt"
          start_command        = "python app.py"
          port                 = "8080"
          runtime_environment_variables = {
            # Add your environment variables here
            # FLASK_ENV = "production"
          }
        }
      }
    }

    auto_deployments_enabled = true
  }

  instance_configuration {
    cpu    = "1024"  # 1 vCPU
    memory = "2048"  # 2 GB
    instance_role_arn = aws_iam_role.apprunner_instance_role.arn
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = "/"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 1
    unhealthy_threshold = 5
  }

  tags = {
    Name        = "flask-app"
    Environment = "production"
  }
}

output "service_url" {
  value       = aws_apprunner_service.flask_app.service_url
  description = "The URL of the App Runner service"
}

output "service_arn" {
  value       = aws_apprunner_service.flask_app.arn
  description = "The ARN of the App Runner service"
}

output "github_connection_arn" {
  value       = aws_apprunner_connection.github.arn
  description = "GitHub connection ARN - complete authentication via AWS Console"
}