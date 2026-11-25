import '../../../core/network/page.dart';
import 'card.dart';

/// 卡片数据源的失败原因。
enum CardFailure {
  /// 目标卡片集不存在。
  deckNotFound,

  /// 目标卡片不存在（可能已被其它设备删除）。
  cardNotFound,
}

/// 卡片操作失败。只携带 [failure]，中文文案归展示层。
class CardException implements Exception {
  const CardException(this.failure);

  final CardFailure failure;

  @override
  String toString() => 'CardException: $failure';
}

/// 卡片数据源接口。
///
/// 与 [DeckRepository] 同一套思路：页面只认这个接口，接后端时新增
/// `HttpCardRepository` 并在组合根替换注入即可，页面不动。
///
/// 本期（纯前端）只覆盖「读 + 改 + 删」；卡片创建属于后端制卡流水线
/// （`docs/02` E3），客户端不提供创建入口。
abstract interface class CardRepository {
  /// 拉取某一页卡片（后端 `GET /decks/{id}/cards` 是分页的，`docs/03` §6）。
  ///
  /// 按 `sortOrder` 升序返回；[cursor] 为 null 表示第一页，
  /// 返回的 `nextCursor` 为 null 表示没有更多。
  Future<PagedResult<Card>> fetchCards(String deckId, {String? cursor, int limit});

  /// 更新一张卡片（内容与排序都可能变）。
  ///
  /// 卡片集或卡片不存在时抛 [CardException]。
  Future<Card> updateCard(Card card);

  /// 删除一张卡片。不存在时抛 [CardException]。
  Future<void> deleteCard(String id);

  /// 批量删除（多选模式用）。ids 中不存在的条目忽略，不抛异常。
  Future<void> deleteCards(List<String> ids);

  /// 批量追加卡片（导入卡片集时用）。
  ///
  /// id 与排序由实现方分配；后续由数据源决定顺序，调用方不传 id。
  Future<void> addCards(String deckId, List<CardFields> cards);
}
