import '../../domain/deck.dart';
import '../../domain/deck_repository.dart';

/// 新建卡片集用例。
///
/// 名称校验放在数据层（空名抛 [DeckFailure.titleRequired]、重名抛
/// [DeckFailure.duplicateTitle]），这里保持薄壳：
/// 用例层只负责「这一步业务叫什么」，具体约束由实现给出。
final class CreateDeckUseCase {
  const CreateDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Deck> call({required String title}) => _repository.createDeck(title: title);
}
