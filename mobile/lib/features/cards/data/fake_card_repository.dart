import '../../../core/network/page.dart';
import '../domain/card.dart';
import '../domain/card_repository.dart';

/// 种子卡片：按 deckId 分组的初始数据。
///
/// 本期为空——卡片文本由人直接提供后灌入（对应 `docs/02` 之外的演示数据，
/// 不来自后端）。接入后端时应改为从后端拉取，并关闭这份种子数据。
const Map<String, List<Card>> kSeedCards = <String, List<Card>>{};

/// 内存实现的卡片仓储，供 UI 开发与测试使用。
class FakeCardRepository implements CardRepository {
  FakeCardRepository([Map<String, List<Card>> seed = kSeedCards])
    : _cards = <String, List<Card>>{
        for (final MapEntry<String, List<Card>> entry in seed.entries)
          entry.key: List<Card>.of(entry.value),
      };

  final Map<String, List<Card>> _cards;

  /// 假实现内部的自增序号，仅用于生成可读的卡片 id。
  int _seq = 0;

  /// 某卡片集下的卡片数量。供假卡片集仓储展示用，接后端后由 `stats` 取代。
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
      throw StateError('卡片集不存在：${card.deckId}');
    }
    final int index = cards.indexWhere((Card item) => item.id == card.id);
    if (index < 0) {
      throw StateError('卡片不存在：${card.id}');
    }
    cards[index] = card;
    return card;
  }

  @override
  Future<void> deleteCard(String id) async {
    for (final List<Card> cards in _cards.values) {
      final int index = cards.indexWhere((Card item) => item.id == id);
      if (index >= 0) {
        cards.removeAt(index);
        return;
      }
    }
    throw StateError('卡片不存在：$id');
  }

  @override
  Future<void> deleteCards(List<String> ids) async {
    final Set<String> targets = ids.toSet();
    for (final List<Card> cards in _cards.values) {
      cards.removeWhere((Card item) => targets.contains(item.id));
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
}
