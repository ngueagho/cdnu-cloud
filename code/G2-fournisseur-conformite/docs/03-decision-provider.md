# Décision finale — Choix du fournisseur cloud

<!-- 
INSTRUCTIONS : Compléter ce document après avoir finalisé le comparatif (doc 01)
et l'analyse de conformité (doc 02). Ce document est le livrable clé de G2.
Il conditionne le travail de G3, G4 et G7.
-->

## Décision

**Fournisseur retenu : AWS (Amazon Web Services)**  
**Région principale : `eu-west-1` (Irlande) avec fallback `eu-west-3` (Paris)**

> *Pour le TP : si crédits AWS Educate disponibles → AWS. Sinon, utiliser LocalStack en simulation.*

---

## Justification

### Raisons techniques
1. **Richesse des services managés** : RDS, S3, ECR, Transit Gateway, Cognito — tous disponibles nativement en IaC Terraform
2. **Documentation et communauté** : La plus large base de ressources pédagogiques, tutoriels en français
3. **Terraform provider** : Le provider AWS est le plus mature et le mieux documenté
4. **Latence acceptable** : ~120ms depuis Yaoundé vers eu-west-1 — acceptable pour Moodle

### Raisons économiques
1. **Crédits AWS Educate** disponibles pour les étudiants (~100$/compte)
2. **Free Tier** couvre une grande partie du développement/test
3. **Coût mensuel estimé** : ~2 180$/mois pour 10 CDNUs en production (voir G9)

### Raisons de conformité
1. **ISO 27001 certifié** sur eu-west-1
2. **DPA RGPD** disponible et signable
3. **Données localisées en Europe** (Irlande) — hors portée directe des autorités camerounaises non-habilitées
4. **Mitigation Cloud Act** : chiffrement côté client avec clés gérées par MINESUP (AWS KMS)

---

## Conditions et garde-fous

| Condition | Mesure |
|-----------|--------|
| Souveraineté des données | Chiffrement KMS avec clés détenues par MINESUP |
| Cloud Act US | Données chiffrées côté client avant upload S3 |
| Latence zones septentrionales | Cache local + CDN CloudFront |
| Continuité si AWS indisponible | DRP avec backup exportable (G10) |

---

## Alternative recommandée

Si les contraintes budgétaires ou de souveraineté évoluent :  
→ **OVHcloud Public Cloud** (Terraform provider compatible, 30% moins cher, droit français)

---

## Impact sur les autres groupes

| Groupe | Impact de cette décision |
|--------|--------------------------|
| G3 | Architecture basée sur services AWS (VPC, Transit GW, RDS, S3, IAM) |
| G4 | Code Terraform avec `provider "aws"` — region `eu-west-1` |
| G5 | Services : `aws_s3_bucket`, `aws_db_instance`, `aws_ecr_repository` |
| G7 | IAM AWS, Security Groups, ACM pour les certificats TLS |
| G9 | Grille tarifaire AWS eu-west-1 pour les estimations |
