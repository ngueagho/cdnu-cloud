# G3 — Architecture Haut Niveau

## Objectif

Concevoir l'architecture cloud globale qui sera implémentée par G4 et G5. G3 produit les schémas et documents d'architecture qui font référence pour tous les groupes techniques.

## Livrables attendus

| Livrable | Fichier | Échéance |
|----------|---------|----------|
| Architecture globale + sélection services | `docs/01-architecture-globale.md` | Fin S2 |
| Schéma HA/DR | `docs/02-ha-dr.md` | Fin S2 |
| Schémas visuels (draw.io / PNG) | `schemas/` | Fin S3 |
| Rapport final G3 (15-20 pages) | `docs/rapport-g3.md` | Fin S4 |

## Dépendances

- **G2 → G3** : Décision provider (AWS) + contraintes conformité
- **G1 → G3** : Besoins en capacité (volumétrie, utilisateurs)
- **G3 → G4** : Spécifications réseau (CIDR, topologie, services)
- **G3 → G5** : Services managés à déployer
- **G3 → G7** : Périmètre de sécurité, zones de confiance

## Schémas à produire (dossier `schemas/`)

1. **Vue globale réseau** : 10 VPCs interconnectés via Transit Gateway
2. **Détail d'un CDNU** : Subnets public/private/database, flux entre couches
3. **Schéma HA/DR** : Multi-AZ, failover RDS, S3 Cross-Region Replication
4. **Flux applicatif** : Internet → ALB → App EC2 → RDS → S3

### Outils recommandés
- [draw.io](https://draw.io) (gratuit, export PNG/SVG)
- AWS Architecture Icons : https://aws.amazon.com/architecture/icons/
