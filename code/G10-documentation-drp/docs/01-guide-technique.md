# Guide Technique — Infrastructure Cloud CDNU

**Version :** 1.0  
**Date :** <!-- À compléter -->  
**Auteurs :** Groupe G10  
**Statut :** <!-- Brouillon / Validé -->

---

## Table des matières

1. [Prérequis et outils](#1-prérequis)
2. [Vue d'ensemble de l'architecture](#2-architecture)
3. [Déploiement initial](#3-déploiement)
4. [Opérations courantes](#4-opérations)
5. [Surveillance et alertes](#5-surveillance)
6. [Gestion des accès](#6-accès)
7. [Troubleshooting](#7-troubleshooting)
8. [Contacts et escalade](#8-contacts)

---

## 1. Prérequis

### Outils requis

```bash
# Vérifier les versions installées
terraform version   # >= 1.5.0
aws --version       # >= 2.0
docker --version    # >= 24.0
python3 --version   # >= 3.11
git --version       # >= 2.40
```

### Accès AWS

```bash
# Configurer les credentials
aws configure
# Vérifier l'identité
aws sts get-caller-identity
```

### Cloner le dépôt

```bash
git clone https://github.com/[org]/cdnu-cloud.git
cd cdnu-cloud/code
cp shared/.env.example shared/.env
# Éditer shared/.env avec les vraies valeurs
```

---

## 2. Architecture

L'infrastructure est composée de :

- **10 VPCs AWS** (1 par CDNU) dans `eu-west-1`, chacun avec 3 couches de subnets
- **1 Transit Gateway** central interconnectant tous les VPCs
- **10 NAT Gateways** pour l'accès internet sortant des subnets privés
- **1 RDS PostgreSQL** Multi-AZ (db.t3.medium) — partagé ou 1 par CDNU
- **10 buckets S3** (1 par CDNU) avec versioning et chiffrement
- **1 registre ECR** pour les images Docker
- **Stack Prometheus + Grafana** pour le monitoring

Voir les schémas dans `G3-architecture/schemas/`.

---

## 3. Déploiement initial

### Ordre de déploiement

```bash
# Étape 1 — Réseau (G4)
cd G4-iac-reseau
cp terraform.tfvars.example terraform.tfvars
# Éditer terraform.tfvars
terraform init && terraform apply

# Étape 2 — Sécurité (G7) — dépend des VPC IDs de G4
cd ../G7-securite-iam
# Renseigner les vpc_ids dans terraform.tfvars
terraform init && terraform apply

# Étape 3 — Services managés (G5) — dépend VPC IDs + SG IDs
cd ../G5-services-manages
# export TF_VAR_db_password="MotDePasseSecurisé!"
terraform init && terraform apply

# Étape 4 — Application (G6)
cd ../G6-cicd-app/app
# Le pipeline CI/CD déploie automatiquement via GitHub Actions

# Étape 5 — Monitoring (G8)
cd ../G8-tests-monitoring/monitoring
docker-compose up -d

# Étape 6 — FinOps (G9)
cd ../G9-finops
terraform init && terraform apply
```

### Vérification post-déploiement

```bash
# Vérifier que l'API répond
curl https://api.cdnu.cm/health

# Vérifier les 10 CDNUs
curl https://api.cdnu.cm/cdnu

# Vérifier Grafana
open http://[monitoring-ip]:3000
```

---

## 4. Opérations courantes

### Mettre à jour l'application

```bash
# Pousser une nouvelle version → déclenche le pipeline CI/CD
git push origin main
# Le pipeline build → test → push ECR → deploy automatiquement
```

### Scaler les instances EC2

```bash
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name cdnu-cloud-prod-asg \
  --min-size 2 --desired-capacity 3 --max-size 6
```

### Créer un snapshot RDS manuel

```bash
aws rds create-db-snapshot \
  --db-instance-identifier cdnu-cloud-prod-db \
  --db-snapshot-identifier cdnu-snapshot-$(date +%Y%m%d)
```

### Lister les buckets S3

```bash
aws s3 ls | grep cdnu-cloud-prod-storage
```

---

## 5. Surveillance et alertes

- **Grafana** : `http://[ip]:3000` — dashboard "CDNU Health Overview"
- **Prometheus** : `http://[ip]:9090` — métriques brutes
- **AlertManager** : `http://[ip]:9093` — gestion des alertes actives
- **CloudWatch** : Console AWS → CloudWatch → Dashboards

### Seuils d'alerte configurés

| Alerte | Seuil | Sévérité |
|--------|-------|----------|
| API inaccessible | 2 min down | Critique |
| CDNU dégradé | 5 min | Warning |
| DB inaccessible | 2 min | Critique |
| Latence scrape | > 5s | Warning |

---

## 6. Gestion des accès

### Ajouter un administrateur CDNU

```bash
# Créer l'utilisateur IAM
aws iam create-user --user-name admin-yaounde-1

# Attacher le rôle restreint au CDNU
aws iam attach-user-policy \
  --user-name admin-yaounde-1 \
  --policy-arn arn:aws:iam::[account]:policy/cdnu-cloud-prod-policy-yaounde-1
```

---

## 7. Troubleshooting

### L'API ne répond pas

```bash
# 1. Vérifier l'état du conteneur
docker ps | grep cdnu-api
# 2. Voir les logs
docker logs cdnu-api --tail=50
# 3. Vérifier la connectivité DB
curl http://[ip]:8000/cdnu/yaounde-1
```

### RDS injoignable depuis l'application

```bash
# Vérifier les Security Groups
aws ec2 describe-security-groups --group-ids [sg-id]
# Vérifier que le SG app est bien dans les inbound rules du SG db
```

### Terraform plan échoue

```bash
# Vérifier les credentials
aws sts get-caller-identity
# Vérifier l'état Terraform
terraform state list
```

---

## 8. Contacts

| Rôle | Contact | Disponibilité |
|------|---------|---------------|
| Coordinateur technique | [email] | Heures ouvrées |
| Astreinte infrastructure | [email] | 24/7 pour incidents P1 |
| DSI MINESUP | dsi@minesup.cm | Heures ouvrées |
