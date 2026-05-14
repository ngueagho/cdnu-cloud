# Inventaire des services existants et cibles cloud

<!-- Compléter ce tableau pour chacun des 10 CDNUs -->

## Légende
- **État actuel** : On-premise / Hébergé externe / SaaS
- **Cible cloud** : Service AWS équivalent
- **Priorité** : P1 (critique) / P2 (important) / P3 (secondaire)

---

## Services communs à tous les CDNUs

| Service | Techno actuelle | État | Cible AWS | Groupe responsable | Priorité |
|---------|----------------|------|-----------|-------------------|----------|
| LMS Moodle | Moodle 3.x + MySQL | On-premise | EC2 + RDS MySQL/PostgreSQL | G5/G6 | P1 |
| Stockage fichiers | NAS Synology | On-premise | S3 (1 bucket/CDNU) | G5 | P1 |
| Authentification | LDAP/AD local | On-premise | AWS Cognito ou SSO SAML | G7 | P1 |
| Visioconférence | BigBlueButton | On-premise | Chime SDK ou BigBlueButton containerisé | G6 | P2 |
| DNS interne | BIND9 | On-premise | Route 53 Private Hosted Zone | G4 | P2 |
| Monitoring | Nagios local | On-premise | Prometheus + Grafana (G8) | G8 | P2 |
| Email | Postfix | On-premise | SES ou maintien on-premise | — | P3 |
| Site web | Apache + WordPress | On-premise | S3 Static + CloudFront | G5 | P3 |
| Bibliothèque numérique | DSpace | On-premise | EC2 + S3 pour stockage | G5/G6 | P2 |

---

## Volumétrie par CDNU (estimations)

| CDNU | Stockage actuel | Croissance/an | Instances VM actuelles | RAM totale |
|------|----------------|---------------|----------------------|------------|
| yaounde-1 | 2 To | +800 Go | 8 VMs | 64 Go |
| douala-1 | 1.5 To | +600 Go | 6 VMs | 48 Go |
| bafoussam-1 | 800 Go | +400 Go | 4 VMs | 32 Go |
| ngaoundere-1 | 600 Go | +300 Go | 3 VMs | 24 Go |
| garoua-1 | 500 Go | +250 Go | 3 VMs | 24 Go |
| maroua-1 | 500 Go | +250 Go | 3 VMs | 24 Go |
| ebolowa-1 | 400 Go | +200 Go | 2 VMs | 16 Go |
| bertoua-1 | 400 Go | +200 Go | 2 VMs | 16 Go |
| limbe-1 | 700 Go | +350 Go | 4 VMs | 32 Go |
| buea-1 | 600 Go | +300 Go | 3 VMs | 24 Go |
| **TOTAL** | **~8 To** | **~3.65 To/an** | **38 VMs** | **304 Go** |

---

## Recommandations de dimensionnement initial (cloud)

| Composant | Instance recommandée | Justification |
|-----------|---------------------|---------------|
| Moodle app server | t3.large (2 vCPU, 8 Go) | Charge moyenne, scalable |
| RDS PostgreSQL | db.t3.medium Multi-AZ | HA + backup automatique |
| S3 Standard | Stockage objet illimité | Pay-as-you-go |
| NAT Gateway | 1 par AZ | Coût optimisé |
| Transit Gateway | 1 régional | Interconnexion 10 VPCs |

> Ces recommandations seront affinées par G9 (FinOps) après analyse des métriques réelles.
