import '../../domain/auth_repository.dart';
import '../../domain/auth_user.dart';

/// 读取当前登录用户：应用启动时用它决定初始路由。
///
/// 单独成层是为了让状态层只描述「业务流程」，不直接知道数据从哪来；
/// 接后端时换 [AuthRepository] 的实现即可，本文件不动。
final class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser?> call() => _repository.currentUser();
}
