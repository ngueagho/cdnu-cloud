# G2 — Fournisseur & Conformité

## Objectif

Choisir et justifier le fournisseur cloud le mieux adapté au contexte camerounais, en tenant compte des critères techniques, économiques et réglementaires.

## Livrables attendus

| Livrable | Fichier | Échéance |
|----------|---------|----------|
| Comparatif fournisseurs | `docs/01-comparatif-providers.md` | Fin S1 |
| Analyse conformité RGPD + loi camerounaise | `docs/02-conformite-rgpd-cameroun.md` | Fin S2 |
| Décision finale + justification | `docs/03-decision-provider.md` | Fin S3 |
| Rapport final G2 (15-20 pages) | `docs/rapport-g2.md` | Fin S4 |

## Dépendances

- **G2 → G3** : Le choix du provider détermine les services utilisés dans l'architecture
- **G2 → G4** : Le provider détermine le code Terraform (AWS vs Azure vs GCP)
- **G2 → G7** : Les contraintes de conformité influencent la politique IAM et chiffrement

> **IMPORTANT** : G2 doit rendre sa décision avant la fin de S1 pour que G4 puisse démarrer le code Terraform.

## Critères d'évaluation

1. **Technique** : Disponibilité datacenter Afrique/Europe, services managés, SLA
2. **Économique** : Coût estimé pour 10 CDNUs, crédits éducatifs disponibles
3. **Conformité** : RGPD, loi camerounaise n°2010/012, ISO 27001
4. **Support** : Présence locale, documentation en français, support niveau 1
5. **Souveraineté** : Localisation des données, droit applicable
