import '../../../cards/domain/card_repository.dart';
import '../../domain/deck.dart';
import '../../domain/deck_import.dart';
import '../../domain/deck_repository.dart';

/// 导入一份卡片集：先建卡片集，再批量写入卡片。
///
/// 这是**应用层的编排**，不是领域能力：卡片集与卡片分属两个仓储，
/// 谁也不该知道对方的存在，所以由用例把两步串起来。
///
/// 带权威编号（`source_key`）的导入是「拉取云端权威版」的现在时态
/// （`BundledDeckLoader` 即当前拉取源，接后端后换成 Http 即可）：
/// - 书架里已有同编号卡片集 → 权威版整条覆盖（元数据 + 整集换卡）；
/// - 同编号只在回收站里 → 跳过并报 [DeckFailure.authorityInTrash]，
///   既不复活也不在书架里另建一条；
/// - 书架和回收站都没有 → 首次拉取，按新建处理。
///
/// 接后端时如果服务端提供原子导入端点（`POST /decks:import`），
/// 只需换掉仓储实现，本用例的调用方（页面）不用动。
final class ImportDeckUseCase {
  const ImportDeckUseCase(this._decks, this._cards);

  final DeckRepository _decks;
  final CardRepository _cards;

  Future<Deck> call(DeckImport data) async {
    final String? sourceKey = data.sourceKey;
    if (sourceKey != null) {
      final Deck? existing = await _decks.findVisibleDeckBySourceKey(sourceKey);
      if (existing != null) {
        return _overwrite(existing.id, data);
      }
      if (await _decks.hasTrashedDeckWithSourceKey(sourceKey)) {
        throw const DeckException(DeckFailure.authorityInTrash);
      }
    }

    // card_type / config 属于「建集」时可写字段，和标题一起创建（docs/03 §4.2、§4.3）。
    final Deck created = await _decks.createDeck(
      title: data.title,
      cardType: data.cardType,
      config: data.config,
      sourceKey: sourceKey,
    );
    // 只改需要改的字段；卡片数不在这里写——统计归服务端 `stats`，
    // 假实现由 `FakeDeckRepository.cardCounter` 在读取时补上。
    final Deck updated = await _decks.updateDeck(
      created.id,
      description: data.description,
      color: data.color,
    );
    await _cards.addCards(updated.id, data.cards);
    return updated;
  }

  /// 权威版覆盖本地缓存：先整条覆盖元数据，再把卡片整集换成权威版的。
  Future<Deck> _overwrite(String deckId, DeckImport data) async {
    final Deck updated = await _decks.overwriteDeck(
      deckId,
      title: data.title,
      description: data.description,
      color: data.color,
      cardType: data.cardType,
      config: data.config,
    );
    await _cards.replaceCards(updated.id, data.cards);
    return updated;
  }
}
