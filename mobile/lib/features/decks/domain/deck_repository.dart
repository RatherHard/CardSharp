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

  /// 书架里已有同名卡片集。
  ///
  /// 判定口径：去首尾空格、不区分大小写；只和被**书架可见**的卡片集比
  /// （回收站里的不占名，所以删掉后可以立刻用原名新建）。
  duplicateTitle,

  /// 同编号的权威卡片集已经在回收站里。
  ///
  /// 拉取时只覆盖书架里可见的卡片集：命中回收站就跳过，既不复活它，
  /// 也不在书架里另建一条同编号的副本。
  authorityInTrash,
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
/// 有两份实现：`LocalDeckRepository`（Drift 本地库，手机上真正用的）与
/// `FakeDeckRepository`（测试用内存版）；后端 `/decks` 就绪后新增
/// `HttpDeckRepository` 并在组合根替换注入即可，
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
  /// [sourceKey] 是权威编号：只有「从权威版拉下来」的卡片集才有，
  /// 用户手工新建时传 null（这份卡片集暂时没有跨端身份）。
  /// 标题为空时抛 [DeckFailure.titleRequired]，书架已有同名时抛
  /// [DeckFailure.duplicateTitle]。
  Future<Deck> createDeck({
    required String title,
    String cardType = 'memory',
    Map<String, dynamic> config = const <String, dynamic>{},
    String? sourceKey,
  });

  /// 局部更新卡片集（对应后端 `PATCH /decks/{id}`，`docs/03` §6）。
  ///
  /// 只传需要改的字段，null 表示「不改」。**不能传整个 Deck 对象**：
  /// PATCH 是局部语义，整对象回传会把服务端的 stats / config / updated_at
  /// 覆盖成客户端的默认值。
  ///
  /// 改名撞上书架里另一条同名卡片集时抛 [DeckFailure.duplicateTitle]。
  Future<Deck> updateDeck(String id, {String? title, String? description, String? color});

  /// 用权威版整条覆盖本地缓存（编号命中时调用）。
  ///
  /// 与 [updateDeck] 的区别：这是「云端拉下来的权威版落库」，不是用户局部编辑，
  /// 所以 `title` / `description` / `color` / `cardType` / `config` 一律以权威版为准，
  /// 本地对这份卡片集的改动会被丢弃。卡片由调用方另用
  /// `CardRepository.replaceCards` 整集替换。
  ///
  /// 目标不在书架（或不存在）时抛 [DeckFailure.notFound]；
  /// 权威版标题撞上另一条可见卡片集时抛 [DeckFailure.duplicateTitle]。
  Future<Deck> overwriteDeck(
    String id, {
    required String title,
    required String description,
    required String color,
    required String cardType,
    required Map<String, dynamic> config,
  });

  /// 按权威编号查书架里可见的卡片集；没有（或只在回收站里）时返回 null。
  Future<Deck?> findVisibleDeckBySourceKey(String sourceKey);

  /// 回收站里是否有同编号的卡片集（拉取时用来跳过，避免复活或产生重复行）。
  Future<bool> hasTrashedDeckWithSourceKey(String sourceKey);

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
  /// 目标不存在时抛 [DeckFailure.notFound]；
  /// 恢复后标题会和书架里另一条卡片集重名时抛 [DeckFailure.duplicateTitle]（不恢复）。
  Future<void> restoreDeck(String id);

  /// 永久删除回收站里的卡片集（物理删除，不可恢复）。
  ///
  /// 只对「在回收站里」的卡片集生效：集本身连同 `deletedWithDeck == id` 的卡片
  /// 一起从库里抹掉；不在回收站或不存在时什么都不做（幂等）。
  Future<void> purgeDeck(String id);
}
