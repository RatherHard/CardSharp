import '../../domain/deck.dart';
import '../../domain/deck_repository.dart';

/// 更新卡片集用例（名称 / 简介 / 封面色）。
///
/// 与新建一样是薄壳：合法性由数据层把关，用例只固定「这一步业务叫什么」。
final class UpdateDeckUseCase {
  const UpdateDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Deck> call(Deck deck) => _repository.updateDeck(deck);
}
