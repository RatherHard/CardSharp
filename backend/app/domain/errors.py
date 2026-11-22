"""领域异常。业务错误统一继承 ``DomainError``，由异常处理器映射为 HTTP 状态码。"""

from __future__ import annotations


class DomainError(Exception):
    """领域异常基类。"""

    code: str = "DOMAIN_ERROR"
    http_status: int = 400
    message: str = "请求无法处理"

    def __init__(self, message: str | None = None, *, code: str | None = None) -> None:
        self.message = message or self.message
        if code:
            self.code = code
        super().__init__(self.message)


class NotFoundError(DomainError):
    code = "NOT_FOUND"
    http_status = 404
    message = "资源不存在"


class PermissionDeniedError(DomainError):
    code = "PERMISSION_DENIED"
    http_status = 403
    message = "没有权限执行该操作"


class ConflictError(DomainError):
    code = "CONFLICT"
    http_status = 409
    message = "资源状态冲突"


class ValidationError(DomainError):
    code = "VALIDATION_ERROR"
    http_status = 422
    message = "参数校验失败"


class RateLimitError(DomainError):
    code = "RATE_LIMITED"
    http_status = 429
    message = "请求过于频繁，请稍后再试"
