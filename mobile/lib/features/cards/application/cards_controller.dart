import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_card_repository.dart';
import '../domain/card.dart';
import '../domain/card_repository.dart';

/// 注入点：接后端时把这里换成 `HttpCardRepository`，页面无需改动。
final Provider<CardRepository> cardRepositoryProvider = Provider<CardRepository>(
  (Ref ref) => FakeCardRepository(),
);

/// 某个卡片集下的卡片列表。参数为 deckId。
///
/// 用 `FutureProvider.family` 而不是自建 Notifier：本期页面只读，
/// 增删改后调 `ref.invalidate(cardsForDeckProvider(deckId))` 重新拉取即可；
/// 等到需要「多选状态 + 乐观更新」时再升级为 AsyncNotifier。
///
/// 这里不写显式类型：Riverpod 3 的 `FutureProviderFamily` 未从
/// `flutter_riverpod` 导出，写全类型会报 undefined_class。
final cardsForDeckProvider = FutureProvider.family<List<Card>, String>(
  (Ref ref, String deckId) => ref.watch(cardRepositoryProvider).fetchCards(deckId),
);

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
