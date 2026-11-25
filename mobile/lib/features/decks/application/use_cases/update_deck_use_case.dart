import '../../domain/deck.dart';
import '../../domain/deck_repository.dart';

/// 局部更新卡片集用例（名称 / 简介 / 封面色）。
///
/// 与新建一样是薄壳：合法性由数据层把关，用例只固定「这一步业务叫什么」。
/// 只传需要改的字段，对应后端 `PATCH /decks/{id}` 的局部更新语义。
final class UpdateDeckUseCase {
  const UpdateDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Deck> call(String id, {String? title, String? description, String? color}) =>
      _repository.updateDeck(id, title: title, description: description, color: color);
}
