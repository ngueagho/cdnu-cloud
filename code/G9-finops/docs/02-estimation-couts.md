# Estimation des coûts mensuels — 10 CDNUs (AWS eu-west-1)

> Tarifs indicatifs AWS Ireland (eu-west-1) — Mai 2026. Utiliser le calculateur AWS pour affiner.

## Coûts par composant (pour 10 CDNUs)

### Calcul (EC2)

| Instance | Quantité | Prix unitaire/h | Heures/mois | Total/mois |
|----------|----------|-----------------|-------------|------------|
| t3.large (Moodle app) | 10 (1/CDNU) | $0.0928 | 730 | ~$677 |
| t3.medium (monitoring) | 1 | $0.0464 | 730 | ~$34 |
| **Sous-total EC2** | | | | **~$711** |

### Base de données (RDS)

| Service | Config | Prix/h | Total/mois |
|---------|--------|--------|------------|
| RDS PostgreSQL Multi-AZ | db.t3.medium | $0.136 | ~$99 |
| Stockage RDS (100 Go gp3) | 100 Go | $0.115/Go | ~$12 |
| Backups automatiques | Inclus (jusqu'à 100%) | — | $0 |
| **Sous-total RDS** | | | **~$111** |

### Stockage S3

| Composant | Volume | Prix/Go | Total/mois |
|-----------|--------|---------|------------|
| S3 Standard (données actives) | 3 To | $0.023 | ~$69 |
| S3 Infrequent Access (archives) | 5 To | $0.0125 | ~$63 |
| Requêtes GET (10M/mois) | 10M | $0.0004/1000 | ~$4 |
| **Sous-total S3** | | | **~$136** |

### Réseau

| Composant | Unité | Prix | Total/mois |
|-----------|-------|------|------------|
| Transit Gateway | 10 VPCs attachés × $0.05/h | | ~$365 |
| NAT Gateway (10 × 1) | $0.045/h | 730h | ~$328 |
| Data Transfer OUT (500 Go) | $0.09/Go | | ~$45 |
| **Sous-total Réseau** | | | **~$738** |

### Monitoring & Logs

| Service | Prix estimé/mois |
|---------|-----------------|
| CloudWatch Logs (100 Go) | ~$50 |
| CloudWatch Métriques custom | ~$15 |
| **Sous-total Monitoring** | **~$65** |

### Autres services

| Service | Prix/mois |
|---------|-----------|
| ECR (100 Go stockage images) | ~$10 |
| ACM Certificats | $0 (inclus) |
| Route 53 (1 zone) | ~$1 |
| **Sous-total Divers** | **~$11** |

---

## Récapitulatif mensuel

| Catégorie | Coût/mois |
|-----------|-----------|
| EC2 (Calcul) | $711 |
| RDS (Base de données) | $111 |
| S3 (Stockage) | $136 |
| Réseau (TGW + NAT) | $738 |
| Monitoring | $65 |
| Divers | $11 |
| **TOTAL ESTIMÉ** | **~$1,772/mois** |
| **Avec réserved instances (-30%)** | **~$1,240/mois** |

> **Note :** Le Transit Gateway et les NAT Gateways représentent 42% du coût. Une architecture alternative avec un seul VPC partagé réduirait ce poste de ~$600/mois, mais au détriment de l'isolation par CDNU.

## Recommandations d'optimisation

1. **Reserved Instances EC2** : engagement 1 an → -30% sur les instances EC2/RDS
2. **Spot Instances** pour les environnements de test : -70%
3. **NAT Instance** au lieu de NAT Gateway (dev seulement) : -90% sur ce poste
4. **S3 Intelligent-Tiering** : automatique pour les objets > 128 Ko
5. **Arrêt automatique des instances** hors heures ouvrées (dev/staging) : -40%
