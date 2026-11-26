import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/service_providers.dart';

/// 某个卡片集的自定义封面路径（本地图片）；没有自定义封面时为 null。
///
/// 这里吞掉异常并当作「没有封面」：封面是本地增强能力，
/// 读失败（例如测试环境没注入实现）不应该让书架渲染不出来。
/// 用户主动操作（换图 / 移除）走的仍是同一个 service，失败会在页面上提示。
///
/// 不写显式类型：Riverpod 3 的 `FutureProviderFamily` 未从 `flutter_riverpod` 导出，
/// 与 `cardsForDeckProvider` 保持同样写法。
final deckCoverPathProvider = FutureProvider.family<String?, String>((
  Ref ref,
  String deckId,
) async {
  try {
    return await ref.watch(deckCoverServiceProvider).readCoverPath(deckId);
  } on Object {
    return null;
  }
});
