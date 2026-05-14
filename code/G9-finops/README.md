# G9 — FinOps & Optimisation des coûts

## Objectif

Mettre en place la gouvernance financière cloud : tagging des ressources, budgets AWS avec alertes, estimation des coûts mensuels pour les 10 CDNUs, et recommandations de right-sizing.

## Livrables attendus

| Livrable | Fichier | Échéance |
|----------|---------|----------|
| Stratégie de tagging | `docs/01-strategie-tagging.md` | Fin S2 |
| Code Terraform tags + budgets | `main.tf` | Fin S3 |
| Estimation coûts (grille tarifaire) | `docs/02-estimation-couts.md` | Fin S3 |
| Recommandations right-sizing | `docs/03-right-sizing.md` | Fin S4 |
| Rapport G9 | `docs/rapport-g9.md` | Fin S4 |

## Dépendances

- **G4/G5/G7 → G9** : Toutes les ressources créées doivent avoir les tags obligatoires
- **G9 → tous** : Les tags sont appliqués transversalement via AWS Config rules

## Tags obligatoires

| Tag | Valeur exemple | Obligatoire |
|-----|----------------|-------------|
| `Project` | `cdnu-cloud` | Oui |
| `Environment` | `prod` | Oui |
| `CDNU` | `yaounde-1` | Oui |
| `ManagedBy` | `Terraform` | Oui |
| `CostCenter` | `CDNU-INFRA` | Oui |
| `Owner` | `minesup` | Oui |
