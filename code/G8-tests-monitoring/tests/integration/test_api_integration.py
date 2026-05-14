"""
Tests d'intégration — vérification de l'API CDNU déployée.
Requiert une API en cours d'exécution (configurer API_BASE_URL).
"""

import os
import pytest
import requests

API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")

CDNU_LIST = [
    "yaounde-1", "douala-1", "bafoussam-1", "ngaoundere-1", "garoua-1",
    "maroua-1", "ebolowa-1", "bertoua-1", "limbe-1", "buea-1"
]


@pytest.fixture(scope="session")
def api_url():
    """Vérifie que l'API est accessible avant les tests."""
    try:
        r = requests.get(f"{API_BASE_URL}/health", timeout=5)
        assert r.status_code == 200, f"API non disponible sur {API_BASE_URL}"
    except requests.exceptions.ConnectionError:
        pytest.skip(f"API non accessible sur {API_BASE_URL} — tests d'intégration ignorés")
    return API_BASE_URL


class TestHealthEndpoint:
    def test_health_returns_200(self, api_url):
        r = requests.get(f"{api_url}/health", timeout=10)
        assert r.status_code == 200

    def test_health_response_structure(self, api_url):
        data = requests.get(f"{api_url}/health", timeout=10).json()
        assert "status" in data
        assert "version" in data
        assert "timestamp" in data
        assert data["status"] == "ok"

    def test_health_latency_acceptable(self, api_url):
        import time
        start = time.time()
        requests.get(f"{api_url}/health", timeout=10)
        latency_ms = (time.time() - start) * 1000
        assert latency_ms < 2000, f"Latence trop élevée : {latency_ms:.0f}ms (seuil 2000ms)"


class TestCDNUListEndpoint:
    def test_list_returns_200(self, api_url):
        r = requests.get(f"{api_url}/cdnu", timeout=15)
        assert r.status_code == 200

    def test_list_returns_10_cdnus(self, api_url):
        data = requests.get(f"{api_url}/cdnu", timeout=15).json()
        assert len(data) == 10, f"Attendu 10 CDNUs, reçu {len(data)}"

    def test_list_cdnu_structure(self, api_url):
        data = requests.get(f"{api_url}/cdnu", timeout=15).json()
        for item in data:
            assert "name" in item
            assert "status" in item
            assert "last_checked" in item
            assert item["status"] in ["healthy", "degraded", "down"]

    def test_all_cdnus_present(self, api_url):
        data = requests.get(f"{api_url}/cdnu", timeout=15).json()
        names = {item["name"].replace("cdnu-", "") for item in data}
        for cdnu in CDNU_LIST:
            assert cdnu in names, f"CDNU manquant dans la liste : {cdnu}"


class TestCDNUDetailEndpoint:
    @pytest.mark.parametrize("cdnu_name", CDNU_LIST)
    def test_each_cdnu_returns_200(self, api_url, cdnu_name):
        r = requests.get(f"{api_url}/cdnu/{cdnu_name}", timeout=10)
        assert r.status_code == 200, f"Erreur pour {cdnu_name}: {r.status_code}"

    def test_cdnu_detail_has_db_and_s3_info(self, api_url):
        data = requests.get(f"{api_url}/cdnu/yaounde-1", timeout=10).json()
        assert "details" in data
        details = data["details"]
        assert "s3" in details
        assert "database" in details

    def test_unknown_cdnu_returns_404(self, api_url):
        r = requests.get(f"{api_url}/cdnu/nonexistent-cdnu", timeout=10)
        assert r.status_code == 404


class TestMetricsEndpoint:
    def test_metrics_endpoint_accessible(self, api_url):
        r = requests.get(f"{api_url}/metrics", timeout=10)
        assert r.status_code == 200

    def test_metrics_contains_cdnu_status(self, api_url):
        text = requests.get(f"{api_url}/metrics", timeout=10).text
        assert "cdnu_status" in text

    def test_metrics_has_all_cdnus(self, api_url):
        text = requests.get(f"{api_url}/metrics", timeout=10).text
        for cdnu in CDNU_LIST:
            assert cdnu in text, f"CDNU {cdnu} absent des métriques Prometheus"
