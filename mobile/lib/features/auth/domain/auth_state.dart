import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user.dart';

part 'auth_state.freezed.dart';

/// 登录态。用 sealed union 而不是 `bool isLoggedIn`：
/// 「未登录 / 已登录（带用户）」是互斥的两态，编译期能强制穷尽处理。
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = AuthUnauthenticated;

  const factory AuthState.authenticated({required AuthUser user}) = AuthAuthenticated;
}
