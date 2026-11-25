import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../domain/development_account.dart';
import 'auth_storage.dart';

/// 本期假登录实现：与内置开发账号做本地比对，不访问任何网络。
///
/// 「登录态持久化」放在这一层，而不是状态层：登录态属于数据，谁登录了应该由
/// 数据源回答。`AuthStorage` 只存用户名（不是密码），冷启动时 `currentUser()`
/// 读到用户名即视为已登录——接后端后这里换成按 refresh token 换 access token。
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository([this._storage = const SecureAuthStorage()]);

  final AuthStorage _storage;

  @override
  Future<AuthUser?> currentUser() async {
    final String? username = await _storage.readUsername();
    if (username == null || username.trim().isEmpty) {
      return null;
    }
    return AuthUser(id: username, username: username);
  }

  @override
  Future<AuthUser> signIn({required String username, required String password}) async {
    final String normalizedUsername = username.trim();

    // 密码不做 trim：尾随空格属于用户输入错误，应当登录失败而不是被悄悄纠正。
    if (normalizedUsername != DevelopmentAccount.username ||
        password != DevelopmentAccount.password) {
      throw const AuthException(AuthFailure.invalidCredentials);
    }

    // id 用用户名：本期没有后端分配的稳定 id；接后端后由 `/auth/me` 提供。
    final AuthUser user = AuthUser(id: normalizedUsername, username: normalizedUsername);
    await _storage.writeUsername(user.username);
    return user;
  }

  @override
  Future<void> signOut() => _storage.clear();
}
