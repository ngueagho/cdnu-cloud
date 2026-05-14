# Stratégie de migration vers le cloud

## 1. Approche retenue : les 6 R's

Pour chaque service, nous appliquons la méthodologie des **6 R's de migration cloud** :

| Stratégie | Définition | Services concernés |
|-----------|-----------|-------------------|
| **Rehost** (lift-and-shift) | Migration directe sans modification | Moodle LMS (phase 1) |
| **Replatform** | Migration avec optimisations mineures | Base de données → RDS managé |
| **Refactor** | Réécriture pour architecture cloud-native | API/services futurs |
| **Repurchase** | Remplacement par SaaS | Visioconférence → solution cloud |
| **Retire** | Suppression des services obsolètes | Anciens serveurs FTP |
| **Retain** | Maintien on-premise | Systèmes trop sensibles (LDAP initial) |

---

## 2. Phases de migration

### Phase 1 — Fondations (Semaines 1-2)
**Objectif** : Déployer l'infrastructure de base et migrer les services critiques

- [ ] Déploiement VPC + réseau (G4)
- [ ] Mise en place IAM et sécurité (G7)
- [ ] Migration Moodle (Rehost) vers instances EC2 + RDS
- [ ] Mise en place S3 pour le stockage des fichiers pédagogiques

### Phase 2 — Services managés (Semaines 3-4)
**Objectif** : Remplacer les services on-premise par des équivalents managés cloud

- [ ] Migration base de données vers RDS PostgreSQL Multi-AZ
- [ ] Déploiement registre de conteneurs (ECR)
- [ ] SSO via AWS Cognito ou solution compatible SAML
- [ ] Pipeline CI/CD opérationnel (G6)

### Phase 3 — Optimisation (Après TP)
**Objectif** : Affiner les performances et réduire les coûts

- [ ] Mise en place CDN (CloudFront) pour les ressources statiques
- [ ] Auto-scaling sur les instances Moodle
- [ ] Optimisation coûts RDS (reserved instances)
- [ ] Formation des équipes IT des CDNUs

---

## 3. Analyse des risques

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Perte de données pendant migration | Faible | Critique | Backup complet avant migration + validation |
| Interruption de service prolongée | Moyenne | Élevé | Migration en heures creuses, rollback plan |
| Bande passante insuffisante (zones N) | Élevée | Moyen | Réplication asynchrone, cache local |
| Dépassement budget cloud | Moyenne | Moyen | Alertes budget G9, right-sizing |
| Résistance au changement des utilisateurs | Élevée | Faible | Formation + documentation G10 |

---

## 4. Critères de succès

- [ ] Les 10 CDNUs accèdent à Moodle avec une latence < 300ms
- [ ] Disponibilité 99,5% sur 30 jours après migration
- [ ] Zéro perte de données pendant la migration
- [ ] Coût mensuel dans l'enveloppe budgétaire (estimé par G9)
- [ ] Équipes IT capables de gérer l'infra (formation validée)

---

## 5. Plan de rollback

En cas d'échec critique lors de la migration :

1. **Activation du rollback** : décision du coordinateur technique
2. **Remise en service on-premise** : restauration depuis backup pré-migration
3. **Post-mortem** : analyse des causes dans les 48h
4. **Révision du plan** : correction avant nouvelle tentative

> Durée estimée d'un rollback complet : 4-6 heures (RTO d'urgence)
