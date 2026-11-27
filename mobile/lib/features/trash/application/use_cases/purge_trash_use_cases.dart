import '../../../cards/domain/card_repository.dart';
import '../../../decks/domain/deck_repository.dart';

/// 永久删除回收站里的卡片集（不可恢复）。
///
/// 卡片集连同「被它一起删掉的卡片」一起从本地库抹掉；用户单独删的卡片
/// 不在这个批次里，会继续留在回收站。
final class PurgeDeckUseCase {
  const PurgeDeckUseCase(this._decks);

  final DeckRepository _decks;

  Future<void> call(String deckId) => _decks.purgeDeck(deckId);
}

/// 永久删除回收站里「单独删掉的卡片」（不可恢复）。
final class PurgeCardsUseCase {
  const PurgeCardsUseCase(this._cards);

  final CardRepository _cards;

  Future<void> call(Iterable<String> cardIds) => _cards.purgeCards(cardIds);
}
