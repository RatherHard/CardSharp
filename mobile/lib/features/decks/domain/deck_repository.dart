import 'deck.dart';

/// 卡片集数据源接口。
///
/// 本期实现是内存假数据（`FakeDeckRepository`）；后端 `/decks` 就绪后
/// 新增 `HttpDeckRepository` 并在 `deckRepositoryProvider` 处替换即可，
/// 页面与 Notifier 不动（对应 `docs/02` FR-2.x 的接口形状）。
abstract interface class DeckRepository {
  /// 拉取卡片集列表。返回顺序即展示顺序（本期由实现方决定，接后端后以后端为准）。
  Future<List<Deck>> fetchDecks();

  /// 新建卡片集。`id` 与统计字段由实现方（将来是后端）分配。
  Future<Deck> createDeck({required String title});

  /// 更新卡片集的可编辑字段：名称、简介、封面色。
  ///
  /// 其余字段（id、卡片数、归属）由实现方维护，调用方不得改写。
  Future<Deck> updateDeck(Deck deck);

  /// 删除卡片集。`docs/02` FR-2.5 要求进回收站，本期为就地删除。
  Future<void> deleteDeck(String id);
}
