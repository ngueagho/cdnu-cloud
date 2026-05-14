resource "aws_s3_bucket" "cdnu" {
  bucket = "${var.project_name}-${var.environment}-storage-${var.cdnu_name}"

  tags = {
    Name = "${var.project_name}-${var.environment}-storage-${var.cdnu_name}"
    CDNU = var.cdnu_name
  }
}

# Bloquer tout accès public — les données pédagogiques sont privées
resource "aws_s3_bucket_public_access_block" "cdnu" {
  bucket                  = aws_s3_bucket.cdnu.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning activé — permet restauration en cas de suppression accidentelle
resource "aws_s3_bucket_versioning" "cdnu" {
  bucket = aws_s3_bucket.cdnu.id
  versioning_configuration { status = "Enabled" }
}

# Chiffrement au repos (AES-256)
resource "aws_s3_bucket_server_side_encryption_configuration" "cdnu" {
  bucket = aws_s3_bucket.cdnu.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle : déplacer vers Infrequent Access après 90 jours, Glacier après 1 an
resource "aws_s3_bucket_lifecycle_configuration" "cdnu" {
  bucket = aws_s3_bucket.cdnu.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"
    filter { prefix = "" }

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
