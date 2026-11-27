import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 数据变更计数：任何「写入本地库」的动作之后自增。
///
/// 存在的理由：回收站计数、回收站列表这类**跨 feature 的派生数据**不该由每个写操作
/// 分别去 invalidate（decks 层 import trash 层、cards 层再 import trash 层，越缠越乱）。
/// 写操作只负责 `bump()`，需要感知变更的 Provider 各自 `watch` 这个计数即可。
final NotifierProvider<DataRevision, int> dataRevisionProvider =
    NotifierProvider<DataRevision, int>(DataRevision.new);

class DataRevision extends Notifier<int> {
  @override
  int build() => 0;

  /// 标记一次数据变更。值只增不减，用来触发依赖它的 Provider 重新计算。
  void bump() => state++;
}
