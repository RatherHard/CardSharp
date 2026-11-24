import '../../domain/deck.dart';
import '../../domain/deck_repository.dart';

/// 拉取卡片集列表用例：书架首页的唯一数据入口。
final class FetchDecksUseCase {
  const FetchDecksUseCase(this._repository);

  final DeckRepository _repository;

  Future<List<Deck>> call() => _repository.fetchDecks();
}
