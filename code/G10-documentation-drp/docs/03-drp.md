# Plan de Reprise d'Activité (DRP)

**RPO (Recovery Point Objective) : 4 heures**  
**RTO (Recovery Time Objective) : 24 heures**  
**Version :** 1.0 | **Dernière révision :** <!-- date -->  
**Responsable DRP :** <!-- nom et contact -->

---

## 1. Objectifs du DRP

| Métrique | Valeur cible | Justification |
|----------|-------------|---------------|
| RPO | 4 heures | Perte de données max acceptable — sauvegardes toutes les 4h |
| RTO | 24 heures | Délai max de restauration complète d'un CDNU |
| Disponibilité cible | 99,5% | ~3,65h d'interruption/mois acceptable |

---

## 2. Classification des incidents

| Niveau | Définition | Exemples | Délai réponse |
|--------|-----------|---------|----------------|
| **P1 — Critique** | Service complètement indisponible pour tous les CDNUs | Panne AWS region, DB down | Immédiat (< 15 min) |
| **P2 — Majeur** | 1-3 CDNUs indisponibles ou service dégradé | Panne VPC, EC2 down | < 1 heure |
| **P3 — Mineur** | Dégradation partielle, contournement possible | Latence élevée, logs manquants | < 4 heures |

---

## 3. Arbre de décision — Qualification d'un incident

```
Alerte reçue (monitoring G8 ou signalement utilisateur)
    │
    ▼
[1] Vérifier le dashboard Grafana
    │
    ├── API répond? → NON → Incident P1 → Activer procédure 4.1
    │
    ├── DB accessible? → NON → Incident P1/P2 → Activer procédure 4.2
    │
    ├── S3 accessible? → NON → Incident P2 → Activer procédure 4.3
    │
    └── Latence élevée seulement? → P3 → Procédure 4.4
```

---

## 4. Procédures de restauration

### 4.1 Panne API complète (P1) — RTO cible : 2 heures

```bash
# Étape 1 — Diagnostiquer (15 min)
ssh ec2-user@[ip-serveur]
docker logs cdnu-api --tail=100
docker stats cdnu-api

# Étape 2a — Si le conteneur est crashé : redémarrer
docker restart cdnu-api
# Attendre 30s et vérifier
curl http://[ip]:8000/health

# Étape 2b — Si l'instance EC2 est down : lancer depuis l'AMI
aws ec2 run-instances \
  --image-id [ami-id] \
  --instance-type t3.large \
  --iam-instance-profile Name=cdnu-cloud-prod-profile-api-app \
  --subnet-id [subnet-privé] \
  --security-group-ids [sg-app-id] \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Project,Value=cdnu-cloud},{Key=Role,Value=api-server}]'

# Étape 3 — Redéployer l'image ECR
docker pull [ecr-url]/cdnu-cloud-prod/api-services:latest
docker run -d --name cdnu-api -p 8000:8000 --env-file /etc/cdnu/app.env [image]

# Étape 4 — Vérifier et notifier
curl https://api.cdnu.cm/health
# Notifier les utilisateurs de la restauration du service
```

### 4.2 Panne base de données RDS (P1/P2) — RTO cible : 4 heures

```bash
# Cas A : Failover Multi-AZ automatique (attendu < 2 min)
# Vérifier l'événement dans les logs RDS
aws rds describe-events --source-identifier cdnu-cloud-prod-db --duration 60

# Cas B : Restauration depuis snapshot (si corruption de données)
# 1. Identifier le dernier snapshot valide
aws rds describe-db-snapshots \
  --db-instance-identifier cdnu-cloud-prod-db \
  --query 'DBSnapshots[?Status==`available`].[DBSnapshotIdentifier,SnapshotCreateTime]'

# 2. Restaurer depuis le snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier cdnu-cloud-prod-db-restored \
  --db-snapshot-identifier [snapshot-id] \
  --db-instance-class db.t3.medium \
  --multi-az

# 3. Mettre à jour le paramètre DATABASE_URL dans app.env
# 4. Redémarrer l'API

# Cas C : Restauration point-in-time (PITR) — pour restaurer à J-4h précisément
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier cdnu-cloud-prod-db \
  --target-db-instance-identifier cdnu-cloud-prod-db-pitr \
  --restore-time $(date -u -d '4 hours ago' +%Y-%m-%dT%H:%M:%SZ)
```

### 4.3 Perte données S3 (P2) — RTO cible : 1 heure

```bash
# Lister les versions d'un objet supprimé accidentellement
aws s3api list-object-versions \
  --bucket cdnu-cloud-prod-storage-yaounde-1 \
  --prefix chemin/du/fichier.pdf

# Restaurer une version précédente
aws s3api copy-object \
  --bucket cdnu-cloud-prod-storage-yaounde-1 \
  --copy-source "cdnu-cloud-prod-storage-yaounde-1/chemin/fichier.pdf?versionId=[version-id]" \
  --key "chemin/du/fichier.pdf"
```

### 4.4 Perte complète d'un CDNU (P2) — RTO cible : 24 heures

```bash
# Ce scénario couvre la destruction totale d'un VPC ou d'une région
# Procédure : recréer depuis zéro via Terraform

cd G4-iac-reseau
# Vérifier que terraform.tfvars est à jour
terraform plan -target="module.vpc[\"yaounde-1\"]" -target="module.subnets[\"yaounde-1\"]"
terraform apply -target="module.vpc[\"yaounde-1\"]" -target="module.subnets[\"yaounde-1\"]"

# Puis recréer les services (G5)
cd ../G5-services-manages
terraform apply -target="module.storage[\"yaounde-1\"]"

# Restaurer les données depuis backup S3 Cross-Region (si activé)
# ou depuis le dernier snapshot RDS
```

---

## 5. Checklist post-restauration

Après toute procédure de restauration, vérifier :

- [ ] `/health` de l'API répond HTTP 200
- [ ] Les 10 CDNUs sont visibles dans le dashboard Grafana
- [ ] La base de données accepte les connexions
- [ ] Les 10 buckets S3 sont accessibles
- [ ] Les alertes Prometheus sont résolues
- [ ] Incident consigné dans le registre des incidents
- [ ] Post-mortem planifié sous 48h (pour P1)

---

## 6. Contacts d'urgence

| Rôle | Nom | Téléphone | Email |
|------|-----|-----------|-------|
| Astreinte infrastructure | À désigner | À compléter | À compléter |
| DSI MINESUP | À désigner | À compléter | dsi@minesup.cm |
| Support AWS (si compte payant) | AWS Support | Case via console | — |
| Coordinateur technique TP | À désigner | À compléter | À compléter |

---

## 7. Registre des tests DRP

| Date | Scénario testé | RTO mesuré | Résultat | Observations |
|------|----------------|------------|----------|--------------|
| À compléter | Failover RDS | — | — | — |
| À compléter | Restauration S3 | — | — | — |
| À compléter | Perte CDNU complet | — | — | — |
