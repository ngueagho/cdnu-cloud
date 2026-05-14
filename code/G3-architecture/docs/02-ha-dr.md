# Haute Disponibilité et Plan de Reprise d'Activité

## 1. Objectifs HA/DR

| Métrique | Cible | Justification |
|----------|-------|---------------|
| **Disponibilité** | 99,5% | ~3,65h d'interruption max/mois |
| **RPO** (Recovery Point Objective) | 4 heures | Perte de données max acceptable |
| **RTO** (Recovery Time Objective) | 24 heures | Durée max de restauration complète |

---

## 2. Architecture Haute Disponibilité

### 2.1 Couche réseau
- **Transit Gateway** : aucun SPOF, redondance AWS native
- **NAT Gateway** : 1 par AZ (pas de NAT Gateway cross-AZ)
- **Internet Gateway** : HA native AWS

### 2.2 Couche applicative
- **EC2 Auto Scaling Group** : min=1, desired=2, max=5 instances
- **Application Load Balancer** : distribue le trafic sur 2 AZ
- **Health checks** : vérification toutes les 30s, bascule auto en 90s

### 2.3 Couche données
- **RDS Multi-AZ** : synchronous replication, failover automatique < 60s
- **S3** : 11 neuf de durabilité, réplication multi-AZ native
- **RDS Automated Backups** : rétention 7 jours, PITR (Point-in-Time Recovery)

---

## 3. Scénarios de défaillance et réponses

### Scénario A : Panne d'une instance EC2
```
Détection : ALB health check échoue après 3 tentatives (90s)
Action auto : ASG lance une nouvelle instance en ~3 minutes
Impact utilisateurs : Aucun (ALB reroute le trafic)
RTO effectif : < 5 minutes
```

### Scénario B : Panne de la base de données (AZ primaire)
```
Détection : RDS détecte la panne (30s)
Action auto : Promotion du standby Multi-AZ en master (60s)
DNS update : Automatique (~30s de propagation)
Impact utilisateurs : Interruption 2-3 minutes
RTO effectif : < 5 minutes
```

### Scénario C : Perte d'un CDNU entier (ex: panne datacenter local)
```
Détection : Monitoring G8 — alertes latence/uptime
Action manuelle : Activation du DRP par le coordinateur
Procédure : Voir docs/03-drp.md (G10)
RTO : 24 heures maximum
```

### Scénario D : Corruption de données S3
```
Détection : Intégrité vérifiée par checksums
Action : Restauration depuis S3 Versioning (point précédent)
RPO : Dernière version = 0 perte si versioning activé
```

---

## 4. Stratégie de sauvegarde

| Ressource | Méthode | Fréquence | Rétention | RPO |
|-----------|---------|-----------|-----------|-----|
| RDS PostgreSQL | Automated Backup | Quotidien (minuit) | 7 jours | 24h |
| RDS PostgreSQL | Snapshot manuel | Hebdomadaire | 30 jours | 7 jours |
| S3 Buckets | Versioning activé | Continu | Indéfini | 0 |
| EC2 AMI | AWS Backup | Hebdomadaire | 4 semaines | 7 jours |
| Config Terraform | Git (code) | À chaque commit | Indéfini | 0 |

---

## 5. Tests de HA à réaliser (G8)

- [ ] Test failover RDS : `aws rds reboot-db-instance --force-failover`
- [ ] Test ASG : Terminer une instance manuellement, vérifier relance auto
- [ ] Test restauration S3 : Supprimer un objet, restaurer depuis version précédente
- [ ] Test complet DRP : Simuler perte d'un CDNU, mesurer RTO réel
