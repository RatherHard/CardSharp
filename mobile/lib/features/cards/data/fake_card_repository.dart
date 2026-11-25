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

  @override
  Future<List<Card>> fetchCards(String deckId) async {
    final List<Card> cards = List<Card>.of(_cards[deckId] ?? const <Card>[]);
    cards.sort((Card a, Card b) => a.sortOrder.compareTo(b.sortOrder));
    return List<Card>.unmodifiable(cards);
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
