# G6 — CI/CD & Application exemple

## Objectif

Développer une API FastAPI "état des services" qui illustre l'utilisation de l'infrastructure (connexion RDS + accès S3), et automatiser son déploiement via un pipeline GitHub Actions.

## Livrables attendus

| Livrable | Fichier | Échéance |
|----------|---------|----------|
| API FastAPI fonctionnelle | `app/main.py` | Fin S2 |
| Dockerfile multi-stage | `app/Dockerfile` | Fin S2 |
| Tests unitaires | `app/tests/` | Fin S3 |
| Pipeline CI/CD GitHub Actions | `.github/workflows/deploy.yml` | Fin S3 |
| Rapport G6 | `docs/rapport-g6.md` | Fin S4 |

## Dépendances

- **G5 → G6** : `rds_endpoint`, `s3_bucket_arns`, `ecr_repository_url`
- **G7 → G6** : `iam_role_arn` pour l'application (accès S3 + RDS)
- **G6 → G8** : Fournir les endpoints API pour les tests de monitoring

## Tester l'API localement

```bash
cd G6-cicd-app/app

# Créer un environnement virtuel
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Variables d'environnement (sans base de données réelle)
export DATABASE_URL="postgresql://user:pass@localhost:5432/cdnu_db"
export S3_BUCKET_PREFIX="cdnu-cloud-prod-storage"
export AWS_DEFAULT_REGION="eu-west-1"

# Lancer l'API
uvicorn main:app --reload --port 8000

# Tester
curl http://localhost:8000/health
curl http://localhost:8000/cdnu
curl http://localhost:8000/cdnu/yaounde-1
```

## Pipeline CI/CD

Le pipeline se déclenche sur push vers `main` et exécute :
1. **Lint** : `flake8` + `black --check`
2. **Tests** : `pytest` avec rapport de couverture
3. **Build** : `docker build` image multi-stage
4. **Push ECR** : push vers le registre AWS
5. **Deploy** : mise à jour du service ECS/EC2

### Secrets GitHub Actions requis
```
AWS_ACCESS_KEY_ID       → credentials CI/CD (rôle limité)
AWS_SECRET_ACCESS_KEY
AWS_REGION              → eu-west-1
ECR_REPOSITORY_URL      → output de G5
```
