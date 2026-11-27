import '../../domain/deck_repository.dart';

/// 恢复卡片集用例（从回收站恢复）。
///
/// 语义见 `docs/decisions-trash.md`：卡片集本身恢复可见，**随它一起被删的卡片**
/// 也一起恢复；删除前就被用户单独删掉的卡片仍留在回收站。
final class RestoreDeckUseCase {
  const RestoreDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<void> call(String id) => _repository.restoreDeck(id);
}
