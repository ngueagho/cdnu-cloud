output "iam_role_api_app_arn" {
  description = "ARN du rôle IAM pour l'application API (G6)"
  value       = module.iam.role_api_app_arn
}

output "iam_role_cicd_arn" {
  description = "ARN du rôle IAM pour le pipeline CI/CD (G6)"
  value       = module.iam.role_cicd_arn
}

output "security_group_web_ids" {
  description = "Map cdnu_name → SG ID pour le trafic web (80/443)"
  value       = { for k, v in module.security_groups : k => v.sg_web_id }
}

output "security_group_app_ids" {
  description = "Map cdnu_name → SG ID pour l'application (8000)"
  value       = { for k, v in module.security_groups : k => v.sg_app_id }
}

output "security_group_db_ids" {
  description = "Map cdnu_name → SG ID pour la base de données (5432)"
  value       = { for k, v in module.security_groups : k => v.sg_db_id }
}

output "acm_certificate_arn" {
  description = "ARN du certificat TLS pour le domaine cdnu.cm"
  value       = module.tls.certificate_arn
}
