terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider par défaut — région principale
provider "aws" {
  region = var.aws_region

  # Pour LocalStack : décommenter et définir AWS_ENDPOINT_URL=http://localhost:4566
  # endpoints {
  #   ec2            = "http://localhost:4566"
  #   s3             = "http://localhost:4566"
  #   rds            = "http://localhost:4566"
  #   iam            = "http://localhost:4566"
  #   sts            = "http://localhost:4566"
  # }

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "Terraform"
      Env       = var.environment
    }
  }
}
