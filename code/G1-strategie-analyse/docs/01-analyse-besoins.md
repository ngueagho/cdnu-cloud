# Analyse des besoins des 10 CDNUs

<!-- 
INSTRUCTIONS : Remplir chaque section pour chacun des 10 CDNUs.
Cible : 3-4 pages de ce document dans le rapport final.
-->

## 1. Contexte général

L'État du Cameroun a déployé 10 Centres de Développement du Numérique Universitaire (CDNU) sur l'ensemble du territoire national, interconnectés via le réseau interuniversitaire camerounais. Actuellement, les applications sont hébergées de manière fragmentée, sans mutualisation des ressources.

**Problèmes identifiés :**
- Gestion isolée de chaque centre → coûts élevés et maintenance difficile
- Absence de haute disponibilité → interruptions fréquentes des services
- Pas de procédure standardisée de sauvegarde
- Bande passante limitée dans certaines régions (ex : zones septentrionales)

---

## 2. Inventaire des CDNUs

| CDNU | Ville | Région | Université principale | Nbre estimé d'utilisateurs |
|------|-------|--------|----------------------|---------------------------|
| cdnu-yaounde-1 | Yaoundé | Centre | Université de Yaoundé I | ~15 000 |
| cdnu-douala-1 | Douala | Littoral | Université de Douala | ~12 000 |
| cdnu-bafoussam-1 | Bafoussam | Ouest | Université de Dschang | ~8 000 |
| cdnu-ngaoundere-1 | Ngaoundéré | Adamaoua | Université de Ngaoundéré | ~6 000 |
| cdnu-garoua-1 | Garoua | Nord | Université de Garoua | ~5 000 |
| cdnu-maroua-1 | Maroua | Extrême-Nord | Université de Maroua | ~5 000 |
| cdnu-ebolowa-1 | Ebolowa | Sud | Université du Sud | ~4 000 |
| cdnu-bertoua-1 | Bertoua | Est | Université de Bertoua | ~4 000 |
| cdnu-limbe-1 | Limbe | Sud-Ouest | Université de Buea | ~7 000 |
| cdnu-buea-1 | Buea | Sud-Ouest | Université de Buea (campus) | ~6 000 |

**Total estimé : ~72 000 utilisateurs**

---

## 3. Services actuellement utilisés par CDNU

<!-- Remplir via enquête / simulation -->

| Service | Description | État actuel | Priorité migration |
|---------|-------------|-------------|-------------------|
| Moodle LMS | Plateforme d'enseignement | Hébergé localement, version 3.x | Haute |
| Stockage fichiers | Documents pédagogiques | NAS local, pas de redondance | Haute |
| Visioconférence | Cours en ligne | BigBlueButton / Zoom | Moyenne |
| Annuaire LDAP | Authentification étudiants | Active Directory local | Haute |
| Messagerie | Email institutionnel | Postfix local | Faible |
| Site web | Portail université | Apache/WordPress | Faible |

---

## 4. Contraintes spécifiques au contexte camerounais

### 4.1 Bande passante
- Zones urbaines (Yaoundé, Douala) : fibre disponible, débit ~100 Mbps
- Zones septentrionales (Garoua, Maroua) : liaison satellite, débit ~10 Mbps, latence élevée (~600ms)
- **Implication** : L'architecture doit minimiser la dépendance au réseau WAN pour les opérations critiques

### 4.2 Souveraineté des données
- La loi camerounaise n°2010/012 impose que les données des citoyens soient accessibles aux autorités locales
- **Implication** : Préférer des datacenters en Europe/Afrique plutôt qu'US, considérer un cloud souverain

### 4.3 Coupures électriques
- Délestages fréquents dans plusieurs villes
- **Implication** : Les équipements locaux doivent avoir des UPS ; le cloud assure la continuité des services

### 4.4 Compétences techniques
- Équipes IT des CDNUs ont des niveaux variés
- **Implication** : Interfaces d'administration simples, formation nécessaire, documentation en français

---

## 5. Volumétrie estimée

| Métrique | Estimation annuelle |
|----------|---------------------|
| Utilisateurs actifs simultanés | ~5 000 (pic) |
| Données Moodle (cours, devoirs) | ~5 To croissance/an |
| Données vidéo (enregistrements cours) | ~20 To croissance/an |
| Requêtes API/jour | ~500 000 |
| Disponibilité requise | 99,5 % (hors maintenance) |

---

## 6. Synthèse des exigences

- **Disponibilité** : 99,5 % minimum — SLA 4h max d'interruption/mois
- **Performance** : Latence < 200ms depuis les CDNUs connectés en fibre
- **Sécurité** : Authentification SSO, chiffrement données au repos et en transit
- **Sauvegarde** : RPO = 4h, RTO = 24h (voir G10 pour le DRP complet)
- **Coût** : Budget annuel à estimer par G9, optimiser le right-sizing
