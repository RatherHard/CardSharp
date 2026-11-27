import '../../../core/network/page.dart';
import '../domain/deck.dart';
import '../domain/deck_repository.dart';
import '../domain/trashed_deck.dart';

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
/// 接后端后新增 `HttpDeckRepository implements DeckRepository`，在组合根
/// （`main.dart`）替换注入即可；页面、Notifier、用例都不动。
class FakeDeckRepository implements DeckRepository {
  FakeDeckRepository([List<Deck> seed = kSeedDecks, this.cardCounter])
    : _decks = List<Deck>.of(seed),
      _nextId = _computeNextId(seed);

  final List<Deck> _decks;
  int _nextId;

  /// 回收站：卡片集 id → (卡片集, 删除前在原列表里的位置, 删除时间)。
  ///
  /// 位置记下来是为了「恢复回原位」；真实实现靠 `created_at` 排序，
  /// 假实现没有创建时间字段，只能记住下标。
  final Map<String, ({Deck deck, int index, DateTime deletedAt})> _trashed =
      <String, ({Deck deck, int index, DateTime deletedAt})>{};

  /// 统计卡片数的回调，仅假实现使用：真实数量应由后端 `stats` 提供。
  ///
  /// 由组合根注入（`main.dart` 里传 `FakeCardRepository.countFor`），
  /// 这样假卡片集仓储不需要跨 feature 直接读卡片数据。
  int Function(String deckId)? cardCounter;

  /// 删除卡片集时的联动回调（测试里接 `FakeCardRepository.trashDeckCards`，
  /// 让卡片的批次标记跟上，和 Local 实现语义一致）。
  ///
  /// 用可变字段而不是构造参数：调用点大多是 `FakeDeckRepository(seed)` 的位置参数写法，
  /// 加命名参数会逼着所有老测试改签名。
  void Function(String deckId)? onDeleted;

  /// 恢复卡片集时的联动回调（接 `FakeCardRepository.restoreDeckCards`）。
  void Function(String deckId)? onRestored;

  /// 永久删除卡片集时的联动回调（接 `FakeCardRepository.purgeDeckCards`）。
  void Function(String deckId)? onPurged;

  @override
  Future<PagedResult<Deck>> fetchDecks({String? cursor, int limit = 20}) async {
    final int Function(String)? counter = cardCounter;
    final List<Deck> all = counter == null
        ? List<Deck>.of(_decks)
        : <Deck>[for (final Deck deck in _decks) deck.copyWith(cardCount: counter(deck.id))];

    // 假实现用「偏移量字符串」当游标。真实游标由后端生成，对客户端同样不透明。
    final int start = cursor == null ? 0 : int.tryParse(cursor) ?? 0;
    if (start >= all.length) {
      return const PagedResult<Deck>(items: <Deck>[]);
    }
    final int end = (start + limit).clamp(start, all.length);
    return PagedResult<Deck>(
      items: List<Deck>.unmodifiable(all.sublist(start, end)),
      nextCursor: end < all.length ? '$end' : null,
    );
  }

  @override
  Future<Deck> createDeck({
    required String title,
    String cardType = 'memory',
    Map<String, dynamic> config = const <String, dynamic>{},
  }) async {
    final String normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw const DeckException(DeckFailure.titleRequired);
    }

    final Deck deck = Deck(
      id: '${_nextId++}',
      title: normalizedTitle,
      cardType: cardType,
      config: config,
    );
    _decks.add(deck);
    return deck;
  }

  @override
  Future<Deck> updateDeck(String id, {String? title, String? description, String? color}) async {
    final int index = _decks.indexWhere((Deck item) => item.id == id);
    if (index < 0) {
      throw const DeckException(DeckFailure.notFound);
    }
    // 局部更新语义：只改传进来的字段，其余字段保持原值。
    final Deck current = _decks[index];
    final Deck updated = current.copyWith(
      title: title ?? current.title,
      description: description ?? current.description,
      color: color ?? current.color,
    );
    _decks[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteDeck(String id) async {
    final int index = _decks.indexWhere((Deck deck) => deck.id == id);
    if (index < 0) {
      throw const DeckException(DeckFailure.notFound);
    }
    final Deck deck = _decks.removeAt(index);
    _trashed[id] = (deck: deck, index: index, deletedAt: DateTime.now());
    onDeleted?.call(id);
  }

  @override
  Future<List<TrashedDeck>> fetchTrashedDecks() async {
    final List<TrashedDeck> result = <TrashedDeck>[
      for (final ({Deck deck, int index, DateTime deletedAt}) entry in _trashed.values)
        TrashedDeck(deck: entry.deck, deletedAt: entry.deletedAt),
    ]..sort((TrashedDeck a, TrashedDeck b) => b.deletedAt.compareTo(a.deletedAt));
    return List<TrashedDeck>.unmodifiable(result);
  }

  @override
  Future<void> restoreDeck(String id) async {
    final ({Deck deck, int index, DateTime deletedAt})? entry = _trashed.remove(id);
    if (entry == null) {
      throw const DeckException(DeckFailure.notFound);
    }
    final int at = entry.index.clamp(0, _decks.length);
    _decks.insert(at, entry.deck);
    onRestored?.call(id);
  }

  @override
  Future<void> purgeDeck(String id) async {
    // 不在回收站里（或已恢复、已抹掉）就当作无事发生，保持幂等。
    if (_trashed.remove(id) == null) {
      return;
    }
    onPurged?.call(id);
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
