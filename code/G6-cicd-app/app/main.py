"""API FastAPI — État des services CDNU"""

import os
import boto3
import psycopg2
from datetime import datetime
from typing import Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = ""
    s3_bucket_prefix: str = "cdnu-cloud-prod-storage"
    aws_region: str = "eu-west-1"
    app_version: str = "1.0.0"

    class Config:
        env_file = ".env"


settings = Settings()

app = FastAPI(
    title="API État des Services CDNU",
    description="Supervise l'état des 10 Centres de Développement du Numérique Universitaire",
    version=settings.app_version,
)

CDNU_LIST = [
    "yaounde-1", "douala-1", "bafoussam-1", "ngaoundere-1", "garoua-1",
    "maroua-1", "ebolowa-1", "bertoua-1", "limbe-1", "buea-1"
]


class ServiceStatus(BaseModel):
    name: str
    status: str
    latency_ms: Optional[float] = None
    last_checked: str
    details: Optional[dict] = None


class HealthResponse(BaseModel):
    status: str
    version: str
    timestamp: str


def check_s3_bucket(cdnu_name: str) -> dict:
    """Vérifie l'accessibilité du bucket S3 d'un CDNU."""
    bucket_name = f"{settings.s3_bucket_prefix}-{cdnu_name}"
    try:
        s3 = boto3.client("s3", region_name=settings.aws_region)
        start = datetime.now()
        s3.head_bucket(Bucket=bucket_name)
        latency = (datetime.now() - start).total_seconds() * 1000
        return {"accessible": True, "bucket": bucket_name, "latency_ms": round(latency, 2)}
    except Exception as e:
        return {"accessible": False, "bucket": bucket_name, "error": str(e)}


def check_database() -> dict:
    """Vérifie la connectivité à la base de données PostgreSQL."""
    if not settings.database_url:
        return {"connected": False, "error": "DATABASE_URL non configurée"}
    try:
        start = datetime.now()
        conn = psycopg2.connect(settings.database_url, connect_timeout=5)
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        latency = (datetime.now() - start).total_seconds() * 1000
        conn.close()
        return {"connected": True, "latency_ms": round(latency, 2)}
    except Exception as e:
        return {"connected": False, "error": str(e)}


@app.get("/health", response_model=HealthResponse, tags=["Monitoring"])
def health_check():
    """Point de contrôle de santé de l'API — utilisé par l'ALB et Prometheus."""
    return HealthResponse(
        status="ok",
        version=settings.app_version,
        timestamp=datetime.utcnow().isoformat() + "Z",
    )


@app.get("/cdnu", response_model=list[ServiceStatus], tags=["CDNUs"])
def list_cdnu_status():
    """Retourne le statut de tous les 10 CDNUs (statut S3 uniquement pour les performances)."""
    results = []
    for cdnu in CDNU_LIST:
        s3_check = check_s3_bucket(cdnu)
        status = "healthy" if s3_check.get("accessible") else "degraded"
        results.append(ServiceStatus(
            name=f"cdnu-{cdnu}",
            status=status,
            latency_ms=s3_check.get("latency_ms"),
            last_checked=datetime.utcnow().isoformat() + "Z",
            details={"s3": s3_check},
        ))
    return results


@app.get("/cdnu/{cdnu_name}", response_model=ServiceStatus, tags=["CDNUs"])
def get_cdnu_status(cdnu_name: str):
    """Retourne le statut détaillé d'un CDNU spécifique (S3 + DB)."""
    if cdnu_name not in CDNU_LIST:
        raise HTTPException(
            status_code=404,
            detail=f"CDNU '{cdnu_name}' inconnu. CDNUs disponibles : {CDNU_LIST}"
        )

    s3_check = check_s3_bucket(cdnu_name)
    db_check = check_database()

    all_ok = s3_check.get("accessible") and db_check.get("connected")
    status = "healthy" if all_ok else ("degraded" if (s3_check.get("accessible") or db_check.get("connected")) else "down")

    return ServiceStatus(
        name=f"cdnu-{cdnu_name}",
        status=status,
        last_checked=datetime.utcnow().isoformat() + "Z",
        details={
            "s3": s3_check,
            "database": db_check,
        },
    )


@app.get("/metrics", tags=["Monitoring"])
def prometheus_metrics():
    """Endpoint métriques format Prometheus — consommé par G8."""
    lines = ["# HELP cdnu_status Statut des CDNUs (1=healthy, 0=down)", "# TYPE cdnu_status gauge"]
    for cdnu in CDNU_LIST:
        s3_ok = 1 if check_s3_bucket(cdnu).get("accessible") else 0
        lines.append(f'cdnu_status{{cdnu="{cdnu}",service="s3"}} {s3_ok}')
    db_ok = 1 if check_database().get("connected") else 0
    lines.append(f'cdnu_database_up{{}} {db_ok}')
    return "\n".join(lines)
