import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:flutter_test/flutter_test.dart';

/// 契约测试：`decks` 的 JSON 用下划线命名（`docs/03` §4.2）。
void main() {
  group('Deck JSON 契约', () {
    test('能解析后端返回的下划线键名', () {
      final Deck deck = Deck.fromJson(<String, dynamic>{
        'id': 'd1',
        'title': '生物学',
        'description': '细胞结构',
        'color': '#5B5BD6',
        'card_count': 12,
      });

      expect(deck.title, '生物学');
      expect(deck.description, '细胞结构');
      expect(deck.color, '#5B5BD6');
      // 卡片数不来自 JSON：统计归后端 stats，客户端字段只用于展示。
      expect(deck.cardCount, 0);
      expect(deck.cardType, 'memory');
    });

    test('卡片数不参与序列化往返', () {
      const Deck deck = Deck(id: 'd1', title: 't', cardCount: 3);

      final Map<String, dynamic> json = deck.toJson();

      expect(json.containsKey('card_count'), isFalse);
      expect(json.containsKey('cardCount'), isFalse);
    });

    test('能解析后端补充的字段（card_type / folder_id / config / stats）', () {
      final Deck deck = Deck.fromJson(<String, dynamic>{
        'id': 'd1',
        'title': 't',
        'card_type': 'memory',
        'folder_id': 'f1',
        'config': <String, dynamic>{'daily_new': 20},
        'stats': <String, dynamic>{'total': 12},
      });

      expect(deck.cardType, 'memory');
      expect(deck.folderId, 'f1');
      expect(deck.config['daily_new'], 20);
      expect(deck.stats['total'], 12);
    });

    test('可选字段缺失时用默认值', () {
      final Deck deck = Deck.fromJson(<String, dynamic>{'id': 'd1', 'title': 't'});

      expect(deck.description, '');
      expect(deck.color, '');
      expect(deck.cardCount, 0);
      expect(deck.folderId, isNull);
      expect(deck.config, isEmpty);
      expect(deck.stats, isEmpty);
    });
  });
}
