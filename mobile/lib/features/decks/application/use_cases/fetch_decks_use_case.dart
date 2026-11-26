import '../../../../core/network/page.dart';
import '../../domain/deck.dart';
import '../../domain/deck_repository.dart';

/// 拉取卡片集列表用例：书架首页的唯一数据入口。
///
/// 支持游标分页：不传 [cursor] 取第一页；`Page.nextCursor` 为 null 表示到底了。
final class FetchDecksUseCase {
  const FetchDecksUseCase(this._repository);

  /// 默认每页数量。与后端约定一致（`docs/03` §6 的 `limit=20`）。
  static const int kPageSize = 20;

  final DeckRepository _repository;

  Future<PagedResult<Deck>> call({String? cursor}) =>
      _repository.fetchDecks(cursor: cursor, limit: kPageSize);
}
