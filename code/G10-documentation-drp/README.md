# G10 — Documentation & Plan de Reprise d'Activité (DRP)

## Objectif

Produire la documentation complète de l'infrastructure et formaliser le Plan de Reprise d'Activité (DRP) avec RPO=4h et RTO=24h.

## Livrables attendus

| Livrable | Fichier | Échéance |
|----------|---------|----------|
| Guide technique complet | `docs/01-guide-technique.md` | Fin S3 |
| Guide utilisateur | `docs/02-guide-utilisateur.md` | Fin S3 |
| Plan DRP (RPO=4h, RTO=24h) | `docs/03-drp.md` | Fin S4 |
| Simulation de restauration | `docs/04-simulation-restauration.md` | Fin S4 |
| Rapport G10 | `docs/rapport-g10.md` | Fin S4 |

## Dépendances

- **G1 → G10** : Inventaire des services (base du guide technique)
- **G3 → G10** : Schémas d'architecture pour les docs
- **G4/G5/G6/G7/G8 → G10** : Synthèse de toute l'infrastructure déployée
- **G9 → G10** : Coûts et informations de facturation pour le guide

## Principes de la documentation

- Écrire pour quelqu'un qui n'a jamais vu le projet
- Chaque procédure doit être testée et reproductible
- Utiliser des captures d'écran ou sorties de commandes réelles
- Mettre à jour le document à chaque changement d'infrastructure
