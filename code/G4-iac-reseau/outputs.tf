# Outputs consommés par G5 (services managés) et G7 (sécurité/IAM)

output "vpc_ids" {
  description = "Map cdnu_name → VPC ID"
  value       = { for k, v in module.vpc : k => v.vpc_id }
}

output "vpc_cidrs" {
  description = "Map cdnu_name → CIDR du VPC"
  value       = { for k, v in var.cdnu_vpc_config : k => v.cidr }
}

output "public_subnet_ids" {
  description = "Map cdnu_name → liste des subnet IDs publics"
  value       = { for k, v in module.subnets : k => v.public_subnet_ids }
}

output "private_subnet_ids" {
  description = "Map cdnu_name → liste des subnet IDs privés (pour les apps)"
  value       = { for k, v in module.subnets : k => v.private_subnet_ids }
}

output "database_subnet_ids" {
  description = "Map cdnu_name → liste des subnet IDs pour les bases de données"
  value       = { for k, v in module.subnets : k => v.database_subnet_ids }
}

output "nat_gateway_ids" {
  description = "Map cdnu_name → NAT Gateway ID"
  value       = { for k, v in aws_nat_gateway.main : k => v.id }
}

output "transit_gateway_id" {
  description = "ID du Transit Gateway central (interconnexion 10 CDNUs)"
  value       = var.enable_transit_gateway ? module.transit_gateway[0].transit_gateway_id : null
}

output "igw_ids" {
  description = "Map cdnu_name → Internet Gateway ID"
  value       = { for k, v in module.vpc : k => v.igw_id }
}
