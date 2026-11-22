"""应用配置。所有配置项通过环境变量或 .env 注入，禁止硬编码。"""

from __future__ import annotations

from functools import lru_cache
from typing import Literal

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """全局配置。

    命名约定：环境变量使用大写下划线（如 ``DATABASE_URL``）。
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False,
    )

    # ---- 应用 ----
    app_name: str = "CardSharp API"
    environment: Literal["local", "staging", "prod"] = "local"
    debug: bool = False
    api_prefix: str = "/api/v1"

    # ---- 数据库 ----
    database_url: str = "postgresql+asyncpg://cardsharp:cardsharp@localhost:5432/cardsharp"
    db_pool_size: int = 20
    db_max_overflow: int = 10
    db_echo: bool = False

    # ---- Redis ----
    redis_url: str = "redis://localhost:6379/0"

    # ---- 认证 ----
    # 本地开发默认值；生产环境必须通过环境变量覆盖（openssl rand -hex 32）
    jwt_secret: str = "dev-only-change-me-in-production"  # noqa: S105
    jwt_algorithm: str = "HS256"
    access_token_ttl_minutes: int = 15
    refresh_token_ttl_days: int = 30

    # ---- LLM ----
    llm_base_url: str = "https://api.deepseek.com/v1"
    llm_api_key: str = ""
    llm_model_strong: str = "deepseek-chat"
    llm_model_fast: str = "deepseek-chat"
    llm_timeout_seconds: int = 120

    # ---- 嵌入 ----
    embedding_base_url: str = "http://localhost:8080"
    embedding_model: str = "bge-m3"
    embedding_dim: int = 1024

    # ---- 对象存储 ----
    s3_endpoint: str = "http://localhost:9000"
    s3_access_key: str = "dev"
    s3_secret_key: str = "devdevdev"  # noqa: S105
    s3_bucket: str = "cardsharp"
    s3_region: str = "us-east-1"

    # ---- CORS ----
    cors_origins: list[str] = Field(default_factory=lambda: ["http://localhost:3000"])

    @field_validator("database_url")
    @classmethod
    def _require_async_driver(cls, v: str) -> str:
        if v.startswith("postgresql://"):
            raise ValueError("请使用 postgresql+asyncpg:// 驱动")
        return v

    @property
    def is_prod(self) -> bool:
        return self.environment == "prod"


@lru_cache
def get_settings() -> Settings:
    """进程内单例。测试中可 ``get_settings.cache_clear()`` 重置。"""
    return Settings()
