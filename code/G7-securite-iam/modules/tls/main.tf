# Certificat TLS via AWS ACM (renouvellement automatique)
resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cert"
  }
}

# Les enregistrements DNS de validation sont à créer dans Route53
# ou via le DNS de votre hébergeur — cf. aws_acm_certificate.main.domain_validation_options
output "certificate_arn" {
  value = aws_acm_certificate.main.arn
}

output "domain_validation_options" {
  description = "Enregistrements DNS à créer pour valider le certificat"
  value       = aws_acm_certificate.main.domain_validation_options
}
