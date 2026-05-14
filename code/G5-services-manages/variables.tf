variable "project_name" { type = string; default = "cdnu-cloud" }
variable "environment"  { type = string; default = "prod" }
variable "aws_region"   { type = string; default = "eu-west-1" }

variable "cdnu_list" {
  type    = list(string)
  default = ["yaounde-1","douala-1","bafoussam-1","ngaoundere-1","garoua-1","maroua-1","ebolowa-1","bertoua-1","limbe-1","buea-1"]
}

# Récupérés depuis les outputs de G4 (remote state ou variables directes)
variable "vpc_ids" {
  description = "Map cdnu_name → VPC ID (output de G4)"
  type        = map(string)
}

variable "database_subnet_ids" {
  description = "Map cdnu_name → liste subnet IDs DB (output de G4)"
  type        = map(list(string))
}

variable "private_subnet_ids" {
  description = "Map cdnu_name → liste subnet IDs privés (output de G4)"
  type        = map(list(string))
}

variable "db_security_group_id" {
  description = "Security group ID pour RDS (fourni par G7)"
  type        = string
}

variable "db_instance_class" {
  description = "Classe d'instance RDS"
  type        = string
  default     = "db.t3.medium"
}

variable "db_password" {
  description = "Mot de passe master RDS — NE PAS committer, passer via env TF_VAR_db_password"
  type        = string
  sensitive   = true
}

variable "db_backup_retention_days" {
  type    = number
  default = 7
}

variable "tags" {
  type    = map(string)
  default = {}
}
