locals {
  # Préfixe standard pour nommer toutes les ressources
  prefix = "${var.project_name}-${var.environment}"

  # Tags obligatoires à merger sur chaque ressource
  common_tags = merge(var.tags_common, {
    Environment = var.environment
    Project     = var.project_name
  })

  # Map cdnu_name → index (utile pour les CIDRs)
  cdnu_index_map = { for idx, name in var.cdnu_list : name => idx + 1 }
}
