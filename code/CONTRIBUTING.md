# Guide de contribution — Projet CDNU Cloud

## Organisation des branches

```
main        ← protégée, merge via PR uniquement, état déployable
develop     ← branche d'intégration commune
g1/...      ← branches de travail par groupe
g2/...
...
g10/...
```

## Workflow de base

```bash
# 1. Partir toujours de develop à jour
git checkout develop && git pull origin develop

# 2. Créer sa branche de travail
git checkout -b g4/transit-gateway

# 3. Travailler et committer
git add G4-iac-reseau/modules/transit-gateway/
git commit -m "feat(g4): add Transit Gateway interconnect module"

# 4. Pousser et ouvrir une PR vers develop
git push origin g4/transit-gateway
```

## Convention de nommage des commits

```
feat(gX): nouvelle fonctionnalité
fix(gX):  correction d'un bug
docs(gX): documentation uniquement
infra(gX): code Terraform / infrastructure
test(gX): ajout ou modification de tests
chore(gX): maintenance (dépendances, config)
```

## Règles pour les Pull Requests

- **Titre clair** : `[G4] Add VPC module for 10 CDNUs`
- **Description** : Ce qui change, pourquoi, comment tester
- **Reviewers** : Minimum 1 reviewer du groupe dépendant (voir README.md principal)
- **Checks obligatoires** :
  - `terraform validate` + `terraform fmt` pour les fichiers `.tf`
  - `pytest` pour les fichiers Python
  - Aucun secret dans le diff (`*.tfvars`, `.env`, clés AWS)

## Règles absolues

| Interdit | Raison |
|----------|--------|
| Committer `terraform.tfvars` | Contient des valeurs sensibles |
| Committer `.env` | Contient des secrets |
| Committer des clés AWS / mots de passe | Sécurité |
| `git push --force` sur `main` ou `develop` | Destructif pour tout le monde |
| `terraform destroy` sans accord du coordinateur | Détruit l'infra partagée |

## Coordinateur technique

Le coordinateur technique synchronise les versions IaC entre G4, G5, G6, G7, G8.  
Ouvrir une **issue GitHub** pour tout problème d'intégration inter-groupes.
