terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = merge({
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Group       = "G4-reseau"
    }, var.tags)
  }
}

# ── VPC par CDNU ──────────────────────────────────────────────────────────────
module "vpc" {
  source   = "./modules/vpc"
  for_each = var.cdnu_vpc_config

  cdnu_name    = each.key
  vpc_cidr     = each.value.cidr
  project_name = var.project_name
  environment  = var.environment
}

# ── Subnets par CDNU ──────────────────────────────────────────────────────────
module "subnets" {
  source   = "./modules/subnets"
  for_each = var.cdnu_vpc_config

  cdnu_name          = each.key
  vpc_id             = module.vpc[each.key].vpc_id
  public_cidrs       = each.value.public_cidrs
  private_cidrs      = each.value.private_cidrs
  database_cidrs     = each.value.database_cidrs
  availability_zones = var.availability_zones
  project_name       = var.project_name
  environment        = var.environment
}

# ── Transit Gateway (interconnexion des 10 VPCs) ──────────────────────────────
module "transit_gateway" {
  source = "./modules/transit-gateway"
  count  = var.enable_transit_gateway ? 1 : 0

  project_name = var.project_name
  environment  = var.environment
  vpc_ids      = { for k, v in module.vpc : k => v.vpc_id }
  # Subnets privés de chaque CDNU attachés au TGW
  private_subnet_ids = { for k, v in module.subnets : k => v.private_subnet_ids }
  vpc_cidrs          = { for k, v in var.cdnu_vpc_config : k => v.cidr }
}

# ── NAT Gateway (un par CDNU, dans le subnet public AZ-a) ────────────────────
resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? var.cdnu_vpc_config : {}
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-eip-nat-${each.key}"
    CDNU = each.key
  }
}

resource "aws_nat_gateway" "main" {
  for_each = var.enable_nat_gateway ? var.cdnu_vpc_config : {}

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = module.subnets[each.key].public_subnet_ids[0]

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-${each.key}"
    CDNU = each.key
  }

  depends_on = [module.subnets]
}

# ── Route Tables ──────────────────────────────────────────────────────────────

# Table de routage publique (0.0.0.0/0 → IGW)
resource "aws_route_table" "public" {
  for_each = var.cdnu_vpc_config
  vpc_id   = module.vpc[each.key].vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc[each.key].igw_id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rt-public-${each.key}"
    CDNU = each.key
  }
}

resource "aws_route_table_association" "public" {
  for_each = {
    for pair in flatten([
      for cdnu, v in var.cdnu_vpc_config : [
        for idx, subnet_id in module.subnets[cdnu].public_subnet_ids : {
          key       = "${cdnu}-${idx}"
          cdnu      = cdnu
          subnet_id = subnet_id
        }
      ]
    ]) : pair.key => pair
  }

  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.public[each.value.cdnu].id
}

# Table de routage privée (0.0.0.0/0 → NAT Gateway)
resource "aws_route_table" "private" {
  for_each = var.cdnu_vpc_config
  vpc_id   = module.vpc[each.key].vpc_id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[each.key].id
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rt-private-${each.key}"
    CDNU = each.key
  }
}
