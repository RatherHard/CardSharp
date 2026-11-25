import '../../../cards/domain/card.dart';
import '../../../cards/domain/card_repository.dart';
import '../../domain/deck.dart';
import '../../domain/deck_import.dart';
import '../../domain/deck_repository.dart';

/// 导入一份卡片集：先建卡片集，再批量写入卡片。
///
/// 这是**应用层的编排**，不是领域能力：卡片集与卡片分属两个仓储，
/// 谁也不该知道对方的存在，所以由用例把两步串起来。
///
/// 接后端时如果服务端提供原子导入端点（`POST /decks:import`），
/// 只需换掉仓储实现，本用例的调用方（页面）不用动。
final class ImportDeckUseCase {
  const ImportDeckUseCase(this._decks, this._cards);

  final DeckRepository _decks;
  final CardRepository _cards;

  Future<Deck> call(DeckImport data) async {
    final Deck created = await _decks.createDeck(title: data.title);
    final Deck updated = await _decks.updateDeck(
      created.copyWith(
        description: data.description,
        color: data.color,
        // 假仓储没有服务端统计，这里先用导入数量填上，避免列表显示 0。
        // 接后端后 cardCount 一律以服务端 stats 为准，这一行应删除。
        cardCount: data.cards.length,
      ),
    );
    await _cards.addCards(updated.id, <CardFields>[
      for (final ImportedDeckCard card in data.cards)
        CardFields(
          plaintext: card.plaintext,
          ciphertext: card.ciphertext,
          hint: card.hint,
          extra: card.extra,
        ),
    ]);
    return updated;
  }
}
