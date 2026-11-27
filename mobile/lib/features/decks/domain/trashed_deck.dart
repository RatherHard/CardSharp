import 'deck.dart';

/// 回收站里的一条卡片集记录。
///
/// 只是「卡片集 + 删除时间」的组合，不新增业务字段：删除时间来自
/// `local_decks.deleted_at`，将来接后端就是 `decks.deleted_at`。
class TrashedDeck {
  const TrashedDeck({required this.deck, required this.deletedAt});

  final Deck deck;

  /// 用户点删除的时刻（本地时间）。回收站按它倒序分组。
  final DateTime deletedAt;
}
