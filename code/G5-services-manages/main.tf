terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = merge({
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Group       = "G5-services"
    }, var.tags)
  }
}

# ── S3 : 1 bucket par CDNU ───────────────────────────────────────────────────
module "storage" {
  source   = "./modules/storage"
  for_each = toset(var.cdnu_list)

  cdnu_name    = each.key
  project_name = var.project_name
  environment  = var.environment
}

# ── RDS PostgreSQL : 1 instance partagée (ou 1 par CDNU selon budget) ────────
module "database" {
  source = "./modules/database"

  project_name             = var.project_name
  environment              = var.environment
  db_subnet_ids            = var.database_subnet_ids["yaounde-1"]
  db_security_group_id     = var.db_security_group_id
  db_instance_class        = var.db_instance_class
  db_password              = var.db_password
  db_backup_retention_days = var.db_backup_retention_days
}

# ── ECR : registre de conteneurs commun ──────────────────────────────────────
module "registry" {
  source = "./modules/registry"

  project_name = var.project_name
  environment  = var.environment
}
