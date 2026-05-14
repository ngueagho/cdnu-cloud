locals { prefix = "${var.project_name}-${var.environment}" }

# SG Web : accepte HTTP/HTTPS depuis internet
resource "aws_security_group" "web" {
  name        = "${local.prefix}-sg-web-${var.cdnu_name}"
  description = "Trafic web public (80/443)"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP depuis internet"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS depuis internet"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${local.prefix}-sg-web-${var.cdnu_name}", CDNU = var.cdnu_name }
}

# SG App : accepte le trafic depuis le SG Web uniquement
resource "aws_security_group" "app" {
  name        = "${local.prefix}-sg-app-${var.cdnu_name}"
  description = "Application (port 8000) — accès depuis ALB uniquement"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
    description     = "API depuis ALB/SG Web"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${local.prefix}-sg-app-${var.cdnu_name}", CDNU = var.cdnu_name }
}

# SG DB : accepte PostgreSQL uniquement depuis le SG App
resource "aws_security_group" "db" {
  name        = "${local.prefix}-sg-db-${var.cdnu_name}"
  description = "PostgreSQL (5432) — accès depuis app uniquement"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
    description     = "PostgreSQL depuis SG App"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${local.prefix}-sg-db-${var.cdnu_name}", CDNU = var.cdnu_name }
}

# SG Monitoring : Prometheus (9090) + Grafana (3000) depuis le réseau interne
resource "aws_security_group" "monitoring" {
  name        = "${local.prefix}-sg-monitoring-${var.cdnu_name}"
  description = "Monitoring interne (Prometheus 9090, Grafana 3000)"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Prometheus depuis VPC interne"
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Grafana depuis VPC interne"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${local.prefix}-sg-monitoring-${var.cdnu_name}", CDNU = var.cdnu_name }
}
