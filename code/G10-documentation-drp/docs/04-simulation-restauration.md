# Simulation de restauration — Scénarios de test

Ce document décrit les scénarios à simuler pour valider le DRP.  
Chaque simulation doit être réalisée en environnement de test (jamais en production).

---

## Scénario 1 : Failover automatique RDS (Multi-AZ)

**Objectif** : Vérifier que le basculement RDS est transparent pour l'application  
**RTO cible** : < 5 minutes  
**Fréquence** : Trimestrielle

### Procédure

```bash
# 1. Noter l'heure de début
echo "Début test: $(date)"

# 2. Vérifier que l'API fonctionne
watch -n 5 'curl -s http://localhost:8000/cdnu/yaounde-1 | python3 -m json.tool'

# 3. Déclencher le failover RDS (dans un autre terminal)
aws rds reboot-db-instance \
  --db-instance-identifier cdnu-cloud-prod-db \
  --force-failover

# 4. Observer la récupération automatique dans le monitoring Grafana
# 5. Mesurer le temps de rétablissement de la connexion DB

# 6. Valider que les données sont intactes
# (vérifier que des objets créés avant le failover sont toujours présents)
```

### Critères de succès
- [ ] La connexion DB est rétablie en < 5 minutes
- [ ] Aucune donnée n'est perdue
- [ ] Les logs applicatifs montrent la reconnexion automatique

---

## Scénario 2 : Suppression accidentelle d'objets S3

**Objectif** : Valider la restauration depuis le versioning S3  
**RPO cible** : 0 (versioning continu)  
**RTO cible** : < 30 minutes

### Procédure

```bash
# 1. Créer un fichier test
echo "Fichier test DRP - $(date)" > /tmp/test-drp.txt
aws s3 cp /tmp/test-drp.txt s3://cdnu-cloud-dev-storage-yaounde-1/test/drp-test.txt

# 2. Vérifier qu'il existe
aws s3 ls s3://cdnu-cloud-dev-storage-yaounde-1/test/

# 3. Supprimer le fichier (simulation d'une suppression accidentelle)
aws s3 rm s3://cdnu-cloud-dev-storage-yaounde-1/test/drp-test.txt

# 4. Constater la suppression
aws s3 ls s3://cdnu-cloud-dev-storage-yaounde-1/test/

# 5. Restaurer depuis le versioning
VERSION_ID=$(aws s3api list-object-versions \
  --bucket cdnu-cloud-dev-storage-yaounde-1 \
  --prefix test/drp-test.txt \
  --query 'Versions[0].VersionId' --output text)

aws s3api copy-object \
  --bucket cdnu-cloud-dev-storage-yaounde-1 \
  --copy-source "cdnu-cloud-dev-storage-yaounde-1/test/drp-test.txt?versionId=$VERSION_ID" \
  --key "test/drp-test.txt"

# 6. Vérifier la restauration
aws s3 cp s3://cdnu-cloud-dev-storage-yaounde-1/test/drp-test.txt /tmp/test-restaure.txt
cat /tmp/test-restaure.txt
```

### Critères de succès
- [ ] Le fichier est restauré avec son contenu original intact
- [ ] La procédure prend moins de 30 minutes
- [ ] L'opération est entièrement scriptable

---

## Scénario 3 : Perte complète d'un CDNU (simulation Terraform)

**Objectif** : Valider la recréation d'un VPC complet depuis le code IaC  
**RTO cible** : < 24 heures  
**Fréquence** : Annuelle (en environnement de test dédié)

### Procédure

```bash
# ATTENTION : Exécuter UNIQUEMENT sur l'environnement dev/test

# 1. Simuler la destruction du CDNU bertoua-1 (le moins critique pour le test)
cd G4-iac-reseau
terraform destroy \
  -target="module.vpc[\"bertoua-1\"]" \
  -target="module.subnets[\"bertoua-1\"]" \
  -auto-approve

# 2. Mesurer l'impact (G8 doit détecter le CDNU comme down)
curl http://localhost:8000/cdnu/bertoua-1
# Attendu : status "down"

# 3. Recréer depuis le code IaC
terraform apply \
  -target="module.vpc[\"bertoua-1\"]" \
  -target="module.subnets[\"bertoua-1\"]"

# 4. Mesurer le temps de recréation complète
# 5. Valider que le CDNU est de nouveau opérationnel
curl http://localhost:8000/cdnu/bertoua-1
# Attendu : status "healthy"
```

### Critères de succès
- [ ] Le CDNU est entièrement recréé depuis le code IaC
- [ ] La recréation prend moins de 24 heures
- [ ] Toutes les ressources (VPC, subnets, routes) sont correctement configurées
- [ ] Le monitoring G8 confirme le retour à la normale

---

## Registre des simulations effectuées

| Date | Scénario | Durée réelle | RTO mesuré | Résultat | Responsable |
|------|----------|-------------|------------|----------|-------------|
| À compléter | | | | | |
