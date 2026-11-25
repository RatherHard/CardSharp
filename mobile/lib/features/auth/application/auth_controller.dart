import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/repository_providers.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_state.dart';
import 'use_cases/get_current_user_use_case.dart';
import 'use_cases/sign_in_use_case.dart';
import 'use_cases/sign_out_use_case.dart';

/// 用例注入点。状态层只依赖用例与 domain 接口，不出现任何 data 层实现
/// （`AGENTS.md` §5.2 分层约定；仓储端口声明在 `core/di/repository_providers.dart`）。
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>(
  (Ref ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)),
);
final signInUseCaseProvider = Provider<SignInUseCase>(
  (Ref ref) => SignInUseCase(ref.watch(authRepositoryProvider)),
);
final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (Ref ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);

/// 全局登录态。路由守卫与侧栏都读它。
///
/// 冷启动时 `build()` 会问数据源「上次是谁」，因此登录态持久化在数据层完成，
/// 状态层与页面都不需要额外处理。
final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final user = await ref.read(getCurrentUserUseCaseProvider).call();
    return user == null ? const AuthState.unauthenticated() : AuthState.authenticated(user: user);
  }

  /// 登录。返回 null 表示成功，否则返回可直接交给展示层翻译的失败原因。
  ///
  /// 失败时不把整个 state 变成 AsyncError：那会让路由守卫误以为「加载中」，
  /// 表现为登录页闪一下再回来；错误交给页面就地展示更稳。
  Future<AuthFailure?> signIn({required String username, required String password}) async {
    try {
      final user = await ref
          .read(signInUseCaseProvider)
          .call(username: username, password: password);
      state = AsyncData(AuthState.authenticated(user: user));
      return null;
    } on AuthException catch (error) {
      state = const AsyncData(AuthState.unauthenticated());
      return error.failure;
    }
  }

  Future<void> signOut() async {
    await ref.read(signOutUseCaseProvider).call();
    state = const AsyncData(AuthState.unauthenticated());
  }
}
