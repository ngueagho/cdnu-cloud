variable "project_name" {
  description = "Nom du projet — préfixe de toutes les ressources"
  type        = string
  default     = "cdnu-cloud"
}

variable "environment" {
  description = "Environnement cible (prod | staging | dev)"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["prod", "staging", "dev"], var.environment)
    error_message = "L'environnement doit être prod, staging ou dev."
  }
}

variable "aws_region" {
  description = "Région AWS principale"
  type        = string
  default     = "eu-west-1"
}

variable "cdnu_list" {
  description = "Liste des 10 CDNU — chaque entrée génère un VPC et des sous-réseaux dédiés"
  type        = list(string)
  default = [
    "yaounde-1",
    "douala-1",
    "bafoussam-1",
    "ngaoundere-1",
    "garoua-1",
    "maroua-1",
    "ebolowa-1",
    "bertoua-1",
    "limbe-1",
    "buea-1"
  ]
}

# Chaque CDNU obtient un /16 dans l'espace 10.x.0.0/16
# cdnu-yaounde-1  → 10.1.0.0/16
# cdnu-douala-1   → 10.2.0.0/16  … etc.
variable "vpc_cidr_map" {
  description = "CIDR /16 par CDNU (doit correspondre à l'ordre de cdnu_list)"
  type        = map(string)
  default = {
    "yaounde-1"    = "10.1.0.0/16"
    "douala-1"     = "10.2.0.0/16"
    "bafoussam-1"  = "10.3.0.0/16"
    "ngaoundere-1" = "10.4.0.0/16"
    "garoua-1"     = "10.5.0.0/16"
    "maroua-1"     = "10.6.0.0/16"
    "ebolowa-1"    = "10.7.0.0/16"
    "bertoua-1"    = "10.8.0.0/16"
    "limbe-1"      = "10.9.0.0/16"
    "buea-1"       = "10.10.0.0/16"
  }
}

variable "tags_common" {
  description = "Tags appliqués à toutes les ressources"
  type        = map(string)
  default = {
    Project    = "CDNU-Cloud-Cameroun"
    ManagedBy  = "Terraform"
    Owner      = "MINESUP"
    CostCenter = "CDNU-INFRA"
  }
}
