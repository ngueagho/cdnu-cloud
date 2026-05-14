variable "cdnu_name" {
  description = "Identifiant du CDNU (ex: yaounde-1)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block du VPC (ex: 10.1.0.0/16)"
  type        = string
}

variable "project_name" {
  description = "Préfixe du projet"
  type        = string
}

variable "environment" {
  description = "Environnement cible"
  type        = string
}
