import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/repository_providers.dart';
import '../../../core/network/page.dart';
import '../domain/card.dart';
import '../domain/card_repository.dart';

/// 某个卡片集下的卡片列表。参数为 deckId。
///
/// 逐页拉取直到没有下一页：详情页的序号、全选、批量删除都依赖**完整**列表，
/// 半截数据会让「全选」只选中已加载的部分。卡片数量过大时再做滚动加载。
///
/// 这里不写显式类型：Riverpod 3 的 `FutureProviderFamily` 未从
/// `flutter_riverpod` 导出，写全类型会报 undefined_class。
final cardsForDeckProvider = FutureProvider.family<List<Card>, String>((
  Ref ref,
  String deckId,
) async {
  final CardRepository repository = ref.watch(cardRepositoryProvider);
  final List<Card> all = <Card>[];
  String? cursor;
  // 最多 20 页，避免后端游标异常时无限循环。
  for (int page = 0; page < 20; page++) {
    final PagedResult<Card> result = await repository.fetchCards(
      deckId,
      cursor: cursor,
      limit: _cardsPageSize,
    );
    all.addAll(result.items);
    cursor = result.nextCursor;
    if (cursor == null) {
      break;
    }
  }
  return List<Card>.unmodifiable(all);
});

/// 每页卡片数量。后端契约不强制，取一个详情页够用的值。
const int _cardsPageSize = 50;

/// 卡片写操作入口。页面不直接碰 Repository，统一经这一层收口，
/// 写完由这里负责让列表失效重拉，避免页面各写一套刷新逻辑。
final Provider<CardActions> cardActionsProvider = Provider<CardActions>(
  (Ref ref) => CardActions(ref),
);

class CardActions {
  CardActions(this._ref);

  final Ref _ref;

  Future<void> update(Card card) async {
    await _ref.read(cardRepositoryProvider).updateCard(card);
    _ref.invalidate(cardsForDeckProvider(card.deckId));
  }

  Future<void> delete(String deckId, String cardId) async {
    await _ref.read(cardRepositoryProvider).deleteCard(cardId);
    _ref.invalidate(cardsForDeckProvider(deckId));
  }

  /// 批量删除（多选模式）。空列表直接返回，不触发刷新。
  Future<void> deleteMany(String deckId, List<String> cardIds) async {
    if (cardIds.isEmpty) {
      return;
    }
    await _ref.read(cardRepositoryProvider).deleteCards(cardIds);
    _ref.invalidate(cardsForDeckProvider(deckId));
  }
}
