import 'package:cardsharp/features/search/domain/search_hit.dart';
import 'package:cardsharp/features/search/domain/search_service.dart';
import 'package:cardsharp/features/search/domain/search_source.dart';
import 'package:flutter_test/flutter_test.dart';

DeckSource _deck({
  String id = 'd1',
  String title = '奶蛙家族图鉴',
  String description = '按外形认角色',
  int cardCount = 8,
}) => DeckSource(id: id, title: title, description: description, cardCount: cardCount);

CardSource _cards(
  String deckTitle,
  List<({String id, String plaintext, String ciphertext})> cards,
) => CardSource(
  deckId: 'd1',
  deckTitle: deckTitle,
  cards: <CardSourceCard>[
    for (final c in cards)
      CardSourceCard(id: c.id, name: c.plaintext, plaintext: c.plaintext, ciphertext: c.ciphertext),
  ],
);

void main() {
  group('SearchService.searchDecks', () {
    test('名称命中：返回一条，并给出高亮区间', () {
      const SearchService service = SearchService();

      final SearchOutcome<DeckSearchHit> result = service.searchDecks(<DeckSource>[_deck()], '奶蛙');

      expect(result.hits, hasLength(1));
      expect(result.hits.first.titleRanges, <MatchRange>[const MatchRange(start: 0, end: 2)]);
      expect(result.hits.first.descriptionRanges, isEmpty);
      expect(result.totalMatches, 1);
    });

    test('简介命中：titleRanges 为空，descriptionRanges 有值', () {
      const SearchService service = SearchService();

      final SearchOutcome<DeckSearchHit> result = service.searchDecks(<DeckSource>[_deck()], '外形');

      expect(result.hits.single.titleRanges, isEmpty);
      expect(result.hits.single.descriptionRanges, hasLength(1));
    });

    test('都没命中时返回空', () {
      const SearchService service = SearchService();

      final SearchOutcome<DeckSearchHit> result = service.searchDecks(<DeckSource>[
        _deck(),
      ], '不存在的词');

      expect(result.hits, isEmpty);
      expect(result.totalMatches, 0);
      expect(result.hasMore, isFalse);
    });

    test('空关键词返回空结果，不报错', () {
      const SearchService service = SearchService();

      expect(service.searchDecks(<DeckSource>[_deck()], '').hits, isEmpty);
      expect(service.searchDecks(<DeckSource>[_deck()], '   ').hits, isEmpty);
    });

    test('忽略大小写', () {
      const SearchService service = SearchService();

      final SearchOutcome<DeckSearchHit> result = service.searchDecks(<DeckSource>[
        _deck(title: 'ABC 卡组'),
      ], 'abc');

      expect(result.hits, hasLength(1));
    });
  });

  group('SearchService.searchCards', () {
    test('明文命中：field 为 plaintext', () {
      const SearchService service = SearchService();
      final CardSource source = _cards('奶蛙', <({String id, String plaintext, String ciphertext})>[
        (id: 'c1', plaintext: '奶蛙的眼睛是什么颜色？', ciphertext: '绿色'),
      ]);

      final SearchOutcome<CardSearchHit> result = service.searchCards(<CardSource>[source], '眼睛');

      expect(result.hits.single.field, CardMatchField.plaintext);
      expect(result.hits.single.deckTitle, '奶蛙');
      expect(result.hits.single.cardId, 'c1');
    });

    test('只在暗文命中时 field 为 ciphertext', () {
      const SearchService service = SearchService();
      final CardSource source = _cards('奶蛙', <({String id, String plaintext, String ciphertext})>[
        (id: 'c1', plaintext: '奶蛙的眼睛是什么颜色？', ciphertext: '绿色，像豌豆'),
      ]);

      final SearchOutcome<CardSearchHit> result = service.searchCards(<CardSource>[source], '豌豆');

      expect(result.hits.single.field, CardMatchField.ciphertext);
      expect(result.hits.single.text, contains('豌豆'));
    });

    test('明文与暗文都命中时只出一条，优先明文', () {
      const SearchService service = SearchService();
      final CardSource source = _cards('奶蛙', <({String id, String plaintext, String ciphertext})>[
        (id: 'c1', plaintext: '奶蛙是绿色的吗', ciphertext: '是的，绿色'),
      ]);

      final SearchOutcome<CardSearchHit> result = service.searchCards(<CardSource>[source], '绿色');

      expect(result.hits, hasLength(1));
      expect(result.hits.single.field, CardMatchField.plaintext);
    });

    test('同一段文本里多次命中，区间全部返回', () {
      const SearchService service = SearchService();
      final CardSource source = _cards('奶蛙', <({String id, String plaintext, String ciphertext})>[
        (id: 'c1', plaintext: '奶蛙的奶蛙耳朵', ciphertext: '无'),
      ]);

      final SearchOutcome<CardSearchHit> result = service.searchCards(<CardSource>[source], '奶蛙');

      expect(result.hits.single.ranges, hasLength(2));
    });

    test('超过 hitLimit 时只返回前 N 条，但 totalMatches 是全量', () {
      const SearchService service = SearchService(hitLimit: 2);
      final CardSource source = _cards('奶蛙', <({String id, String plaintext, String ciphertext})>[
        (id: 'c1', plaintext: '奶蛙一', ciphertext: 'x'),
        (id: 'c2', plaintext: '奶蛙二', ciphertext: 'x'),
        (id: 'c3', plaintext: '奶蛙三', ciphertext: 'x'),
      ]);

      final SearchOutcome<CardSearchHit> result = service.searchCards(<CardSource>[source], '奶蛙');

      expect(result.hits, hasLength(2));
      expect(result.totalMatches, 3);
      expect(result.hasMore, isTrue);
    });

    test('达到扫描上限时标记 scanLimitReached', () {
      const SearchService service = SearchService(scanLimit: 2);
      final CardSource source = _cards('奶蛙', <({String id, String plaintext, String ciphertext})>[
        (id: 'c1', plaintext: '无', ciphertext: 'x'),
        (id: 'c2', plaintext: '无', ciphertext: 'x'),
        (id: 'c3', plaintext: '奶蛙', ciphertext: 'x'),
      ]);

      final SearchOutcome<CardSearchHit> result = service.searchCards(<CardSource>[source], '奶蛙');

      expect(result.scanLimitReached, isTrue);
      expect(result.scannedCount, 2);
      expect(result.hits, isEmpty);
    });

    test('空关键词返回空结果', () {
      const SearchService service = SearchService();
      final CardSource source = _cards('奶蛙', <({String id, String plaintext, String ciphertext})>[
        (id: 'c1', plaintext: '奶蛙', ciphertext: '绿色'),
      ]);

      expect(service.searchCards(<CardSource>[source], '').hits, isEmpty);
    });
  });

  group('SearchService.findAll', () {
    test('找出所有出现位置', () {
      expect(SearchService.findAll('abcabc', 'abc'), <MatchRange>[
        const MatchRange(start: 0, end: 3),
        const MatchRange(start: 3, end: 6),
      ]);
    });

    test('不重叠匹配', () {
      expect(SearchService.findAll('aaaa', 'aa'), hasLength(2));
    });

    test('空文本或空关键词返回空', () {
      expect(SearchService.findAll('', 'a'), isEmpty);
      expect(SearchService.findAll('abc', ''), isEmpty);
    });
  });
}
