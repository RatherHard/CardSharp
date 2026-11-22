"""健康检查路由。"""

from __future__ import annotations

from typing import Any

import structlog
from fastapi import APIRouter, status
from fastapi.responses import ORJSONResponse

from app import __version__
from app.config import get_settings
from app.infra.db import check_connection

router = APIRouter(tags=["health"])
api_router = APIRouter(tags=["health"])

log = structlog.get_logger(__name__)


@router.get("/healthz", summary="存活探针")
async def healthz() -> dict[str, str]:
    """只表示进程存活，不检查依赖。"""
    return {"status": "ok", "version": __version__}


@api_router.get("/health", summary="就绪探针")
async def health() -> ORJSONResponse:
    """检查数据库连通性。任一依赖不可用返回 503。"""
    settings = get_settings()
    checks: dict[str, Any] = {}
    healthy = True

    try:
        checks["database"] = await check_connection()
    except Exception as exc:
        log.warning("health.database_failed", error=str(exc))
        checks["database"] = {"ok": False, "error": type(exc).__name__}
        healthy = False

    payload = {
        "status": "ok" if healthy else "degraded",
        "version": __version__,
        "environment": settings.environment,
        "checks": checks,
    }
    return ORJSONResponse(
        content=payload,
        status_code=status.HTTP_200_OK if healthy else status.HTTP_503_SERVICE_UNAVAILABLE,
    )
