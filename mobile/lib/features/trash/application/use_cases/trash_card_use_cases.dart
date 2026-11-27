import '../../../cards/domain/card.dart';
import '../../../cards/domain/card_repository.dart';
import '../../../cards/domain/trashed_card.dart';

/// 读回收站里「用户单独删掉的卡片」（按删除时间倒序）。
final class FetchStandaloneTrashedCardsUseCase {
  const FetchStandaloneTrashedCardsUseCase(this._cards);

  final CardRepository _cards;

  Future<List<TrashedCard>> call() => _cards.fetchStandaloneTrashedCards();
}

/// 读某个卡片集被删除时一起带走的卡片（回收站里的卡片集详情用）。
final class FetchTrashedDeckCardsUseCase {
  const FetchTrashedDeckCardsUseCase(this._cards);

  final CardRepository _cards;

  Future<List<Card>> call(String deckId) => _cards.fetchTrashedCardsOfDeck(deckId);
}

/// 把一张卡片从回收站恢复到指定卡片集。
final class RestoreCardUseCase {
  const RestoreCardUseCase(this._cards);

  final CardRepository _cards;

  Future<void> call(String cardId, {required String targetDeckId}) =>
      _cards.restoreCard(cardId, targetDeckId: targetDeckId);
}
