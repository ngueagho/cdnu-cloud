# G8 — Tests & Monitoring

## Objectif

Écrire les tests d'intégration de l'API et déployer la stack de monitoring (Prometheus + Grafana) avec un dashboard affichant la santé en temps réel des 10 CDNUs.

## Livrables attendus

| Livrable | Fichier | Échéance |
|----------|---------|----------|
| Tests d'intégration API | `tests/integration/` | Fin S2 |
| Stack Prometheus + Grafana | `monitoring/docker-compose.yml` | Fin S3 |
| Règles d'alerte | `monitoring/prometheus/alert_rules.yml` | Fin S3 |
| Dashboard Grafana (10 CDNUs) | `monitoring/grafana/` | Fin S4 |
| Rapport G8 | `docs/rapport-g8.md` | Fin S4 |

## Dépendances

- **G6 → G8** : URL de l'API déployée (endpoints `/health`, `/cdnu`, `/metrics`)
- **G7 → G8** : Security Group monitoring pour autoriser les ports 9090/3000

## Lancer le monitoring localement

```bash
cd G8-tests-monitoring/monitoring
docker-compose up -d

# Prometheus : http://localhost:9090
# Grafana    : http://localhost:3000 (admin / voir .env)
# AlertManager : http://localhost:9093
```

## Exécuter les tests d'intégration

```bash
cd G8-tests-monitoring
pip install -r tests/requirements.txt

# Définir l'URL de l'API à tester
export API_BASE_URL=http://localhost:8000

pytest tests/integration/ -v --tb=short
```
