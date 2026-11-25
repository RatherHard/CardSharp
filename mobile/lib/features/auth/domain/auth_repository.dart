import 'auth_user.dart';

/// 登录失败的原因。
///
/// 数据层只说「哪种失败」，不写给人看的中文文案——文案归展示层
/// （`AppStrings`），这样同一份 domain 代码将来接后端、做多语言都不用改。
enum AuthFailure {
  /// 账号或密码不正确。
  invalidCredentials,

  /// 其它未归类的失败（网络、服务端异常等）。
  unknown,
}

/// 登录失败异常。只携带 [failure]，由展示层翻译成文案。
class AuthException implements Exception {
  const AuthException(this.failure);

  final AuthFailure failure;

  @override
  String toString() => 'AuthException: $failure';
}

/// 认证数据源接口。
///
/// 形状按 `docs/02` FR-1.1 的最终形态保留（登录 / 登出 / 当前用户），
/// 本期实现是本地比对（`FakeAuthRepository`），后端 `/auth/*` 就绪后替换实现即可。
abstract interface class AuthRepository {
  /// 读取当前登录态。返回 null 表示未登录。
  ///
  /// 本期实现会读本地持久化的用户名，因此冷启动后仍是登录态。
  Future<AuthUser?> currentUser();

  /// 登录。失败抛 [AuthException]。
  Future<AuthUser> signIn({required String username, required String password});

  Future<void> signOut();
}
