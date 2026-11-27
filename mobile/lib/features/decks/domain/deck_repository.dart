import '../../../core/network/page.dart';
import 'deck.dart';
import 'trashed_deck.dart';

/// 卡片集数据源的失败原因。
///
/// 与 [AuthFailure] 同样的约定：domain 只描述「哪种失败」，中文文案归展示层。
enum DeckFailure {
  /// 标题为空（新建或改名时）。
  titleRequired,

  /// 目标卡片集不存在（可能已被其它设备删除）。
  notFound,
}

/// 卡片集操作失败。只携带 [failure]。
class DeckException implements Exception {
  const DeckException(this.failure);

  final DeckFailure failure;

  @override
  String toString() => 'DeckException: $failure';
}

/// 卡片集数据源接口。
///
/// 本期实现是内存假数据（`FakeDeckRepository`）；后端 `/decks` 就绪后
/// 新增 `HttpDeckRepository` 并在组合根替换注入即可，
/// 页面与 Notifier 不动（对应 `docs/02` FR-2.x 的接口形状）。
abstract interface class DeckRepository {
  /// 拉取一页卡片集（`docs/03` §6：`?cursor=&limit=`）。
  ///
  /// [cursor] 为 null 表示第一页；返回的 `nextCursor` 为 null 表示没有更多。
  /// 游标是不透明字符串，客户端原样回传，不解析其内容。
  Future<PagedResult<Deck>> fetchDecks({String? cursor, int limit});

  /// 新建卡片集。`id` 与统计字段由实现方（将来是后端）分配。
  ///
  /// [cardType] 与 [config] 对应后端 `POST /decks` 里标题以外的可写字段
  /// （`docs/03` §4.2、§4.3）：导入时由文件提供，手工新建时用默认值。
  /// 标题为空时抛 [DeckException]（failure = [DeckFailure.titleRequired]）。
  Future<Deck> createDeck({
    required String title,
    String cardType = 'memory',
    Map<String, dynamic> config = const <String, dynamic>{},
  });

  /// 局部更新卡片集（对应后端 `PATCH /decks/{id}`，`docs/03` §6）。
  ///
  /// 只传需要改的字段，null 表示「不改」。**不能传整个 Deck 对象**：
  /// PATCH 是局部语义，整对象回传会把服务端的 stats / config / updated_at
  /// 覆盖成客户端的默认值。
  Future<Deck> updateDeck(String id, {String? title, String? description, String? color});

  /// 删除卡片集。`docs/02` FR-2.5：**移入回收站**，不是物理删除。
  ///
  /// 卡片集自己打上 `deletedAt`；它下面所有卡片（含更早单独删掉的）
  /// 一起标记成「被这次删除带走」，这样它们在回收站里只出现在这个集下面。
  /// 目标不存在时抛 [DeckException]（failure = [DeckFailure.notFound]）。
  Future<void> deleteDeck(String id);

  /// 回收站里的卡片集，按删除时间倒序。
  Future<List<TrashedDeck>> fetchTrashedDecks();

  /// 把卡片集从回收站恢复：集本身恢复可见，随它一起被删的卡片一起恢复。
  ///
  /// 删除前被用户单独删掉、之后又被合并进这次删除的卡片也算这次带走的，
  /// 会一起回来（合并语义见 `docs/decisions-trash.md`）。
  /// 目标不存在时抛 [DeckException]（failure = [DeckFailure.notFound]）。
  Future<void> restoreDeck(String id);

  /// 永久删除回收站里的卡片集（物理删除，不可恢复）。
  ///
  /// 只对「在回收站里」的卡片集生效：集本身连同 `deletedWithDeck == id` 的卡片
  /// 一起从库里抹掉；不在回收站或不存在时什么都不做（幂等）。
  Future<void> purgeDeck(String id);
}
