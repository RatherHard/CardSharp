"""pytest 全局配置。"""

from __future__ import annotations

import os

import pytest

# 测试环境使用内存友好的默认配置，避免依赖真实服务
os.environ.setdefault("ENVIRONMENT", "local")
os.environ.setdefault("DEBUG", "false")


@pytest.fixture
def anyio_backend() -> str:
    return "asyncio"
