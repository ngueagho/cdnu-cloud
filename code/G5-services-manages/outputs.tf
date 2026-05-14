output "s3_bucket_ids" {
  description = "Map cdnu_name → S3 bucket ID"
  value       = { for k, v in module.storage : k => v.bucket_id }
}

output "s3_bucket_arns" {
  description = "Map cdnu_name → S3 bucket ARN"
  value       = { for k, v in module.storage : k => v.bucket_arn }
}

output "rds_endpoint" {
  description = "Endpoint RDS PostgreSQL (host:port)"
  value       = module.database.db_endpoint
}

output "rds_db_name" {
  value = module.database.db_name
}

output "ecr_repository_url" {
  description = "URL du registre ECR pour push/pull d'images Docker"
  value       = module.registry.repository_url
}
