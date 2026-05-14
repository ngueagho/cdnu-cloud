locals {
  az_count = length(var.availability_zones)
}

# Subnets publics (ALB, NAT GW)
resource "aws_subnet" "public" {
  count = length(var.public_cidrs)

  vpc_id                  = var.vpc_id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index % local.az_count]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-subnet-pub-${var.cdnu_name}-${count.index + 1}"
    CDNU = var.cdnu_name
    Tier = "public"
  }
}

# Subnets privés applicatifs (EC2, ECS)
resource "aws_subnet" "private" {
  count = length(var.private_cidrs)

  vpc_id            = var.vpc_id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % local.az_count]

  tags = {
    Name = "${var.project_name}-${var.environment}-subnet-priv-${var.cdnu_name}-${count.index + 1}"
    CDNU = var.cdnu_name
    Tier = "private"
  }
}

# Subnets base de données (RDS — isolés, pas de route vers internet)
resource "aws_subnet" "database" {
  count = length(var.database_cidrs)

  vpc_id            = var.vpc_id
  cidr_block        = var.database_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % local.az_count]

  tags = {
    Name = "${var.project_name}-${var.environment}-subnet-db-${var.cdnu_name}-${count.index + 1}"
    CDNU = var.cdnu_name
    Tier = "database"
  }
}
