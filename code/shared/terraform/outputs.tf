# Ce fichier sera enrichi par G4, G5, G7 au fur et à mesure
# Les outputs partagés permettent aux groupes de référencer
# les ressources des autres sans dupliquer le code.

output "cdnu_list" {
  description = "Liste canonique des 10 CDNUs"
  value       = var.cdnu_list
}

output "project_prefix" {
  description = "Préfixe de nommage commun"
  value       = local.prefix
}
