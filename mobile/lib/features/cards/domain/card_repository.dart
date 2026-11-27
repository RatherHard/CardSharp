import '../../../core/network/page.dart';
import 'card.dart';
import 'trashed_card.dart';

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
  ///
  /// `docs/02` FR-2.5：**移入回收站**——打上 `deletedAt` 且不归任何卡片集批次，
  /// 于是在回收站顶层按「卡片」列出、并标注来源卡片集。
  Future<void> deleteCard(String id);

  /// 批量删除（多选模式用）。ids 中不存在的条目忽略，不抛异常。
  ///
  /// 同样是移入回收站（单独删除语义，不走卡片集批次）。
  Future<void> deleteCards(List<String> ids);

  /// 批量追加卡片（导入卡片集时用）。
  ///
  /// id 与排序由实现方分配；后续由数据源决定顺序，调用方不传 id。
  Future<void> addCards(String deckId, List<CardFields> cards);

  /// 用户单独删掉的卡片（`deletedWithDeck` 为空），按删除时间倒序。
  ///
  /// 每项带来源卡片集标题，回收站里直接显示，不用页面再查一次。
  Future<List<TrashedCard>> fetchStandaloneTrashedCards();

  /// 某个卡片集被删除时一并带走的卡片（`deletedWithDeck` = [deckId]），
  /// 按 `sortOrder` 升序。用于回收站里的卡片集详情。
  Future<List<Card>> fetchTrashedCardsOfDeck(String deckId);

  /// 把一张卡片从回收站恢复到 [targetDeckId]（原卡片集或新建的卡片集）。
  ///
  /// 清掉 `deletedAt` / `deletedWithDeck`，并把 `deckId` 改成 [targetDeckId]；
  /// 卡片不存在时抛 [CardException]（failure = [CardFailure.cardNotFound]）。
  Future<void> restoreCard(String cardId, {required String targetDeckId});

  /// 永久删除回收站里「单独删除」的卡片（物理删除，不可恢复）。
  ///
  /// 只删 `deletedAt` 非空且 `deletedWithDeck` 为空的卡片；不在回收站里的 id
  /// 直接忽略（幂等），不会误删正常卡片。
  Future<void> purgeCards(Iterable<String> cardIds);
}
