import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// 已登录用户的最小投影。
///
/// 本期只有 `id` 与 `username`：后端 `/auth/me` 会带邮箱、头像等字段，
/// 等契约固定后再扩，避免前端先编一套。
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({required String id, required String username}) = _AuthUser;
}
