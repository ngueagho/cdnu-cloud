terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Group       = "G7-securite"
    }
  }
}

module "iam" {
  source             = "./modules/iam"
  project_name       = var.project_name
  environment        = var.environment
  s3_bucket_arns     = var.s3_bucket_arns
  ecr_repository_arn = var.ecr_repository_arn
}

module "security_groups" {
  source       = "./modules/security-groups"
  for_each     = var.vpc_ids
  cdnu_name    = each.key
  vpc_id       = each.value
  project_name = var.project_name
  environment  = var.environment
}

module "tls" {
  source       = "./modules/tls"
  domain_name  = var.domain_name
  project_name = var.project_name
  environment  = var.environment
}
