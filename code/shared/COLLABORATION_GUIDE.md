# Guide de collaboration technique — G4 / G5 / G6 / G7 / G8

Ce guide définit comment les groupes techniques partagent et consomment l'infrastructure Terraform.

## Principe général

```
G4 (réseau) → produit les VPC IDs et Subnet IDs
G5 (services) → consomme VPC IDs de G4, produit RDS endpoint, S3 ARNs, ECR URLs
G6 (app) → consomme RDS endpoint + S3 ARNs de G5, produit l'URL de l'API
G7 (sécurité) → consomme VPC IDs de G4, produit IAM Role ARNs et SG IDs
G8 (monitoring) → consomme l'URL API de G6 et les SG IDs de G7
```

## Partage des outputs Terraform

Chaque groupe exporte ses valeurs clés dans son `outputs.tf`.  
Les groupes consommateurs les référencent via un **data source remote state** :

```hcl
# Exemple dans G5 : lire les VPC IDs produits par G4
data "terraform_remote_state" "g4_network" {
  backend = "local"
  config = {
    path = "../G4-iac-reseau/terraform.tfstate"
  }
}

# Utilisation
resource "aws_db_subnet_group" "main" {
  subnet_ids = data.terraform_remote_state.g4_network.outputs.private_subnet_ids
}
```

> En production, utiliser un backend S3 partagé (voir ci-dessous).

## Backend S3 partagé (recommandé)

```hcl
# À ajouter dans chaque main.tf de groupe
terraform {
  backend "s3" {
    bucket         = "cdnu-terraform-state"
    key            = "g4/network/terraform.tfstate"  # Adapter par groupe
    region         = "eu-west-1"
    dynamodb_table = "cdnu-terraform-locks"
    encrypt        = true
  }
}
```

## Ordre de déploiement

```
1. G4  → terraform apply  (réseau de base)
2. G7  → terraform apply  (IAM + SGs — dépend VPC)
3. G5  → terraform apply  (services managés — dépend VPC + SGs)
4. G6  → docker build + push + deploy (dépend ECR + RDS + S3)
5. G8  → docker-compose up (monitoring — dépend API G6)
6. G9  → terraform apply  (tagging + budgets)
```

## Conventions de nommage des ressources

| Ressource     | Format                              | Exemple                        |
|---------------|-------------------------------------|--------------------------------|
| VPC           | `{prefix}-vpc-{cdnu}`               | `cdnu-cloud-prod-vpc-yaounde-1`|
| Subnet public | `{prefix}-subnet-pub-{cdnu}-{az}`   | `cdnu-cloud-prod-subnet-pub-yaounde-1-a` |
| S3 Bucket     | `{prefix}-storage-{cdnu}`           | `cdnu-cloud-prod-storage-yaounde-1` |
| RDS Instance  | `{prefix}-db-{cdnu}`                | `cdnu-cloud-prod-db-yaounde-1` |
| IAM Role      | `{prefix}-role-{fonction}`          | `cdnu-cloud-prod-role-api-app` |

## Règles absolues

- **Jamais de `terraform destroy` sans accord du coordinateur**
- **Tout changement sur G4 doit être signalé à G5, G7, G8** (ouvrir une issue)
- **Les outputs critiques ne doivent pas changer de nom** (breaking change)
- **Un `terraform plan` doit être partagé dans la PR** avant tout merge
