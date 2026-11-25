import 'card.dart';

/// 卡片数据源接口。
///
/// 与 [DeckRepository] 同一套思路：页面只认这个接口，接后端时新增
/// `HttpCardRepository` 并替换 `cardRepositoryProvider` 即可，页面不动。
///
/// 本期（纯前端）只覆盖「读 + 改 + 删」；卡片创建属于后端制卡流水线
/// （`docs/02` E3），客户端不提供创建入口。
abstract interface class CardRepository {
  /// 拉取某个卡片集下的全部卡片，按 `sortOrder` 升序返回。
  Future<List<Card>> fetchCards(String deckId);

  /// 更新一张卡片（内容与排序都可能变）。
  Future<Card> updateCard(Card card);

  /// 删除一张卡片。
  Future<void> deleteCard(String id);

  /// 批量删除（多选模式用）。ids 中不存在的条目忽略，不抛异常。
  Future<void> deleteCards(List<String> ids);

  /// 批量追加卡片（导入卡片集时用）。
  ///
  /// id 与排序由实现方分配；后续由数据源决定顺序，调用方不传 id。
  Future<void> addCards(String deckId, List<CardFields> cards);
}
