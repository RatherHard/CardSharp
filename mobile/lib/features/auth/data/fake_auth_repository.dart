import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../domain/development_account.dart';

/// 本期假登录实现：只与内置开发账号做本地比对，不访问任何网络。
///
/// 放在 data 层而不是 domain，是因为它只是接口的一种实现：接后端后用
/// `HttpAuthRepository` 整体替换，页面与状态层一行都不用改。
class FakeAuthRepository implements AuthRepository {
  AuthUser? _user;

  @override
  Future<AuthUser?> currentUser() async => _user;

  @override
  Future<AuthUser> signIn({required String username, required String password}) async {
    final String normalizedUsername = username.trim();

    // 密码不做 trim：尾随空格属于用户输入错误，应当登录失败而不是被悄悄纠正。
    if (normalizedUsername != DevelopmentAccount.username ||
        password != DevelopmentAccount.password) {
      throw const AuthException('用户名或密码不正确');
    }

    // id 用用户名：本期没有后端分配的稳定 id，登录态也不持久化。
    final AuthUser user = AuthUser(id: normalizedUsername, username: normalizedUsername);
    _user = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }
}
