# Conformité réglementaire : RGPD, loi camerounaise & ISO 27001

## 1. Cadre réglementaire applicable

### 1.1 Réglementation camerounaise

**Loi n°2010/012 du 21 décembre 2010** relative à la cybersécurité et à la cybercriminalité :
- Obligation de protéger les données personnelles des citoyens camerounais
- Les opérateurs doivent notifier les violations de données aux autorités compétentes
- Conservation des données de connexion pendant 12 mois minimum

**Loi n°2010/013 du 21 décembre 2010** régissant les communications électroniques au Cameroun :
- Les fournisseurs de services doivent garantir la confidentialité des communications
- Obligation d'interception légale pour les forces de l'ordre

**Agence Nationale des Technologies de l'Information et de la Communication (ANTIC)** :
- Organe de régulation — tout hébergement de données camerounaises doit être notifié
- Recommande la localisation des données sensibles en territoire africain ou européen

### 1.2 RGPD (applicable aux partenariats avec l'UE)

Bien que le Cameroun ne soit pas membre de l'UE, les universités reçoivent des financements européens et échangent des données avec des partenaires EU. Le RGPD s'applique par extension aux traitements impliquant des données de ressortissants européens.

**Obligations principales :**
- Consentement explicite pour la collecte de données personnelles
- Droit à l'effacement (droit à l'oubli)
- Notification des violations dans les 72h
- Nomination d'un DPO (Data Protection Officer) si traitement à grande échelle

### 1.3 ISO 27001

Norme internationale de management de la sécurité de l'information.

**Contrôles pertinents pour ce projet :**

| Contrôle ISO 27001 | Implementation dans le projet |
|-------------------|-------------------------------|
| A.9 Contrôle d'accès | IAM roles + moindre privilège (G7) |
| A.10 Cryptographie | Chiffrement S3 + RDS + TLS (G7) |
| A.12 Sécurité opérationnelle | Monitoring + logs (G8) |
| A.13 Sécurité des communications | VPC + Security Groups (G4/G7) |
| A.17 Continuité d'activité | Plan DRP RPO=4h / RTO=24h (G10) |

---

## 2. Analyse par fournisseur cloud

### AWS

- **Certifications** : ISO 27001, SOC 2 Type II, PCI DSS, RGPD
- **Accord de traitement des données (DPA)** : Disponible et signable
- **Localisation des données** : Configurable — choisir `eu-west-1` (Irlande) ou `eu-west-3` (Paris)
- **Cloud Act américain** : ⚠️ AWS est soumis au Cloud Act US — les autorités américaines peuvent théoriquement accéder aux données
- **Mitigation** : Chiffrement côté client (données illisibles sans la clé)

### OVHcloud

- **Certifications** : ISO 27001, SecNumCloud (certification ANSSI française)
- **Droit applicable** : Droit français/européen exclusivement
- **Cloud Act** : ✅ Non soumis (siège en France)
- **Hébergement RGPD** : Natif — OVH est recommandé par la CNIL pour certains traitements sensibles

---

## 3. Recommandations de conformité pour le projet

### Données sensibles à identifier

| Type de donnée | Sensibilité | Traitement recommandé |
|----------------|-------------|----------------------|
| Notes et résultats d'examen | Haute | Chiffrement AES-256, accès restreint |
| Données personnelles étudiants | Haute | Pseudonymisation, consentement |
| Contenu pédagogique | Moyenne | Chiffrement au repos |
| Logs applicatifs | Faible | Anonymisation des IPs |
| Données administratives | Moyenne | Contrôle d'accès strict |

### Mesures techniques obligatoires

```
✅ Chiffrement au repos : S3 SSE-S3/KMS + RDS StorageEncrypted=true
✅ Chiffrement en transit : TLS 1.2 minimum sur tous les endpoints
✅ Gestion des accès : IAM avec moindre privilège (G7)
✅ Journalisation : CloudTrail + CloudWatch Logs (G8)
✅ Sauvegarde : Backup quotidien, rétention 30 jours minimum
✅ Isolation réseau : VPC privés, pas d'exposition directe des DBs
```

### Checklist conformité avant mise en production

- [ ] DPA signé avec le fournisseur cloud choisi
- [ ] Notification dépôt à l'ANTIC (Cameroun)
- [ ] Politique de confidentialité mise à jour pour les utilisateurs
- [ ] DPO désigné (ou équivalent institutionnel)
- [ ] Procédure de notification de violation documentée (G10)
- [ ] Test annuel de la procédure de restauration (G10)
