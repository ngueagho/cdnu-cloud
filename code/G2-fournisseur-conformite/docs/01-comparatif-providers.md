# Comparatif des fournisseurs cloud

## Fournisseurs évalués

1. **AWS** (Amazon Web Services)
2. **Microsoft Azure**
3. **Google Cloud Platform (GCP)**
4. **OVHcloud** (solution européenne souveraine)

---

## Tableau comparatif général

| Critère | AWS | Azure | GCP | OVHcloud |
|---------|-----|-------|-----|----------|
| **Datacenter Afrique** | Cape Town, Johannesburg | Johannesburg, Cape Town | Johannesburg | Paris, Roubaix (+ partenaires Afrique) |
| **Datacenter Europe** | Paris, Francfort, Dublin | Amsterdam, Paris, Francfort | Belgique, Pays-Bas | Paris, Roubaix, Gravelines |
| **Latence depuis Cameroun** | ~120ms (Paris) | ~125ms (Paris) | ~130ms (Belgique) | ~115ms (Paris) |
| **Disponibilité SLA** | 99,99% (EC2) | 99,99% (VM) | 99,99% (GCE) | 99,9% (Public Cloud) |
| **Crédits éducatifs** | AWS Educate (~100$/étudiant) | Azure for Students (100$) | Google for Education (300$) | Non |
| **Services managés** | Très large (200+) | Large (200+) | Large (150+) | Limité (50+) |
| **Terraform support** | Excellent (provider officiel) | Excellent | Excellent | Bon |
| **Documentation FR** | Complète | Complète | Partielle | Excellente |
| **ISO 27001** | Oui | Oui | Oui | Oui |
| **RGPD** | Conforme (DPA disponible) | Conforme | Conforme | Conforme (siège EU) |
| **Prix relatif** | Référence | +5% | -10% | -20% à -30% |
| **Support niveau 1** | Payant (dès 29$/mois) | Payant | Payant | Inclus |

---

## Analyse détaillée par critère

### 1. Présence géographique en Afrique

**AWS** dispose de la région `af-south-1` (Cape Town) depuis 2020, et d'edge locations à Lagos, Nairobi, Johannesburg. Pour le Cameroun, le routage passe par Paris (`eu-west-3`) avec une latence ~120ms.

**Azure** a lancé ses deux régions africaines en 2019 (Johannesburg + Cape Town). Présence à Yaoundé via partenaire (Afrimax).

**OVHcloud** n'a pas de datacenter en Afrique subsaharienne mais offre la latence la plus faible depuis la France (~115ms) et un coût réduit.

### 2. Conformité réglementaire (voir doc 02 pour le détail)

Tous les fournisseurs majeurs sont conformes au RGPD. Le point différenciateur est la **localisation des données** et le **droit applicable** en cas de litige — OVHcloud (droit français/européen) vs AWS/GCP (droit américain, Cloud Act).

### 3. Coût estimé (base 10 CDNUs, voir G9 pour le détail)

| Poste | AWS (eu-west-1) | OVHcloud |
|-------|-----------------|----------|
| Compute (10x t3.large) | ~$1,200/mois | ~$800/mois |
| RDS PostgreSQL Multi-AZ | ~$400/mois | ~$280/mois |
| S3 / Object Storage (10 To) | ~$230/mois | ~$100/mois |
| Réseau (Transit GW + NAT) | ~$350/mois | ~$150/mois |
| **Total estimé** | **~$2,180/mois** | **~$1,330/mois** |

---

## Matrice de décision (scoring 1-5)

| Critère | Poids | AWS | Azure | GCP | OVHcloud |
|---------|-------|-----|-------|-----|----------|
| Services disponibles | 25% | 5 | 5 | 4 | 3 |
| Coût | 20% | 3 | 3 | 4 | 5 |
| Conformité souveraineté | 20% | 3 | 3 | 3 | 5 |
| Crédits éducatifs | 15% | 5 | 5 | 5 | 1 |
| Latence Cameroun | 10% | 4 | 3 | 3 | 4 |
| Support FR | 10% | 3 | 4 | 3 | 5 |
| **Score pondéré** | | **3.8** | **3.8** | **3.7** | **3.9** |

<!-- 
À COMPLÉTER : justifier votre choix final dans docs/03-decision-provider.md
La décision doit tenir compte des crédits disponibles pour ce TP.
Pour le TP, AWS Educate est la solution la plus pratique si les crédits sont disponibles.
-->
