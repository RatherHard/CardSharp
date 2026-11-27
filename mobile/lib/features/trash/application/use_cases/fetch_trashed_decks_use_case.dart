import '../../../decks/domain/deck_repository.dart';
import '../../../decks/domain/trashed_deck.dart';

/// 读回收站里的卡片集（按删除时间倒序）。
final class FetchTrashedDecksUseCase {
  const FetchTrashedDecksUseCase(this._decks);

  final DeckRepository _decks;

  Future<List<TrashedDeck>> call() => _decks.fetchTrashedDecks();
}
