import '../../../core/network/page.dart';
import '../domain/card.dart';
import '../domain/card_repository.dart';
import '../domain/trashed_card.dart';

/// 种子卡片：按 deckId 分组的初始数据。
///
/// 本期为空——卡片文本由人直接提供后灌入（对应 `docs/02` 之外的演示数据，
/// 不来自后端）。接入后端时应改为从后端拉取，并关闭这份种子数据。
const Map<String, List<Card>> kSeedCards = <String, List<Card>>{};

/// 内存实现的卡片仓储，供 UI 开发与测试使用。
///
/// 删除是「移入回收站」语义（`docs/02` FR-2.5）：卡片从 `_cards` 挪到
/// `_trashed`，按 `deletedWithDeck` 区分「单独删」与「跟着卡片集删」。
class FakeCardRepository implements CardRepository {
  FakeCardRepository([Map<String, List<Card>> seed = kSeedCards, this.deckTitle])
    : _cards = <String, List<Card>>{
        for (final MapEntry<String, List<Card>> entry in seed.entries)
          entry.key: List<Card>.of(entry.value),
      };

  final Map<String, List<Card>> _cards;

  /// 回收站：卡片 id → (卡片, 删除时间, 跟着哪个卡片集走的；null = 单独删的)。
  final Map<String, ({Card card, DateTime deletedAt, String? withDeck})> _trashed =
      <String, ({Card card, DateTime deletedAt, String? withDeck})>{};

  /// 假实现内部的自增序号，仅用于生成可读的卡片 id。
  int _seq = 0;

  /// 回收站里要显示来源卡片集标题，假卡片集数据不在这个仓储里，靠回调拿。
  ///
  /// 测试里传 `(String deckId) => '卡片集1'`；不传时来源显示为空字符串。
  final String Function(String deckId)? deckTitle;

  /// 某卡片集下还活着的卡片数量。供假卡片集仓储展示用，接后端后由 `stats` 取代。
  ///
  /// 由组合根把它传给 `FakeDeckRepository`，避免两个假仓储互相 import。
  int countFor(String deckId) => _cards[deckId]?.length ?? 0;

  @override
  Future<PagedResult<Card>> fetchCards(String deckId, {String? cursor, int limit = 50}) async {
    final List<Card> all = List<Card>.of(_cards[deckId] ?? const <Card>[]);
    all.sort((Card a, Card b) => a.sortOrder.compareTo(b.sortOrder));

    // 假实现用「偏移量字符串」当游标；真实游标由后端生成，对客户端同样不透明。
    final int start = cursor == null ? 0 : int.tryParse(cursor) ?? 0;
    if (start >= all.length) {
      return const PagedResult<Card>(items: <Card>[]);
    }
    final int end = (start + limit).clamp(start, all.length);
    return PagedResult<Card>(
      items: List<Card>.unmodifiable(all.sublist(start, end)),
      nextCursor: end < all.length ? '$end' : null,
    );
  }

  @override
  Future<Card> updateCard(Card card) async {
    final List<Card>? cards = _cards[card.deckId];
    if (cards == null) {
      throw const CardException(CardFailure.deckNotFound);
    }
    final int index = cards.indexWhere((Card item) => item.id == card.id);
    if (index < 0) {
      throw const CardException(CardFailure.cardNotFound);
    }
    cards[index] = card;
    return card;
  }

  @override
  Future<void> deleteCard(String id) async {
    for (final MapEntry<String, List<Card>> entry in _cards.entries) {
      final int index = entry.value.indexWhere((Card item) => item.id == id);
      if (index >= 0) {
        final Card card = entry.value.removeAt(index);
        _trashed[id] = (card: card, deletedAt: DateTime.now(), withDeck: null);
        return;
      }
    }
    throw const CardException(CardFailure.cardNotFound);
  }

  @override
  Future<void> deleteCards(List<String> ids) async {
    final Set<String> targets = ids.toSet();
    final DateTime now = DateTime.now();
    for (final MapEntry<String, List<Card>> entry in _cards.entries) {
      final List<Card> kept = <Card>[];
      for (final Card card in entry.value) {
        if (targets.contains(card.id)) {
          _trashed[card.id] = (card: card, deletedAt: now, withDeck: null);
        } else {
          kept.add(card);
        }
      }
      entry.value
        ..clear()
        ..addAll(kept);
    }
  }

  @override
  Future<void> addCards(String deckId, List<CardFields> cards) async {
    final List<Card> target = _cards.putIfAbsent(deckId, () => <Card>[]);
    int order = target.length;
    for (final CardFields fields in cards) {
      target.add(
        Card(
          // 仅在假实现里自增 id：接后端后 id 由服务端分配，客户端不生成。
          id: '${deckId}_${_seq++}',
          deckId: deckId,
          fields: fields,
          sortOrder: order,
        ),
      );
      order++;
    }
  }

