output "vpc_id" {
  description = "ID du VPC créé pour ce CDNU"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block du VPC"
  value       = aws_vpc.main.cidr_block
}

output "igw_id" {
  description = "ID de l'Internet Gateway"
  value       = aws_internet_gateway.main.id
}
