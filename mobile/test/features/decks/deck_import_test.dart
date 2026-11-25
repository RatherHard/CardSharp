import 'package:cardsharp/features/decks/domain/deck_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseDeckImport', () {
    test('解析完整文件：标题、简介、颜色、卡片字段齐全', () {
      final DeckImport data = parseDeckImport('''
      {
        "title": "生物学基础",
        "description": "细胞结构与代谢",
        "color": "#5B5BD6",
        "cards": [
          {"plaintext": "线粒体的功能？", "ciphertext": "产生 ATP", "hint": "能量", "extra": "第 3 节"}
        ]
      }
      ''');

      expect(data.title, '生物学基础');
      expect(data.description, '细胞结构与代谢');
      expect(data.color, '#5B5BD6');
      expect(data.cards, hasLength(1));
      expect(data.cards.first.plaintext, '线粒体的功能？');
      expect(data.cards.first.ciphertext, '产生 ATP');
      expect(data.cards.first.hint, '能量');
      expect(data.cards.first.extra, '第 3 节');
    });

    test('标题与文本两端空白会被去掉', () {
      final DeckImport data = parseDeckImport(
        '{"title":"  空格标题  ","cards":[{"plaintext":" 问 ","ciphertext":" 答 "}]}',
      );

      expect(data.title, '空格标题');
      expect(data.cards.first.plaintext, '问');
      expect(data.cards.first.ciphertext, '答');
    });

    test('颜色格式不合法时降级为空串，不影响导入', () {
      final DeckImport data = parseDeckImport(
        '{"title":"t","color":"red","cards":[{"plaintext":"a","ciphertext":"b"}]}',
      );

      expect(data.color, '');
    });

    test('非 JSON 抛 invalidJson', () {
      expect(
        () => parseDeckImport('not json'),
        throwsA(
          isA<DeckImportException>().having(
            (DeckImportException e) => e.error,
            'error',
            DeckImportError.invalidJson,
          ),
        ),
      );
    });

    test('顶层不是对象抛 notAnObject', () {
      expect(
        () => parseDeckImport('[]'),
        throwsA(
          isA<DeckImportException>().having(
            (DeckImportException e) => e.error,
            'error',
            DeckImportError.notAnObject,
          ),
        ),
      );
    });

    test('缺少标题抛 missingTitle', () {
      expect(
        () => parseDeckImport('{"cards":[{"plaintext":"a","ciphertext":"b"}]}'),
        throwsA(
          isA<DeckImportException>().having(
            (DeckImportException e) => e.error,
            'error',
            DeckImportError.missingTitle,
          ),
        ),
      );
    });

    test('没有卡片抛 missingCards', () {
      expect(
        () => parseDeckImport('{"title":"t","cards":[]}'),
        throwsA(
          isA<DeckImportException>().having(
            (DeckImportException e) => e.error,
            'error',
            DeckImportError.missingCards,
          ),
        ),
      );
    });

    test('明文超过 200 字抛 invalidCard', () {
      final String longText = 'a' * 201;
      expect(
        () => parseDeckImport('{"title":"t","cards":[{"plaintext":"$longText","ciphertext":"b"}]}'),
        throwsA(
          isA<DeckImportException>().having(
            (DeckImportException e) => e.error,
            'error',
            DeckImportError.invalidCard,
          ),
        ),
      );
    });

    test('暗文超过 500 字抛 invalidCard', () {
      final String longText = 'a' * 501;
      expect(
        () => parseDeckImport('{"title":"t","cards":[{"plaintext":"a","ciphertext":"$longText"}]}'),
        throwsA(isA<DeckImportException>()),
      );
    });

    test('卡片缺少暗文抛 invalidCard', () {
      expect(
        () => parseDeckImport('{"title":"t","cards":[{"plaintext":"a"}]}'),
        throwsA(isA<DeckImportException>()),
      );
    });
  });
}
