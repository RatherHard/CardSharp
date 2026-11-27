import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/repository_providers.dart';
import '../../../core/state/data_revision.dart';
import '../../cards/application/cards_controller.dart';
import '../../cards/domain/card.dart';
import '../../cards/domain/trashed_card.dart';
import '../../decks/application/decks_controller.dart';
import '../../decks/domain/deck.dart';
import '../../decks/domain/trashed_deck.dart';
import 'use_cases/fetch_trashed_decks_use_case.dart';
import 'use_cases/purge_trash_use_cases.dart';
import 'use_cases/trash_card_use_cases.dart';

// ---------------------------------------------------------------- 用例注入点
final fetchTrashedDecksUseCaseProvider = Provider<FetchTrashedDecksUseCase>(
  (Ref ref) => FetchTrashedDecksUseCase(ref.watch(deckRepositoryProvider)),
);
final fetchStandaloneTrashedCardsUseCaseProvider = Provider<FetchStandaloneTrashedCardsUseCase>(
  (Ref ref) => FetchStandaloneTrashedCardsUseCase(ref.watch(cardRepositoryProvider)),
);
final fetchTrashedDeckCardsUseCaseProvider = Provider<FetchTrashedDeckCardsUseCase>(
  (Ref ref) => FetchTrashedDeckCardsUseCase(ref.watch(cardRepositoryProvider)),
);
final restoreCardUseCaseProvider = Provider<RestoreCardUseCase>(
  (Ref ref) => RestoreCardUseCase(ref.watch(cardRepositoryProvider)),
);
final purgeDeckUseCaseProvider = Provider<PurgeDeckUseCase>(
  (Ref ref) => PurgeDeckUseCase(ref.watch(deckRepositoryProvider)),
);
final purgeCardsUseCaseProvider = Provider<PurgeCardsUseCase>(
  (Ref ref) => PurgeCardsUseCase(ref.watch(cardRepositoryProvider)),
);

// ---------------------------------------------------------------- 只读数据
/// 回收站里的卡片集（按删除时间倒序）。
final trashedDecksProvider = FutureProvider<List<TrashedDeck>>((Ref ref) {
  // 写操作只 bump dataRevisionProvider，这里 watch 它就能自动重算。
  ref.watch(dataRevisionProvider);
  return ref.watch(fetchTrashedDecksUseCaseProvider).call();
});

/// 回收站里「单独删掉的卡片」（按删除时间倒序）。
final standaloneTrashedCardsProvider = FutureProvider<List<TrashedCard>>((Ref ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(fetchStandaloneTrashedCardsUseCaseProvider).call();
});

/// 某个卡片集被删除时一起带走的卡片（回收站里的卡片集详情）。
final trashedDeckCardsProvider = FutureProvider.family<List<Card>, String>((
  Ref ref,
  String deckId,
) {
  ref.watch(dataRevisionProvider);
  return ref.watch(fetchTrashedDeckCardsUseCaseProvider).call(deckId);
});

/// 侧边栏「回收站」的角标：卡片集数 + 单独删掉的卡片数。
final trashCountProvider = FutureProvider<int>((Ref ref) async {
  final List<TrashedDeck> decks = await ref.watch(trashedDecksProvider.future);
  final List<TrashedCard> cards = await ref.watch(standaloneTrashedCardsProvider.future);
  return decks.length + cards.length;
});

/// 回收站里的写操作。成功后统一失效相关列表，页面不用自己刷新。
final class TrashActions {
  TrashActions(this._ref);

  final Ref _ref;

  /// 恢复整个卡片集；跟着它被删的卡片一起回来。
  Future<void> restoreDeck(String id) async {
    await _ref.read(restoreDeckUseCaseProvider).call(id);
    _invalidateAll();
  }

  /// 恢复一张卡片到 [targetDeckId]（原卡片集或新建的卡片集）。
  Future<void> restoreCard(String cardId, {required String targetDeckId}) async {
    await _ref.read(restoreCardUseCaseProvider).call(cardId, targetDeckId: targetDeckId);
    _invalidateAll();
  }

  /// 恢复单个卡片时若选了「新建卡片集」，先建集再恢复卡片。
  Future<Deck> createDeckForRestore(String title) =>
      _ref.read(createDeckUseCaseProvider).call(title: title);

  /// 永久删除选中的卡片集（连同被它带走的卡片），不可恢复。
  Future<void> purgeDecks(Iterable<String> deckIds) async {
    for (final String id in deckIds) {
      await _ref.read(purgeDeckUseCaseProvider).call(id);
    }
    _invalidateAll();
  }

  /// 永久删除选中的「单独删掉的卡片」，不可恢复。
  Future<void> purgeCards(Iterable<String> cardIds) async {
    final List<String> ids = cardIds.toList();
    if (ids.isEmpty) {
      return;
    }
    await _ref.read(purgeCardsUseCaseProvider).call(ids);
    _invalidateAll();
  }

  void _invalidateAll() {
    _ref.invalidate(trashedDecksProvider);
    _ref.invalidate(standaloneTrashedCardsProvider);
    _ref.invalidate(trashedDeckCardsProvider);
    _ref.invalidate(trashCountProvider);
    // 恢复/永久删除后的数据要立刻反映到书架与详情页。
    _ref.invalidate(decksControllerProvider);
    _ref.invalidate(cardsForDeckProvider);
  }
}

final trashActionsProvider = Provider<TrashActions>(TrashActions.new);
