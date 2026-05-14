# Architecture cloud globale — 10 CDNUs

## 1. Vue d'ensemble

L'architecture repose sur **10 VPCs AWS isolés** (un par CDNU), interconnectés via un **AWS Transit Gateway** central. Chaque VPC est découpé en 3 couches de subnets pour respecter le principe de défense en profondeur.

```
Internet
    │
    ▼
[CloudFront CDN] ──────────────────────────────────────────
    │
    ▼
[Application Load Balancer] ← subnet public (10.x.0.0/24)
    │
    ▼
[EC2 - App Moodle] ← subnet privé applicatif (10.x.1.0/24)
    │                    │
    ▼                    ▼
[RDS PostgreSQL]    [S3 via VPC Endpoint]
subnet DB privé
(10.x.2.0/24)
    │
    ▼
[Transit Gateway] ←──── interconnexion 10 CDNUs
```

---

## 2. Plan d'adressage IP

| CDNU | VPC CIDR | Subnet Public | Subnet Privé App | Subnet Privé DB |
|------|----------|---------------|-----------------|-----------------|
| yaounde-1 | 10.1.0.0/16 | 10.1.0.0/24 | 10.1.1.0/24 | 10.1.2.0/24 |
| douala-1 | 10.2.0.0/16 | 10.2.0.0/24 | 10.2.1.0/24 | 10.2.2.0/24 |
| bafoussam-1 | 10.3.0.0/16 | 10.3.0.0/24 | 10.3.1.0/24 | 10.3.2.0/24 |
| ngaoundere-1 | 10.4.0.0/16 | 10.4.0.0/24 | 10.4.1.0/24 | 10.4.2.0/24 |
| garoua-1 | 10.5.0.0/16 | 10.5.0.0/24 | 10.5.1.0/24 | 10.5.2.0/24 |
| maroua-1 | 10.6.0.0/16 | 10.6.0.0/24 | 10.6.1.0/24 | 10.6.2.0/24 |
| ebolowa-1 | 10.7.0.0/16 | 10.7.0.0/24 | 10.7.1.0/24 | 10.7.2.0/24 |
| bertoua-1 | 10.8.0.0/16 | 10.8.0.0/24 | 10.8.1.0/24 | 10.8.2.0/24 |
| limbe-1 | 10.9.0.0/16 | 10.9.0.0/24 | 10.9.1.0/24 | 10.9.2.0/24 |
| buea-1 | 10.10.0.0/16 | 10.10.0.0/24 | 10.10.1.0/24 | 10.10.2.0/24 |

---

## 3. Services AWS sélectionnés

| Catégorie | Service AWS | Justification |
|-----------|------------|---------------|
| **Réseau** | VPC + Transit Gateway | Isolation par CDNU + interconnexion centralisée |
| **Calcul** | EC2 t3.large (Auto Scaling) | Flexibilité + scalabilité |
| **Base de données** | RDS PostgreSQL Multi-AZ | HA native + backup managé |
| **Stockage objet** | S3 Standard + Intelligent-Tiering | Durabilité 99,999999999% + coût optimisé |
| **Registre conteneurs** | ECR | Intégration native avec ECS/EC2 |
| **Identité** | IAM + Cognito | SSO SAML2 pour les universités |
| **DNS** | Route 53 | Résolution DNS privée entre VPCs |
| **Certificats TLS** | ACM (Let's Encrypt en backup) | Renouvellement automatique |
| **Monitoring** | CloudWatch + Prometheus/Grafana | Métriques temps réel + dashboards |
| **CDN** | CloudFront | Réduction latence pour contenus statiques |
| **Sécurité** | WAF + Security Groups + ACL | Défense en profondeur |

---

## 4. Zones de disponibilité (AZ)

Chaque CDNU utilise **2 AZ minimum** dans `eu-west-1` (Irlande) :
- `eu-west-1a` : AZ primaire (EC2, RDS master)
- `eu-west-1b` : AZ secondaire (RDS standby, EC2 backup)

```
eu-west-1a                    eu-west-1b
┌──────────────────┐          ┌──────────────────┐
│ EC2 App (active) │          │ EC2 App (standby)│
│ RDS Master       │◄────────►│ RDS Standby      │
│ NAT GW           │          │ NAT GW           │
└──────────────────┘          └──────────────────┘
         │                              │
         └──────────┬───────────────────┘
                    │
              Transit Gateway
```
