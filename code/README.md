# Projet CDNU Cloud - Déploiement Cloud Unifié des Centres de Développement du Numérique Universitaire

## Description

Ce projet a pour objectif de déployer un **environnement cloud unifié et sécurisé** pour les 10 Centres de Développement du Numérique Universitaire (CDNU) camerounais. L'infrastructure est hébergée sur AWS (avec support LocalStack pour simulation locale) et gérée entièrement par Infrastructure-as-Code (Terraform).

10 groupes collaborent en parallèle sur différentes couches de l'infrastructure, de l'analyse stratégique jusqu'à la documentation et le plan de reprise d'activité.

---

## Groupes et responsabilités

| Groupe | Nom | Responsabilité | Dossier |
|--------|-----|----------------|---------|
| **G1** | Stratégie & Analyse | Analyse des besoins des 10 CDNUs, stratégie de migration, inventaire des services | [G1-strategie-analyse/](./G1-strategie-analyse/) |
| **G2** | Fournisseur & Conformité | Comparatif AWS/Azure/GCP/OVH, conformité RGPD, loi camerounaise, ISO 27001 | [G2-fournisseur-conformite/](./G2-fournisseur-conformite/) |
| **G3** | Architecture Haut Niveau | Design VPC inter-régions, topologie réseau, sélection des services AWS | [G3-architecture/](./G3-architecture/) |
| **G4** | IaC Réseau (Terraform) | VPC, sous-réseaux, IGW, NAT, tables de routage, Transit Gateway | [G4-iac-reseau/](./G4-iac-reseau/) |
| **G5** | Services Managés (Terraform) | S3 buckets, RDS PostgreSQL, ECR, politiques de sauvegarde | [G5-services-manages/](./G5-services-manages/) |
| **G6** | CI/CD & Application | Pipeline GitHub Actions, API FastAPI "état des services" | [G6-cicd-app/](./G6-cicd-app/) |
| **G7** | Sécurité & IAM | Rôles IAM, Security Groups, ACL, WAF, TLS/Let's Encrypt | [G7-securite-iam/](./G7-securite-iam/) |
| **G8** | Tests & Monitoring | Tests d'intégration, Prometheus + Grafana, dashboard santé CDNUs | [G8-tests-monitoring/](./G8-tests-monitoring/) |
| **G9** | FinOps | Tagging, budgets AWS, alertes coûts, right-sizing, estimations | [G9-finops/](./G9-finops/) |
| **G10** | Documentation & DRP | Guide technique, guide utilisateur, plan DRP (RPO=4h, RTO=24h) | [G10-documentation-drp/](./G10-documentation-drp/) |

---

## Les 10 CDNUs concernés

```
cdnu-yaounde-1     cdnu-douala-1      cdnu-bafoussam-1   cdnu-ngaoundere-1  cdnu-garoua-1
cdnu-maroua-1      cdnu-ebolowa-1     cdnu-bertoua-1     cdnu-limbe-1       cdnu-buea-1
```

---

## Schéma des dépendances inter-groupes

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FLUX DE DÉPENDANCES                                 │
└─────────────────────────────────────────────────────────────────────────────┘

  G1 (Analyse)  ──────► G3 (Architecture) ──────┐
  G2 (Conformité) ────► G3 (Architecture) ──────┤
                                                  ▼
                              G4 (IaC Réseau) ───────────────────────┐
                              │  VPC IDs, Subnet IDs                  │
                              ▼                                        │
                         G5 (Services) ◄──────────────────────────────┤
                         │  RDS Endpoint, S3 ARNs, ECR URLs           │
                         ▼                                             │
                    G6 (CI/CD + App) ◄─────────────────────────────── │
                    │  API déployée                                    │
                    ▼                                                  │
               G7 (Sécurité) ◄──────────── G4 (VPC IDs) ◄────────────┘
               │  IAM Roles, Security Groups
               ▼
          G8 (Monitoring) ◄──── G6 (API endpoints) ◄──── G7 (SGs)
          │  Dashboards, Alertes
          ▼
     G9 (FinOps) ──── Tagging de TOUTES les ressources G4/G5/G6/G7
     │  Budgets, Rapports coûts
     ▼
G10 (Documentation) ──── Synthèse de G1 à G9 + Plan DRP

