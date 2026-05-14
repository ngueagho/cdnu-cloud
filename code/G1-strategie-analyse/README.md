# G1 — Stratégie & Analyse

## Objectif

Comprendre le contexte actuel des 10 CDNUs, proposer une stratégie de migration vers le cloud et produire un inventaire complet des services à migrer.

## Livrables attendus

| Livrable | Fichier | Échéance |
|----------|---------|----------|
| Analyse des besoins des 10 CDNUs | `docs/01-analyse-besoins.md` | Fin S1 |
| Stratégie de migration | `docs/02-strategie-migration.md` | Fin S2 |
| Inventaire des services existants | `docs/03-inventaire-services.md` | Fin S3 |
| Rapport final G1 (15-20 pages) | `docs/rapport-g1.md` | Fin S4 |
| Slides présentation (15 min) | `presentation/` | Fin S4 |

## Dépendances

- **G1 → G2** : Transmettre les contraintes de conformité identifiées
- **G1 → G3** : Fournir les besoins en capacité réseau et services
- **G1 → G10** : L'inventaire servira de base à la documentation technique

## Activités clés

1. **Analyser les besoins** : Interviewer (simuler) les besoins de chaque CDNU
2. **Cartographier l'existant** : Lister tous les services actuels (Moodle, stockage, messagerie…)
3. **Proposer une stratégie** : Choisir entre Rehost (lift-and-shift), Replatform ou Refactor
4. **Évaluer les risques** : Contraintes bande passante au Cameroun, souveraineté des données

## Ressources utiles

- AWS Migration Acceleration Program (MAP)
- 6 R's de la migration cloud (Rehost, Replatform, Refactor, Repurchase, Retire, Retain)
- Rapport ITU sur la connectivité internet en Afrique centrale
- Plan stratégique MINESUP Cameroun 2030
