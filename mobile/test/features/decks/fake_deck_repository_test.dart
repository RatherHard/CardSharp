import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeDeckRepository', () {
    test('默认返回 6 个种子卡片集，卡片数都是 0', () async {
      final decks = await FakeDeckRepository().fetchDecks();

      expect(decks, hasLength(kSeedDecks.length));
      expect(decks.map((Deck d) => d.title).toList(), <String>[
        '卡片集1',
        '卡片集2',
        '卡片集3',
        '卡片集4',
        '卡片集5',
        '卡片集6',
      ]);
      expect(decks.every((Deck d) => d.cardCount == 0), isTrue);
    });

    test('返回值为只读副本，外部修改不能影响内部状态', () async {
      final repository = FakeDeckRepository();
      final decks = await repository.fetchDecks();

      expect(() => decks.add(const Deck(id: 'x', title: 'x')), throwsUnsupportedError);
    });

    test('新建：名称去空格、卡片数从 0 开始、id 递增', () async {
      final repository = FakeDeckRepository();

      final first = await repository.createDeck(title: '  TestDeck  ');
      final second = await repository.createDeck(title: 'Another');

      expect(first.title, 'TestDeck');
      expect(first.cardCount, 0);
      expect(second.id, isNot(first.id));
      expect((await repository.fetchDecks()).length, kSeedDecks.length + 2);
    });

    test('新建：空名称抛 ArgumentError 且不写入', () async {
      final repository = FakeDeckRepository();

      await expectLater(repository.createDeck(title: '   '), throwsArgumentError);
      expect((await repository.fetchDecks()).length, kSeedDecks.length);
    });

    test('id 取现有最大值 +1，删除后再建不会撞号', () async {
      final repository = FakeDeckRepository();

      await repository.deleteDeck('3');
      final created = await repository.createDeck(title: 'after-delete');

      expect(created.id, '7');
      final ids = (await repository.fetchDecks()).map((Deck d) => d.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('种子 id 不连续时也不会撞号', () async {
      final repository = FakeDeckRepository(<Deck>[
        const Deck(id: '1', title: 'a'),
        const Deck(id: '9', title: 'b'),
      ]);

      final created = await repository.createDeck(title: 'c');

      expect(created.id, '10');
    });

    test('非数字 id 的种子从 1 开始编号', () async {
      final repository = FakeDeckRepository(<Deck>[const Deck(id: 'uuid-x', title: 'a')]);

      final created = await repository.createDeck(title: 'b');

      expect(created.id, '1');
    });

    test('删除存在的卡片集', () async {
      final repository = FakeDeckRepository();

      await repository.deleteDeck('2');

      expect((await repository.fetchDecks()).map((Deck d) => d.id), isNot(contains('2')));
    });

    test('删除不存在的卡片集抛 StateError', () async {
      final repository = FakeDeckRepository();

      expect(() => repository.deleteDeck('missing'), throwsStateError);
    });

    test('两个实例互不影响', () async {
      final a = FakeDeckRepository();
      final b = FakeDeckRepository();

      await a.createDeck(title: 'only-in-a');

      expect((await b.fetchDecks()).length, kSeedDecks.length);
    });
  });
}
