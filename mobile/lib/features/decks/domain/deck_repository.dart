import '../../../core/network/page.dart';
import 'deck.dart';

/// 卡片集数据源接口。
///
/// 本期实现是内存假数据（`FakeDeckRepository`）；后端 `/decks` 就绪后
/// 新增 `HttpDeckRepository` 并在 `deckRepositoryProvider` 处替换即可，
/// 页面与 Notifier 不动（对应 `docs/02` FR-2.x 的接口形状）。
abstract interface class DeckRepository {
  /// 拉取一页卡片集（`docs/03` §6：`?cursor=&limit=`）。
  ///
  /// [cursor] 为 null 表示第一页；返回的 `nextCursor` 为 null 表示没有更多。
  /// 游标是不透明字符串，客户端原样回传，不解析其内容。
  Future<PagedResult<Deck>> fetchDecks({String? cursor, int limit});

  /// 新建卡片集。`id` 与统计字段由实现方（将来是后端）分配。
  Future<Deck> createDeck({required String title});

  /// 局部更新卡片集（对应后端 `PATCH /decks/{id}`，`docs/03` §6）。
  ///
  /// 只传需要改的字段，null 表示「不改」。**不能传整个 Deck 对象**：
  /// PATCH 是局部语义，整对象回传会把服务端的 stats / config / updated_at
  /// 覆盖成客户端的默认值。
  Future<Deck> updateDeck(String id, {String? title, String? description, String? color});

  /// 删除卡片集。`docs/02` FR-2.5 要求进回收站，本期为就地删除。
  Future<void> deleteDeck(String id);
}
