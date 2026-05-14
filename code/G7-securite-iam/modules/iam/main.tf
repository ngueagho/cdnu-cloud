locals {
  prefix = "${var.project_name}-${var.environment}"
}

# ── Rôle applicatif (EC2/ECS qui fait tourner l'API) ─────────────────────────
resource "aws_iam_role" "api_app" {
  name = "${local.prefix}-role-api-app"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "api_app_s3" {
  name   = "s3-access"
  role   = aws_iam_role.api_app.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ]
      # Accès limité aux seuls buckets CDNU du projet
      Resource = concat(
        values(var.s3_bucket_arns),
        [for arn in values(var.s3_bucket_arns) : "${arn}/*"]
      )
    }]
  })
}

resource "aws_iam_role_policy" "api_app_cloudwatch" {
  name   = "cloudwatch-metrics"
  role   = aws_iam_role.api_app.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["cloudwatch:PutMetricData", "logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "api_app" {
  name = "${local.prefix}-profile-api-app"
  role = aws_iam_role.api_app.name
}

# ── Rôle CI/CD (GitHub Actions, pipeline) ────────────────────────────────────
resource "aws_iam_role" "cicd" {
  name = "${local.prefix}-role-cicd"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com" }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = { "token.actions.githubusercontent.com:sub" = "repo:*:ref:refs/heads/main" }
      }
    }]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "cicd_ecr" {
  name   = "ecr-push-pull"
  role   = aws_iam_role.cicd.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken"
      ]
      Resource = var.ecr_repository_arn != "" ? [var.ecr_repository_arn, "*"] : ["*"]
    }]
  })
}

resource "aws_iam_role_policy" "cicd_ssm" {
  name   = "ssm-deploy"
  role   = aws_iam_role.cicd.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:SendCommand", "ssm:GetCommandInvocation"]
      Resource = "*"
      Condition = {
        StringEquals = { "aws:ResourceTag/Project" = var.project_name }
      }
    }]
  })
}

# ── Rôle monitoring (Prometheus/Grafana) ─────────────────────────────────────
resource "aws_iam_role" "monitoring" {
  name = "${local.prefix}-role-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "monitoring_cloudwatch" {
  name   = "cloudwatch-read"
  role   = aws_iam_role.monitoring.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["cloudwatch:GetMetricData", "cloudwatch:ListMetrics", "logs:DescribeLogGroups", "logs:GetLogEvents"]
      Resource = "*"
    }]
  })
}
