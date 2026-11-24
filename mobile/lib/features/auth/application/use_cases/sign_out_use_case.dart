import '../../domain/auth_repository.dart';

/// 退出登录用例：清掉登录态。接后端后还要顺带作废 refresh token，届时改实现即可。
final class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
