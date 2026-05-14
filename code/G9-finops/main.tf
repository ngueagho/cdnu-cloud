terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Group       = "G9-finops"
    }
  }
}

# ── Budget mensuel global ─────────────────────────────────────────────────────
resource "aws_budgets_budget" "total_monthly" {
  name         = "${var.project_name}-${var.environment}-budget-total"
  budget_type  = "COST"
  limit_amount = var.monthly_budget_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.alert_emails
  }
}

# ── Budget par CDNU ───────────────────────────────────────────────────────────
resource "aws_budgets_budget" "per_cdnu" {
  for_each = toset(var.cdnu_list)

  name         = "${var.project_name}-${var.environment}-budget-${each.key}"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd / length(var.cdnu_list))
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "TagKeyValue"
    values = ["user:CDNU$${each.key}"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
  }
}

# ── AWS Config Rule : vérifier que toutes les ressources ont les tags requis ──
resource "aws_config_config_rule" "required_tags" {
  name = "${var.project_name}-${var.environment}-required-tags"

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  input_parameters = jsonencode({
    tag1Key = "Project"
    tag2Key = "Environment"
    tag3Key = "CDNU"
    tag4Key = "ManagedBy"
    tag5Key = "CostCenter"
  })
}
