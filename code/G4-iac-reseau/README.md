# G4 — Infrastructure as Code : Réseau

## Objectif

Déployer via Terraform l'intégralité de la couche réseau pour les 10 CDNUs : VPCs, subnets, passerelles, tables de routage et Transit Gateway d'interconnexion.

## Livrables attendus

| Livrable | Fichier | Échéance |
|----------|---------|----------|
| Module VPC (10 VPCs) | `modules/vpc/` | Fin S2 |
| Module Subnets (pub/priv/DB par CDNU) | `modules/subnets/` | Fin S3 |
| Transit Gateway | `modules/transit-gateway/` | Fin S3 |
| NAT Gateways + Route Tables | `main.tf` | Fin S3 |
| Rapport + validation `terraform plan` | `docs/rapport-g4.md` | Fin S4 |

## Dépendances

- **G2 → G4** : Provider AWS confirmé avant de commencer
- **G3 → G4** : Plan d'adressage IP (CIDRs) et topologie réseau
- **G4 → G5** : Fournir `vpc_ids`, `private_subnet_ids`, `db_subnet_ids`
- **G4 → G7** : Fournir `vpc_ids` pour les Security Groups

## Prérequis

```bash
# Installer Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg
sudo apt-add-repository "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update && sudo apt install terraform

# Configurer AWS CLI
aws configure
# AWS Access Key ID: (depuis AWS Educate ou variables d'env)
# Region: eu-west-1

# Vérifier
terraform version
aws sts get-caller-identity
```

## Démarrage

```bash
cd G4-iac-reseau

# Copier les variables
cp terraform.tfvars.example terraform.tfvars
# Éditer terraform.tfvars (ne pas committer!)

# Initialiser
terraform init

# Planifier (voir ce qui sera créé)
terraform plan -out=plan.tfplan

# Appliquer
terraform apply plan.tfplan
```

## Simulation LocalStack

```bash
# Démarrer LocalStack
docker run -d -p 4566:4566 localstack/localstack

# Déployer sur LocalStack
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
terraform init -backend=false
terraform apply -var="aws_region=us-east-1"
```

## Validation

```bash
# Vérifier la syntaxe
terraform validate

# Formater le code
terraform fmt -recursive

# Lister les ressources créées
terraform state list

# Vérifier un VPC spécifique
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=cdnu-cloud"
```
