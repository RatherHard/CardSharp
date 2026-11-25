/// 后端统一错误体。
///
/// 契约来自 `docs/03` §6：错误响应是结构化的，带 `code` / `message` / `request_id`。
/// `request_id` 用于和后端对日志，出问题时报这个 id 就能定位。
///
/// 现阶段还没有 HTTP 实现，这个类型先建好：等 `HttpRepository` 接上后，
/// 把响应体解析成 [ApiError] 抛出，页面按 `code` 决定提示与跳转，
/// 不再一律显示「请重试」。
///
/// [message] 允许为 null：后端可能只给 `code`（例如网关返回的空体），
/// 这时由展示层退回 `AppStrings.unknownError`，而不是在数据层写死中文。
class ApiError implements Exception {
  const ApiError({required this.code, this.message, this.requestId});

  /// 业务错误码，例如 `DECK_NOT_FOUND`、`VALIDATION_FAILED`、`UNAUTHORIZED`。
  final String code;

  /// 后端已本地化的错误说明；为 null 表示后端没给。
  final String? message;

  /// 请求 id，用于和后端日志对照。
  final String? requestId;

  /// 从响应体解析。结构不符合契约时退化为未知错误，不抛二次异常。
  factory ApiError.fromJson(Map<String, dynamic> json) {
    final Object? payload = json['error'];
    if (payload is! Map<String, dynamic>) {
      return const ApiError(code: 'UNKNOWN');
    }
    return ApiError(
      code: payload['code'] as String? ?? 'UNKNOWN',
      message: payload['message'] as String?,
      requestId: payload['request_id'] as String?,
    );
  }

  /// 登录态失效：调用方应跳回登录页，而不是提示「请重试」。
  bool get isUnauthorized => code == 'UNAUTHORIZED' || code == 'TOKEN_EXPIRED';

  /// 资源不存在：例如卡片集已被其他设备删除。
  bool get isNotFound => code == 'NOT_FOUND' || code.endsWith('_NOT_FOUND');

  /// 入参校验失败：例如某张卡片超长，后端会说明具体字段。
  bool get isValidation => code == 'VALIDATION_FAILED' || code == 'UNPROCESSABLE_ENTITY';

  @override
  String toString() => 'ApiError($code: $message, requestId: $requestId)';
}