  @override
  Future<void> replaceCards(String deckId, List<CardFields> cards) async {
    // 权威版覆盖：先清掉该卡片集名下所有卡片——包括回收站里单独删的
    // 和跟着卡片集删的——再按权威顺序重建。
    _trashed.removeWhere(
      (String _, ({Card card, DateTime deletedAt, String? withDeck}) entry) =>
          entry.card.deckId == deckId,
    );
    final List<Card> rebuilt = <Card>[];
    for (int i = 0; i < cards.length; i++) {
      rebuilt.add(
        Card(
          // 仅在假实现里自增 id：接后端后 id 由服务端分配，客户端不生成。
          id: '${deckId}_${_seq++}',
          deckId: deckId,
          fields: cards[i],
          sortOrder: i,
        ),
      );
    }
    _cards[deckId] = rebuilt;
  }

  // ---- 回收站 ----------------------------------------------------------

  /// 假实现专用：模拟「删卡片集时把它下面的卡片一起带走」。
  ///
  /// 与 Local 实现一致：已经被单独删掉的卡片会被合并进这次删除（改批次标记、
  /// 保留原删除时间），仍活着的卡片取当前时间。
  void trashDeckCards(String deckId, {DateTime? at}) {
    final DateTime now = at ?? DateTime.now();
    final List<Card> cards = List<Card>.of(_cards[deckId] ?? const <Card>[]);
    _cards[deckId] = <Card>[];
    for (final Card card in cards) {
      _trashed[card.id] = (card: card, deletedAt: now, withDeck: deckId);
    }
    for (final MapEntry<String, ({Card card, DateTime deletedAt, String? withDeck})> entry
        in _trashed.entries.toList()) {
      if (entry.value.withDeck == null && entry.value.card.deckId == deckId) {
        _trashed[entry.key] = (
          card: entry.value.card,
          deletedAt: entry.value.deletedAt,
          withDeck: deckId,
        );
      }
    }
  }

  /// 假实现专用：模拟「恢复卡片集时只带回它带走的卡片」。
  void restoreDeckCards(String deckId) {
    for (final MapEntry<String, ({Card card, DateTime deletedAt, String? withDeck})> entry
        in _trashed.entries.toList()) {
      if (entry.value.withDeck != deckId) {
        continue;
      }
      _trashed.remove(entry.key);
      _cards.putIfAbsent(deckId, () => <Card>[]).add(entry.value.card);
    }
    _cards[deckId]?.sort((Card a, Card b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<List<TrashedCard>> fetchStandaloneTrashedCards() async {
    final List<TrashedCard> result = <TrashedCard>[];
    for (final ({Card card, DateTime deletedAt, String? withDeck}) entry in _trashed.values) {
      if (entry.withDeck != null) {
        continue;
      }
      result.add(
        TrashedCard(
          card: entry.card,
          deletedAt: entry.deletedAt,
          sourceDeckTitle: deckTitle?.call(entry.card.deckId) ?? '',
        ),
      );
    }
    result.sort((TrashedCard a, TrashedCard b) => b.deletedAt.compareTo(a.deletedAt));
    return List<TrashedCard>.unmodifiable(result);
  }

  @override
  Future<List<Card>> fetchTrashedCardsOfDeck(String deckId) async {
    final List<Card> result = <Card>[
      for (final ({Card card, DateTime deletedAt, String? withDeck}) entry in _trashed.values)
        if (entry.withDeck == deckId) entry.card,
    ]..sort((Card a, Card b) => a.sortOrder.compareTo(b.sortOrder));
    return List<Card>.unmodifiable(result);
  }

  @override
  Future<void> restoreCard(String cardId, {required String targetDeckId}) async {
    final ({Card card, DateTime deletedAt, String? withDeck})? entry = _trashed.remove(cardId);
    if (entry == null) {
      throw const CardException(CardFailure.cardNotFound);
    }
    _cards.putIfAbsent(targetDeckId, () => <Card>[]).add(entry.card.copyWith(deckId: targetDeckId));
  }

  @override
  Future<void> purgeCards(Iterable<String> cardIds) async {
    // 只抹掉「单独删」的卡片；跟着卡片集走的、以及正常卡片都不动。
    for (final String id in cardIds) {
      if (_trashed[id]?.withDeck == null) {
        _trashed.remove(id);
      }
    }
  }

  /// 假实现专用：模拟「永久删除卡片集时把它带走的卡片一起抹掉」。
  void purgeDeckCards(String deckId) {
    _trashed.removeWhere(
      (String _, ({Card card, DateTime deletedAt, String? withDeck}) entry) =>
          entry.withDeck == deckId,
    );
  }
}
