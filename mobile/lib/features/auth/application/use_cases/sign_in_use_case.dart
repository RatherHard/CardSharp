import '../../domain/auth_repository.dart';
import '../../domain/auth_user.dart';

/// 登录用例：把「账号密码 → 用户」这一步的语义固定下来。
///
/// 本期由 `FakeAuthRepository` 本地比对，后端就绪后只换注入的实现。
final class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({required String username, required String password}) =>
      _repository.signIn(username: username, password: password);
}
