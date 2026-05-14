variable "project_name" { type = string; default = "cdnu-cloud" }
variable "environment"  { type = string; default = "prod" }
variable "aws_region"   { type = string; default = "eu-west-1" }

variable "vpc_ids" {
  description = "Map cdnu_name → VPC ID (output de G4)"
  type        = map(string)
}

variable "s3_bucket_arns" {
  description = "Map cdnu_name → ARN du bucket S3 (output de G5)"
  type        = map(string)
  default     = {}
}

variable "ecr_repository_arn" {
  description = "ARN du registre ECR (output de G5)"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Nom de domaine pour les certificats TLS (ex: cdnu.cm)"
  type        = string
  default     = "cdnu.cm"
}
