variable "project_name" {
  description = "Préfixe de nommage pour toutes les ressources réseau"
  type        = string
  default     = "cdnu-cloud"
}

variable "environment" {
  description = "Environnement (prod | staging | dev)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "Région AWS de déploiement"
  type        = string
  default     = "eu-west-1"
}

variable "availability_zones" {
  description = "Zones de disponibilité à utiliser (2 minimum pour HA)"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "cdnu_vpc_config" {
  description = "Configuration réseau par CDNU"
  type = map(object({
    cidr            = string
    public_cidrs    = list(string)
    private_cidrs   = list(string)
    database_cidrs  = list(string)
  }))
  default = {
    "yaounde-1" = {
      cidr           = "10.1.0.0/16"
      public_cidrs   = ["10.1.0.0/24", "10.1.3.0/24"]
      private_cidrs  = ["10.1.1.0/24", "10.1.4.0/24"]
      database_cidrs = ["10.1.2.0/24", "10.1.5.0/24"]
    }
    "douala-1" = {
      cidr           = "10.2.0.0/16"
      public_cidrs   = ["10.2.0.0/24", "10.2.3.0/24"]
      private_cidrs  = ["10.2.1.0/24", "10.2.4.0/24"]
      database_cidrs = ["10.2.2.0/24", "10.2.5.0/24"]
    }
    "bafoussam-1" = {
      cidr           = "10.3.0.0/16"
      public_cidrs   = ["10.3.0.0/24", "10.3.3.0/24"]
      private_cidrs  = ["10.3.1.0/24", "10.3.4.0/24"]
      database_cidrs = ["10.3.2.0/24", "10.3.5.0/24"]
    }
    "ngaoundere-1" = {
      cidr           = "10.4.0.0/16"
      public_cidrs   = ["10.4.0.0/24", "10.4.3.0/24"]
      private_cidrs  = ["10.4.1.0/24", "10.4.4.0/24"]
      database_cidrs = ["10.4.2.0/24", "10.4.5.0/24"]
    }
    "garoua-1" = {
      cidr           = "10.5.0.0/16"
      public_cidrs   = ["10.5.0.0/24", "10.5.3.0/24"]
      private_cidrs  = ["10.5.1.0/24", "10.5.4.0/24"]
      database_cidrs = ["10.5.2.0/24", "10.5.5.0/24"]
    }
    "maroua-1" = {
      cidr           = "10.6.0.0/16"
      public_cidrs   = ["10.6.0.0/24", "10.6.3.0/24"]
      private_cidrs  = ["10.6.1.0/24", "10.6.4.0/24"]
      database_cidrs = ["10.6.2.0/24", "10.6.5.0/24"]
    }
    "ebolowa-1" = {
      cidr           = "10.7.0.0/16"
      public_cidrs   = ["10.7.0.0/24", "10.7.3.0/24"]
      private_cidrs  = ["10.7.1.0/24", "10.7.4.0/24"]
      database_cidrs = ["10.7.2.0/24", "10.7.5.0/24"]
    }
    "bertoua-1" = {
      cidr           = "10.8.0.0/16"
      public_cidrs   = ["10.8.0.0/24", "10.8.3.0/24"]
      private_cidrs  = ["10.8.1.0/24", "10.8.4.0/24"]
      database_cidrs = ["10.8.2.0/24", "10.8.5.0/24"]
    }
    "limbe-1" = {
      cidr           = "10.9.0.0/16"
      public_cidrs   = ["10.9.0.0/24", "10.9.3.0/24"]
      private_cidrs  = ["10.9.1.0/24", "10.9.4.0/24"]
      database_cidrs = ["10.9.2.0/24", "10.9.5.0/24"]
    }
    "buea-1" = {
      cidr           = "10.10.0.0/16"
      public_cidrs   = ["10.10.0.0/24", "10.10.3.0/24"]
      private_cidrs  = ["10.10.1.0/24", "10.10.4.0/24"]
      database_cidrs = ["10.10.2.0/24", "10.10.5.0/24"]
    }
  }
}

variable "enable_nat_gateway" {
  description = "Activer les NAT Gateways (désactiver pour économiser en dev/test)"
  type        = bool
  default     = true
}

variable "enable_transit_gateway" {
  description = "Activer le Transit Gateway pour interconnecter les 10 VPCs"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags additionnels à appliquer sur toutes les ressources"
  type        = map(string)
  default     = {}
}
