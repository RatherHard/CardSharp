import '../../domain/deck_repository.dart';

/// 删除卡片集用例。
///
/// 本期是硬删除；`docs/02` FR-2.5 要求 30 天回收站，接后端时把语义改成
/// 「移入回收站」即可，页面层的确认对话框不用动。
final class DeleteDeckUseCase {
  const DeleteDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<void> call(String id) => _repository.deleteDeck(id);
}