┌───────────────────────────────────────────────────────────┐
│ shared/terraform/  ← Utilisé par G4, G5, G7, G9          │
│  - providers.tf, variables.tf, locals.tf, outputs.tf      │
└───────────────────────────────────────────────────────────┘
```

---

## Démarrage rapide

### Prérequis

```bash
# Outils requis
terraform >= 1.5.0
aws-cli >= 2.0
python >= 3.11
docker >= 24.0
git >= 2.40

# Vérification
terraform version
aws --version
python3 --version
docker --version
```

### Configuration initiale

```bash
# 1. Cloner le dépôt
git clone https://github.com/votre-org/cdnu-cloud.git
cd cdnu-cloud/code

# 2. Copier et configurer les variables d'environnement
cp shared/.env.example shared/.env
# Éditer shared/.env avec vos credentials

# 3. Initialiser Terraform (dossier G4 en premier)
cd G4-iac-reseau
cp terraform.tfvars.example terraform.tfvars
# Éditer terraform.tfvars
terraform init
terraform plan

# 4. Lancer le stack de monitoring (optionnel, développement)
cd G8-tests-monitoring/monitoring
docker-compose up -d
```

### Simulation locale avec LocalStack

```bash
# Installer LocalStack
pip install localstack awscli-local

# Démarrer LocalStack
localstack start -d

# Configurer AWS CLI pour LocalStack
export AWS_DEFAULT_REGION=eu-west-1
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_ENDPOINT_URL=http://localhost:4566

# Déployer via Terraform (LocalStack)
cd G4-iac-reseau
terraform init -backend=false
terraform apply -var="use_localstack=true"
```

---

## Calendrier du TP (4 semaines)

| Semaine | Dates | G1 | G2 | G3 | G4 | G5 | G6 | G7 | G8 | G9 | G10 |
|---------|-------|----|----|----|----|----|----|----|----|----|----|
| **S1** | J1-J7 | Analyse besoins | Comparatif fournisseurs | - | - | - | - | - | - | - | - |
| **S2** | J8-J14 | Stratégie migration | Conformité RGPD | Architecture globale | Init Terraform | - | - | - | - | - | - |
| **S3** | J15-J21 | Inventaire services | Décision provider | HA/DR | VPC+Subnets | S3+RDS+ECR | App FastAPI | IAM+SGs | Tests + Prometheus | Tagging+Budgets | - |
| **S4** | J22-J28 | Revue finale | Revue finale | Schémas finaux | TGW + review | Backup policies | CI/CD pipeline | TLS+WAF | Grafana dashboards | Right-sizing | Docs + DRP |

---

## Règles de collaboration Git

### Structure des branches

```
main                    ← branche protégée, merge via PR uniquement
├── develop             ← branche d'intégration commune
├── g1/analyse-besoins  ← branches de groupes
├── g2/comparatif-providers
├── g3/architecture-vpc
├── g4/iac-reseau
├── g5/services-manages
├── g6/cicd-app
├── g7/securite-iam
├── g8/monitoring
├── g9/finops
└── g10/documentation
```

### Convention de commits (Conventional Commits)

```bash
# Format : <type>(<scope>): <description>

feat(g4): add VPC module for 10 CDNUs
fix(g6): correct health endpoint response format
docs(g1): complete migration strategy document
chore(g9): update cost estimation for eu-west-1
test(g8): add integration tests for CDNU API endpoints
infra(g5): configure RDS backup retention to 7 days
```

### Workflow de contribution

```bash
# 1. Créer sa branche depuis develop
git checkout develop
git pull origin develop
git checkout -b g4/feature-transit-gateway

# 2. Travailler, committer régulièrement
git add G4-iac-reseau/modules/transit-gateway/
git commit -m "feat(g4): add Transit Gateway module for VPC interconnection"

# 3. Pousser et créer une Pull Request vers develop
git push origin g4/feature-transit-gateway
# → Créer PR sur GitHub avec description + reviewers G3 (architecture)

# 4. Après merge dans develop, synchroniser
git checkout develop && git pull origin develop
```

### Règles de PR

- Minimum 1 reviewer d'un groupe dépendant (voir schéma dépendances)
- Les fichiers Terraform doivent passer `terraform validate` et `terraform fmt`
- Aucun secret (clé AWS, mot de passe) dans le code — vérifier avec `git-secrets`
- Description de PR obligatoire : ce qui change, pourquoi, comment tester

---

## Contact coordinateur technique

Pour les questions d'intégration inter-groupes, ouvrir une **issue GitHub** avec le label approprié (`g4`, `integration`, `urgent`, etc.).
