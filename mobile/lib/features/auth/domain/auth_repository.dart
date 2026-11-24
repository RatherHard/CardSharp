import 'auth_user.dart';

/// 登录失败：`message` 直接可以展示给用户，页面不需要再翻译错误码。
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

/// 认证数据源接口。
///
/// 形状按 `docs/02` FR-1.1 的最终形态保留（登录 / 登出 / 当前用户），
/// 本期实现是本地比对（`FakeAuthRepository`），后端 `/auth/*` 就绪后替换实现即可。
abstract interface class AuthRepository {
  /// 读取当前登录态。返回 null 表示未登录。
  Future<AuthUser?> currentUser();

  /// 登录。失败抛 [AuthException]。
  Future<AuthUser> signIn({required String username, required String password});

  Future<void> signOut();
}
