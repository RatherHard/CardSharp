import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 本期的当前用户 id（内置测试账号）。
///
/// 接后端后由 JWT 提供；组合根在 `ProviderScope` 建立之前需要它，
/// 所以这里同时暴露一个常量，避免两处各写一份字符串。
const String kCurrentUserId = 'test';

/// 当前用户 id：本地缓存的「分库键」。
///
/// 现在恒为内置测试账号；接后端后改为从 JWT 取用户 id，
/// 其余代码（数据库路径、仓储、页面）都不用改——
/// 这就是「单用户先写、多用户后改」留的钩子。
final Provider<String> currentUserIdProvider = Provider<String>((ref) => kCurrentUserId);

/// 把用户 id 转成安全的文件名片段。
///
/// 真实用户 id 可能是邮箱/UUID，直接拼进路径会遇到 `/`、空格、中文；
/// 这里只保留 `[A-Za-z0-9_-]`，其余字符用稳定的哈希兜底。
String databaseFileNameFor(String userId) {
  final String sanitized = userId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');
  if (sanitized.isNotEmpty) {
    return 'cache_$sanitized.db';
  }
  // FNV-1a：跨进程稳定，避免使用 String.hashCode（不同运行可能不同）。
  int hash = 0x811C9DC5;
  for (final int code in userId.codeUnits) {
    hash ^= code;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return 'cache_${hash.toRadixString(16)}.db';
}
