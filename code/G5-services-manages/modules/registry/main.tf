resource "aws_ecr_repository" "api" {
  name                 = "${var.project_name}-${var.environment}/api-services"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration { scan_on_push = true }

  encryption_configuration { encryption_type = "AES256" }

  tags = { Name = "${var.project_name}-${var.environment}-ecr" }
}

# Garder seulement les 10 dernières images pour maîtriser les coûts
resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Conserver les 10 dernières images taguées"
      selection = {
        tagStatus   = "tagged"
        tagPrefixList = ["v"]
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }, {
      rulePriority = 2
      description  = "Supprimer les images non taguées après 7 jours"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 7
      }
      action = { type = "expire" }
    }]
  })
}
