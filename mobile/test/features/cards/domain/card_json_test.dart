import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:flutter_test/flutter_test.dart';

/// 契约测试：后端 JSON 用下划线命名（`docs/03` §4.2 / §4.4），
/// 这里锁住「能解析 + 能回写」，避免以后有人把注解删掉。
void main() {
  group('Card JSON 契约', () {
    test('能解析后端返回的下划线键名', () {
      final Card card = Card.fromJson(<String, dynamic>{
        'id': 'c1',
        'deck_id': 'd1',
        'card_type': 'memory',
        'sort_order': 3,
        'fields': <String, dynamic>{
          'plaintext': '线粒体的功能？',
          'ciphertext': '产生 ATP',
          'images': <dynamic>[],
          'hint': '能量',
        },
      });

      expect(card.id, 'c1');
      expect(card.deckId, 'd1');
      expect(card.cardType, 'memory');
      expect(card.sortOrder, 3);
      expect(card.fields.plaintext, '线粒体的功能？');
      expect(card.fields.ciphertext, '产生 ATP');
      expect(card.fields.hint, '能量');
    });

    test('toJson 输出的是下划线键名，不是驼峰', () {
      const Card card = Card(
        id: 'c1',
        deckId: 'd1',
        fields: CardFields(plaintext: '问', ciphertext: '答'),
        sortOrder: 1,
      );

      final Map<String, dynamic> json = card.toJson();

      expect(json.containsKey('deck_id'), isTrue);
      expect(json.containsKey('card_type'), isTrue);
      expect(json.containsKey('sort_order'), isTrue);
      expect(json.containsKey('deckId'), isFalse);
      expect(json.containsKey('cardType'), isFalse);
    });

    test('缺省字段有默认值，不会因为后端少给而崩', () {
      final Card card = Card.fromJson(<String, dynamic>{
        'id': 'c1',
        'deck_id': 'd1',
        'fields': <String, dynamic>{'plaintext': '问', 'ciphertext': '答'},
      });

      expect(card.cardType, 'memory');
      expect(card.sortOrder, 0);
      expect(card.fields.images, isEmpty);
    });
  });
}
