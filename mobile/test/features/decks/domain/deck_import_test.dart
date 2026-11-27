import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/features/decks/domain/deck_import.dart';
import 'package:flutter_test/flutter_test.dart';

/// 一个最小合法卡片对象的 JSON 片段（新契约：内容包在 fields 里）。
String cardJson({
  String plaintext = '问',
  String ciphertext = '答',
  String extraFields = '',
  int? sortOrder,
}) {
  final String order = sortOrder == null ? '' : '"sort_order": $sortOrder,';
  return '{$order"fields":{"plaintext":"$plaintext","ciphertext":"$ciphertext"$extraFields}}';
}

String deckJson({String title = 't', String extra = '', String cards = ''}) =>
    '{"title":"$title"$extra,"cards":[$cards]}';

Matcher throwsImportError(DeckImportError error) =>
    throwsA(isA<DeckImportException>().having((DeckImportException e) => e.error, 'error', error));

void main() {
  group('parseDeckImport', () {
    test('解析完整文件：卡片集字段与 cards[].fields 都按后端契约落位', () {
      final DeckImport data = parseDeckImport('''
      {
        "title": "生物学基础",
        "description": "细胞结构与代谢",
        "color": "#5B5BD6",
        "card_type": "memory",
        "config": {"runner": {"scheduler": "fsrs"}},
        "cards": [
          {
            "sort_order": 1,
            "fields": {
              "plaintext": "线粒体的功能？",
              "ciphertext": "产生 ATP",
              "images": [{"key": "img/1.png", "width": 800, "height": 600, "alt": "线粒体"}],
              "hint": "能量",
              "extra": "第 3 节"
            }
          }
        ]
      }
      ''');

      expect(data.title, '生物学基础');
      expect(data.description, '细胞结构与代谢');
      expect(data.color, '#5B5BD6');
      expect(data.cardType, kMemoryCardType);
      expect(data.config['runner'], isNotNull);
      expect(data.cards, hasLength(1));

      final CardFields fields = data.cards.first;
      expect(fields.plaintext, '线粒体的功能？');
      expect(fields.ciphertext, '产生 ATP');
      expect(fields.hint, '能量');
      expect(fields.extra, '第 3 节');
      expect(fields.images, hasLength(1));
      expect(fields.images.first.key, 'img/1.png');
      expect(fields.images.first.width, 800);
      expect(fields.images.first.height, 600);
      expect(fields.images.first.alt, '线粒体');
    });

    test('card_type 与 config 缺省时用 memory 与空对象', () {
      final DeckImport data = parseDeckImport(deckJson(cards: cardJson()));

      expect(data.cardType, kMemoryCardType);
      expect(data.config, isEmpty);
    });

    test('images 缺省时为空列表，不给 null', () {
      final DeckImport data = parseDeckImport(deckJson(cards: cardJson()));

      expect(data.cards.first.images, isEmpty);
    });

    test('文本两端空白会被去掉', () {
      final DeckImport data = parseDeckImport(
        deckJson(
          title: '  空格标题  ',
          cards: cardJson(plaintext: ' 问 ', ciphertext: ' 答 '),
        ),
      );

      expect(data.title, '空格标题');
      expect(data.cards.first.plaintext, '问');
      expect(data.cards.first.ciphertext, '答');
    });

    test('颜色格式不合法时降级为空串，不影响导入', () {
      final DeckImport data = parseDeckImport(deckJson(extra: ',"color":"red"', cards: cardJson()));

      expect(data.color, '');
    });

    test('按 sort_order 排序；没写的卡片按原数组下标参与排序', () {
      final DeckImport data = parseDeckImport(
        deckJson(
          cards:
              '${cardJson(plaintext: '第三', sortOrder: 3)},'
              '${cardJson(plaintext: '第一', sortOrder: 1)},'
              '${cardJson(plaintext: '第二')}',
        ),
      );

      // 第二张没写 sort_order，用它在数组里的下标 2 参与排序 → 顺序为 第一(1)、第二(2)、第三(3)。
      expect(data.cards.map((CardFields f) => f.plaintext).toList(), <String>['第一', '第二', '第三']);
    });

    test('非 JSON 抛 invalidJson', () {
      expect(() => parseDeckImport('not json'), throwsImportError(DeckImportError.invalidJson));
    });

    test('顶层不是对象抛 notAnObject', () {
      expect(() => parseDeckImport('[]'), throwsImportError(DeckImportError.notAnObject));
    });

    test('缺少标题抛 missingTitle', () {
      expect(
        () => parseDeckImport('{"cards":[${cardJson()}]}'),
        throwsImportError(DeckImportError.missingTitle),
      );
    });

    test('没有卡片抛 missingCards', () {
      expect(
        () => parseDeckImport('{"title":"t","cards":[]}'),
        throwsImportError(DeckImportError.missingCards),
      );
    });

    test('卡片没有 fields 对象抛 invalidCard', () {
      expect(
        () => parseDeckImport('{"title":"t","cards":[{"plaintext":"a","ciphertext":"b"}]}'),
        throwsImportError(DeckImportError.invalidCard),
      );
    });

    test('明文超过 200 字抛 invalidCard', () {
      final String longText = 'a' * (kPlaintextMaxLength + 1);
      expect(
        () => parseDeckImport(deckJson(cards: cardJson(plaintext: longText))),
        throwsImportError(DeckImportError.invalidCard),
      );
    });

    test('暗文超过 500 字抛 invalidCard', () {
      final String longText = 'a' * (kCiphertextMaxLength + 1);
      expect(
        () => parseDeckImport(deckJson(cards: cardJson(ciphertext: longText))),
        throwsImportError(DeckImportError.invalidCard),
      );
    });

    test('卡片缺少暗文抛 invalidCard', () {
      expect(
        () => parseDeckImport('{"title":"t","cards":[{"fields":{"plaintext":"a"}}]}'),
        throwsImportError(DeckImportError.invalidCard),
      );
    });

    test('图片缺少 key 抛 invalidCard', () {
      expect(
        () => parseDeckImport(deckJson(cards: cardJson(extraFields: ',"images":[{"width":10}]'))),
        throwsImportError(DeckImportError.invalidCard),
      );
    });

    test('图片 width 不是整数抛 invalidCard', () {
      expect(
        () => parseDeckImport(
          deckJson(cards: cardJson(extraFields: ',"images":[{"key":"k","width":"10"}]')),
        ),
        throwsImportError(DeckImportError.invalidCard),
      );
    });

    test('卡片集 card_type 不是 memory 抛 unsupportedCardType', () {
      expect(
        () => parseDeckImport(deckJson(extra: ',"card_type":"quiz"', cards: cardJson())),
        throwsImportError(DeckImportError.unsupportedCardType),
      );
    });

    test('卡片自带 card_type 且不是 memory 时也抛 unsupportedCardType', () {
      expect(
        () => parseDeckImport(
          '{"title":"t","cards":[{"card_type":"quiz",'
          '"fields":{"plaintext":"a","ciphertext":"b"}}]}',
        ),
        throwsImportError(DeckImportError.unsupportedCardType),
      );
    });

    test('config 不是对象抛 invalidDeck', () {
      expect(
        () => parseDeckImport(deckJson(extra: ',"config":"x"', cards: cardJson())),
        throwsImportError(DeckImportError.invalidDeck),
      );
    });

    test('question 是本地演示字段：有值就收，缺省为 null', () {
      final DeckImport withQuestion = parseDeckImport(
        deckJson(cards: cardJson(extraFields: ',"question":"奶蛙最明显的两个外观特征是什么？"')),
      );
      expect(withQuestion.cards.first.question, '奶蛙最明显的两个外观特征是什么？');

      final DeckImport withoutQuestion = parseDeckImport(deckJson(cards: cardJson()));
      expect(withoutQuestion.cards.first.question, isNull);
    });

    test('question 两端空白会被去掉，空串按缺省处理', () {
      final DeckImport trimmed = parseDeckImport(
        deckJson(cards: cardJson(extraFields: ',"question":"  是什么？  "')),
      );
      expect(trimmed.cards.first.question, '是什么？');

      final DeckImport blank = parseDeckImport(
        deckJson(cards: cardJson(extraFields: ',"question":"  "')),
      );
      expect(blank.cards.first.question, isNull);
    });

    test('question 超过 200 字抛 invalidCard', () {
      final String longText = 'a' * (kPlaintextMaxLength + 1);
      expect(
        () => parseDeckImport(deckJson(cards: cardJson(extraFields: ',"question":"$longText"'))),
        throwsImportError(DeckImportError.invalidCard),
      );
    });
  });

  group('source_key（权威编号）', () {
    test('有值时就解析出编号', () {
      final DeckImport data = parseDeckImport(
        deckJson(extra: ',"source_key":"example.naiwa-family"', cards: cardJson()),
      );
      expect(data.sourceKey, 'example.naiwa-family');
    });

    test('缺省时编号为 null（视为用户自建卡片集）', () {
      final DeckImport data = parseDeckImport(deckJson(cards: cardJson()));
      expect(data.sourceKey, isNull);
    });

    test('两端空白会去掉，空串按缺省处理', () {
      final DeckImport trimmed = parseDeckImport(
        deckJson(extra: ',"source_key":"  example.mini-world  "', cards: cardJson()),
      );
      expect(trimmed.sourceKey, 'example.mini-world');

      final DeckImport blank = parseDeckImport(
        deckJson(extra: ',"source_key":"   "', cards: cardJson()),
      );
      expect(blank.sourceKey, isNull);
    });

    test('不是字符串报 invalidDeck', () {
      expect(
        () => parseDeckImport(deckJson(extra: ',"source_key":123', cards: cardJson())),
        throwsImportError(DeckImportError.invalidDeck),
      );
    });

    test('超过 200 字符报 invalidDeck', () {
      final String longKey = 'k' * (kSourceKeyMaxLength + 1);
      expect(
        () => parseDeckImport(deckJson(extra: ',"source_key":"$longKey"', cards: cardJson())),
        throwsImportError(DeckImportError.invalidDeck),
      );
    });
  });
}
