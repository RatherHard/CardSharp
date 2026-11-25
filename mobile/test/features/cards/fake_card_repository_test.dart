import 'package:cardsharp/core/network/page.dart';
import 'package:cardsharp/features/cards/data/fake_card_repository.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/features/cards/domain/card_repository.dart';
import 'package:flutter_test/flutter_test.dart';

Card _card(String id, int order) => Card(
  id: id,
  deckId: 'd1',
  fields: CardFields(plaintext: '问$id', ciphertext: '答$id'),
  sortOrder: order,
);

void main() {
  group('FakeCardRepository 分页', () {
    test('按 sortOrder 升序切页，游标可续取', () async {
      final CardRepository repository = FakeCardRepository(<String, List<Card>>{
        'd1': <Card>[_card('c3', 2), _card('c1', 0), _card('c2', 1)],
      });

      final PagedResult<Card> first = await repository.fetchCards('d1', limit: 2);
      expect(first.items.map((Card c) => c.id).toList(), <String>['c1', 'c2']);
      expect(first.nextCursor, isNotNull);

      final PagedResult<Card> second = await repository.fetchCards(
        'd1',
        cursor: first.nextCursor,
        limit: 2,
      );
      expect(second.items.map((Card c) => c.id).toList(), <String>['c3']);
      expect(second.nextCursor, isNull);
    });

    test('不存在的卡片集返回空页', () async {
      final PagedResult<Card> page = await FakeCardRepository().fetchCards('missing');

      expect(page.items, isEmpty);
      expect(page.nextCursor, isNull);
    });

    test('countFor 返回该卡片集的真实数量', () async {
      final FakeCardRepository repository = FakeCardRepository(<String, List<Card>>{
        'd1': <Card>[_card('c1', 0), _card('c2', 1)],
      });

      expect(repository.countFor('d1'), 2);
      expect(repository.countFor('d2'), 0);
    });
  });
}
