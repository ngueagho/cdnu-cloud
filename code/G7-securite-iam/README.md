# G7 — Sécurité & IAM

## Objectif

Mettre en place la couche de sécurité complète : rôles IAM au moindre privilège, Security Groups, WAF et chiffrement TLS pour tous les services exposés.

## Livrables attendus

| Livrable | Fichier | Échéance |
|----------|---------|----------|
| Rôles IAM (moindre privilège) | `modules/iam/` | Fin S2 |
| Security Groups | `modules/security-groups/` | Fin S3 |
| Certificats TLS (ACM) | `modules/tls/` | Fin S3 |
| WAF rules | intégré dans `main.tf` | Fin S4 |
| Rapport G7 | `docs/rapport-g7.md` | Fin S4 |

## Dépendances

- **G4 → G7** : `vpc_ids` (Security Groups liés à un VPC)
- **G7 → G5** : `db_security_group_id` (RDS protégé par SG dédié)
- **G7 → G6** : `iam_role_arn` (rôle IAM pour l'application)

## Principe du moindre privilège

Chaque composant reçoit **exactement** les droits dont il a besoin — ni plus.

| Rôle | Accès autorisé |
|------|----------------|
| `role-api-app` | S3 GetObject/PutObject sur ses buckets CDNU, RDS connect |
| `role-cicd` | ECR push/pull, lecture secrets, SSM send-command |
| `role-monitoring` | CloudWatch:PutMetricData, Logs:PutLogEvents |
| `role-admin-cdnu` | Accès limité au VPC et ressources de son CDNU uniquement |
