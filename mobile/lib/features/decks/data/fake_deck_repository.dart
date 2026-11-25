import '../domain/deck.dart';
import '../domain/deck_repository.dart';

/// 本期种子数据：6 个空卡片集。
///
/// 卡片数一律为 0，因为真实数量由后端统计；客户端凭空算一个数只会在接后端时返工。
const List<Deck> kSeedDecks = <Deck>[
  Deck(id: '1', title: '卡片集1'),
  Deck(id: '2', title: '卡片集2'),
  Deck(id: '3', title: '卡片集3'),
  Deck(id: '4', title: '卡片集4'),
  Deck(id: '5', title: '卡片集5'),
  Deck(id: '6', title: '卡片集6'),
];

/// 内存实现的卡片集仓储，供 UI 开发与测试使用。
///
/// 接后端后新增 `HttpDeckRepository implements DeckRepository`，在
/// `deckRepositoryProvider` 处替换即可；页面、Notifier、用例都不动。
class FakeDeckRepository implements DeckRepository {
  FakeDeckRepository([List<Deck> seed = kSeedDecks])
    : _decks = List<Deck>.of(seed),
      _nextId = _computeNextId(seed);

  final List<Deck> _decks;
  int _nextId;

  @override
  Future<List<Deck>> fetchDecks() async => List<Deck>.unmodifiable(_decks);

  @override
  Future<Deck> createDeck({required String title}) async {
    final String normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', '卡片集名称不能为空');
    }

    final Deck deck = Deck(id: '${_nextId++}', title: normalizedTitle);
    _decks.add(deck);
    return deck;
  }

  @override
  Future<Deck> updateDeck(Deck deck) async {
    final int index = _decks.indexWhere((Deck item) => item.id == deck.id);
    if (index < 0) {
      throw StateError('卡片集不存在：${deck.id}');
    }
    _decks[index] = deck;
    return deck;
  }

  @override
  Future<void> deleteDeck(String id) async {
    final int index = _decks.indexWhere((Deck deck) => deck.id == id);
    if (index < 0) {
      throw StateError('卡片集不存在：$id');
    }
    _decks.removeAt(index);
  }

  /// 取现有数字 id 的最大值 + 1。
  ///
  /// 不能用 `length + 1`：删除过元素或 id 不连续时会撞号；非数字 id（将来的 UUID）
  /// 不参与计算，避免客户端替后端发明编号规则。
  static int _computeNextId(List<Deck> decks) {
    int max = 0;
    for (final Deck deck in decks) {
      final int? value = int.tryParse(deck.id);
      if (value != null && value > max) {
        max = value;
      }
    }
    return max + 1;
  }
}
