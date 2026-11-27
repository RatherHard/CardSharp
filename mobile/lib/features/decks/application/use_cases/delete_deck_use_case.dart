import '../../domain/deck_repository.dart';

/// 删除卡片集用例。
///
/// 语义是**移入回收站**（`docs/02` FR-2.5）：卡片集与其下所有卡片一起打上删除标记，
/// 用户在回收站里可以恢复。彻底删除与 30 天自动清理等接后端后再做。
final class DeleteDeckUseCase {
  const DeleteDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<void> call(String id) => _repository.deleteDeck(id);
}
