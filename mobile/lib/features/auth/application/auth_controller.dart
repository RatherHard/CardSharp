import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_state.dart';
import 'use_cases/get_current_user_use_case.dart';
import 'use_cases/sign_in_use_case.dart';
import 'use_cases/sign_out_use_case.dart';

/// 认证实现注入点：接后端时把这里换成 `HttpAuthRepository(ref)` 即可。
final authRepositoryProvider = Provider<AuthRepository>((ref) => FakeAuthRepository());

/// 用例注入点。状态层只依赖用例，不直接碰仓储实现（`AGENTS.md` §5.2 分层约定）。
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>(
  (ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)),
);
final signInUseCaseProvider = Provider<SignInUseCase>(
  (ref) => SignInUseCase(ref.watch(authRepositoryProvider)),
);
final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);

/// 全局登录态。路由守卫与侧栏都读它。
final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final user = await ref.read(getCurrentUserUseCaseProvider).call();
    return user == null ? const AuthState.unauthenticated() : AuthState.authenticated(user: user);
  }

  /// 登录。返回 null 表示成功，否则返回可直接展示的错误文案。
  ///
  /// 失败时不把整个 state 变成 AsyncError：那会让路由守卫误以为「加载中」，
  /// 表现为登录页闪一下再回来；错误交给页面就地展示更稳。
  Future<String?> signIn({required String username, required String password}) async {
    try {
      final user = await ref
          .read(signInUseCaseProvider)
          .call(username: username, password: password);
      state = AsyncData(AuthState.authenticated(user: user));
      return null;
    } on AuthException catch (error) {
      state = const AsyncData(AuthState.unauthenticated());
      return error.message;
    }
  }

  Future<void> signOut() async {
    await ref.read(signOutUseCaseProvider).call();
    state = const AsyncData(AuthState.unauthenticated());
  }
}
