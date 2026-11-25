import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 登录态的本地存储端口。
///
/// 为什么单独抽接口：测试里用内存实现，避免依赖平台通道；
/// 将来接入真实登录后，把「用户名」换成「refresh token」只改实现。
abstract interface class AuthStorage {
  /// 读取已保存的用户名；null 表示未登录。
  Future<String?> readUsername();

  Future<void> writeUsername(String username);

  Future<void> clear();
}

/// 基于系统安全存储的实现（Android 走 Keystore 加密的文件）。
///
/// 只存用户名、不存密码：本期假登录不需要凭证；接后端后这里应该改成存
/// refresh token（access token 只放内存），密码永远不落盘。
class SecureAuthStorage implements AuthStorage {
  const SecureAuthStorage([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const String _usernameKey = 'auth.username';

  @override
  Future<String?> readUsername() => _storage.read(key: _usernameKey);

  @override
  Future<void> writeUsername(String username) => _storage.write(key: _usernameKey, value: username);

  @override
  Future<void> clear() => _storage.delete(key: _usernameKey);
}
