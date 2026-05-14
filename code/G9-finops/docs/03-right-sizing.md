# Guide de right-sizing — Optimisation des instances

## Principe

Le right-sizing consiste à choisir la bonne taille d'instance cloud pour éviter deux erreurs coûteuses :
- **Over-provisioning** : payer pour des ressources inutilisées
- **Under-provisioning** : dégrader les performances des utilisateurs

## Métriques à surveiller (G8 les collecte)

| Métrique | Outil | Seuil d'alerte |
|----------|-------|---------------|
| CPU utilization (EC2) | CloudWatch | > 80% → scale up, < 20% → scale down |
| RAM utilization | CloudWatch Agent | > 85% → scale up |
| RDS connections | CloudWatch | > 80% max_connections → scale up |
| RDS CPU | CloudWatch | > 75% → scale up |
| S3 requests/jour | CloudWatch | Indicatif (pas de limite) |
| Réseau entrant/sortant (EC2) | CloudWatch | Comparer avec instance limit |

## Recommandations initiales et seuils de revision

### EC2 (instances Moodle)

| CDNU | Instance actuelle | CPU moyen | Action recommandée |
|------|------------------|-----------|-------------------|
| yaounde-1 | t3.large | À mesurer | Baseline |
| douala-1 | t3.large | À mesurer | Baseline |
| CDNUs zones N | t3.large | À mesurer | Si CPU < 20% → t3.medium (-50% coût) |

**Règle : Après 2 semaines de production, revoir le sizing selon les métriques réelles.**

### RDS PostgreSQL

```
Vérifier avec :
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=cdnu-cloud-prod-db \
  --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Average
```

Si CPU RDS < 30% sur 7 jours → descendre à `db.t3.small` (-40% coût)

### NAT Gateway — Alternative économique

Les NAT Gateways représentent 42% du budget réseau (~$738/mois).

**Alternative pour environnement dev/staging :**
```hcl
# NAT Instance (t3.nano) au lieu de NAT Gateway
# Économie : ~$0.0052/h vs $0.045/h = -88%
# Inconvénient : pas HA, gestion manuelle
resource "aws_instance" "nat" {
  ami                    = "ami-nat-xxxxx"  # AMI NAT officielle AWS
  instance_type          = "t3.nano"
  source_dest_check      = false
  subnet_id              = aws_subnet.public.id
}
```

**Ne pas utiliser en production** — utiliser les NAT Gateways standards.

## Plan d'optimisation sur 3 mois

| Mois | Action | Économie estimée |
|------|--------|-----------------|
| M1 | Mesurer les métriques de base | — |
| M2 | Downsize instances sous-utilisées | -10 à -20% |
| M3 | Reserved Instances (engagement 1 an) | -30% sur EC2+RDS |
| M3 | S3 Intelligent-Tiering actif | -5 à -15% sur S3 |
| **Total potentiel** | | **-35 à -45%** (~$620-$800/mois) |
