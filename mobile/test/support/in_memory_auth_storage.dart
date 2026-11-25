import 'package:cardsharp/features/auth/data/auth_storage.dart';

/// 测试用的内存存储。
///
/// 真实实现走 `flutter_secure_storage`（Keychain / Keystore），单测里不可用，
/// 所以用一份内存实现来验证「登录态是否被写下去、退出是否被清掉」。
class InMemoryAuthStorage implements AuthStorage {
  String? _username;

  /// 当前保存的用户名，测试断言用。
  String? get username => _username;

  @override
  Future<String?> readUsername() async => _username;

  @override
  Future<void> writeUsername(String username) async => _username = username;

  @override
  Future<void> clear() async => _username = null;
}
