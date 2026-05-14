"""Tests unitaires de l'API CDNU — avec mocks pour AWS et DB"""

import pytest
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import app

client = TestClient(app)


class TestHealth:
    def test_health_returns_ok(self):
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"
        assert "version" in data
        assert "timestamp" in data

    def test_health_timestamp_format(self):
        response = client.get("/health")
        timestamp = response.json()["timestamp"]
        assert timestamp.endswith("Z")


class TestCDNUList:
    @patch("main.check_s3_bucket")
    def test_list_returns_10_cdnus(self, mock_s3):
        mock_s3.return_value = {"accessible": True, "latency_ms": 45.2}
        response = client.get("/cdnu")
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 10

    @patch("main.check_s3_bucket")
    def test_healthy_cdnu_status(self, mock_s3):
        mock_s3.return_value = {"accessible": True, "latency_ms": 30.0}
        response = client.get("/cdnu")
        assert all(item["status"] == "healthy" for item in response.json())

    @patch("main.check_s3_bucket")
    def test_degraded_when_s3_down(self, mock_s3):
        mock_s3.return_value = {"accessible": False, "error": "NoSuchBucket"}
        response = client.get("/cdnu")
        assert all(item["status"] == "degraded" for item in response.json())


class TestCDNUDetail:
    @patch("main.check_s3_bucket")
    @patch("main.check_database")
    def test_valid_cdnu_returns_details(self, mock_db, mock_s3):
        mock_s3.return_value = {"accessible": True, "latency_ms": 25.0}
        mock_db.return_value = {"connected": True, "latency_ms": 10.0}
        response = client.get("/cdnu/yaounde-1")
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "cdnu-yaounde-1"
        assert data["status"] == "healthy"
        assert "s3" in data["details"]
        assert "database" in data["details"]

    def test_unknown_cdnu_returns_404(self):
        response = client.get("/cdnu/inexistant")
        assert response.status_code == 404

    @patch("main.check_s3_bucket")
    @patch("main.check_database")
    def test_down_status_when_all_fail(self, mock_db, mock_s3):
        mock_s3.return_value = {"accessible": False}
        mock_db.return_value = {"connected": False}
        response = client.get("/cdnu/douala-1")
        assert response.json()["status"] == "down"


class TestMetrics:
    @patch("main.check_s3_bucket")
    @patch("main.check_database")
    def test_metrics_endpoint_returns_text(self, mock_db, mock_s3):
        mock_s3.return_value = {"accessible": True}
        mock_db.return_value = {"connected": True}
        response = client.get("/metrics")
        assert response.status_code == 200
        assert "cdnu_status" in response.text
