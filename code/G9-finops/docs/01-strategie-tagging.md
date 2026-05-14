# Stratégie de tagging des ressources cloud

## Pourquoi tagger ?

Le tagging est fondamental pour :
1. **Allocation des coûts** : savoir combien coûte chaque CDNU
2. **Gouvernance** : identifier toutes les ressources non conformes
3. **Automatisation** : cibler des ressources spécifiques (ex: arrêter les instances dev la nuit)
4. **Sécurité** : politiques IAM basées sur les tags (accès au seul CDNU concerné)

## Tags obligatoires

| Tag | Description | Valeurs autorisées | Exemple |
|-----|-------------|-------------------|---------|
| `Project` | Nom du projet global | `cdnu-cloud` | `cdnu-cloud` |
| `Environment` | Environnement | `prod`, `staging`, `dev` | `prod` |
| `CDNU` | Centre concerné | `yaounde-1`...`buea-1`, `shared` | `yaounde-1` |
| `ManagedBy` | Mode de gestion | `Terraform`, `Manual` | `Terraform` |
| `CostCenter` | Centre de coût | `CDNU-INFRA`, `CDNU-APP` | `CDNU-INFRA` |
| `Owner` | Équipe responsable | `minesup`, `g4-reseau`… | `minesup` |

## Tags optionnels recommandés

| Tag | Description | Exemple |
|-----|-------------|---------|
| `Backup` | Politique de sauvegarde | `daily`, `weekly`, `none` |
| `Shutdown` | Arrêt automatique (dev/test) | `nightly`, `weekend`, `never` |
| `DataClassification` | Sensibilité des données | `public`, `internal`, `confidential` |

## Enforcement par AWS Config

La règle AWS Config `required-tags` (G9/main.tf) détecte automatiquement toute ressource sans les 5 tags obligatoires et la marque comme **NON_COMPLIANT**.

## Exemple d'application dans Terraform

```hcl
# Dans chaque module, fusionner avec les tags locaux
resource "aws_instance" "moodle" {
  # ...
  tags = merge(local.common_tags, {
    CDNU         = "yaounde-1"
    CostCenter   = "CDNU-APP"
    DataClassification = "internal"
  })
}
```
