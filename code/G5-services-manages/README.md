# G5 — Services Managés

## Objectif

Déployer via Terraform les services managés AWS : stockage S3 (1 bucket par CDNU), base de données PostgreSQL managée (RDS Multi-AZ), registre de conteneurs (ECR) et politiques de sauvegarde.

## Livrables attendus

| Livrable | Fichier | Échéance |
|----------|---------|----------|
| Module S3 (10 buckets + lifecycle) | `modules/storage/` | Fin S2 |
| Module RDS PostgreSQL Multi-AZ | `modules/database/` | Fin S3 |
| Module ECR | `modules/registry/` | Fin S3 |
| Politiques de sauvegarde | intégré dans modules | Fin S3 |
| Rapport G5 | `docs/rapport-g5.md` | Fin S4 |

## Dépendances

- **G4 → G5** : `vpc_ids`, `private_subnet_ids`, `database_subnet_ids` (remote state)
- **G7 → G5** : `db_security_group_id` pour RDS
- **G5 → G6** : Fournir `rds_endpoint`, `s3_bucket_arns`, `ecr_repository_urls`

## Démarrage

```bash
cd G5-services-manages

# Récupérer les outputs de G4 (remote state)
# Adapter le chemin dans variables.tf si nécessaire

cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Points d'attention

- Le mot de passe RDS ne doit JAMAIS être dans le code → utiliser `var.db_password` via variable ou AWS Secrets Manager
- Les buckets S3 ont le versioning activé par défaut
- Les backups RDS : rétention 7 jours minimum
