import 'package:cardsharp/core/network/page.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeDeckRepository', () {
    test('默认返回 6 个种子卡片集，卡片数都是 0', () async {
      final PagedResult<Deck> page = await FakeDeckRepository().fetchDecks(limit: 100);

      expect(page.items, hasLength(kSeedDecks.length));
      expect(page.items.map((Deck d) => d.title).toList(), <String>[
        '卡片集1',
        '卡片集2',
        '卡片集3',
        '卡片集4',
        '卡片集5',
        '卡片集6',
      ]);
      expect(page.items.every((Deck d) => d.cardCount == 0), isTrue);
      expect(page.nextCursor, isNull);
    });

    test('分页：按 limit 切分，游标可续取下一页', () async {
      final repository = FakeDeckRepository();

      final PagedResult<Deck> first = await repository.fetchDecks(limit: 4);
      expect(first.items, hasLength(4));
      expect(first.nextCursor, isNotNull);

      final PagedResult<Deck> second = await repository.fetchDecks(
        cursor: first.nextCursor,
        limit: 4,
      );
      expect(second.items, hasLength(2));
      expect(second.nextCursor, isNull);

      final List<String> ids = <String>[
        ...first.items.map((Deck d) => d.id),
        ...second.items.map((Deck d) => d.id),
      ];
      expect(ids.toSet().length, kSeedDecks.length);
    });

    test('游标越界时返回空页，不抛异常', () async {
      final PagedResult<Deck> page = await FakeDeckRepository().fetchDecks(
        cursor: '999',
        limit: 10,
      );

      expect(page.items, isEmpty);
      expect(page.nextCursor, isNull);
    });

    test('返回值为只读副本，外部修改不能影响内部状态', () async {
      final repository = FakeDeckRepository();
      final PagedResult<Deck> page = await repository.fetchDecks(limit: 100);

      expect(() => page.items.add(const Deck(id: 'x', title: 'x')), throwsUnsupportedError);
    });

    test('新建：名称去空格、卡片数从 0 开始、id 递增', () async {
      final repository = FakeDeckRepository();

      final first = await repository.createDeck(title: '  TestDeck  ');
      final second = await repository.createDeck(title: 'Another');

      expect(first.title, 'TestDeck');
      expect(first.cardCount, 0);
      expect(second.id, isNot(first.id));
      expect((await repository.fetchDecks(limit: 100)).items.length, kSeedDecks.length + 2);
    });

    test('新建：空名称抛 ArgumentError 且不写入', () async {
      final repository = FakeDeckRepository();

      await expectLater(repository.createDeck(title: '   '), throwsArgumentError);
      expect((await repository.fetchDecks(limit: 100)).items.length, kSeedDecks.length);
    });

    test('id 取现有最大值 +1，删除后再建不会撞号', () async {
      final repository = FakeDeckRepository();

      await repository.deleteDeck('3');
      final created = await repository.createDeck(title: 'after-delete');

      expect(created.id, '7');
      final ids = (await repository.fetchDecks(limit: 100)).items.map((Deck d) => d.id).toList();
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

      expect(
        (await repository.fetchDecks(limit: 100)).items.map((Deck d) => d.id),
        isNot(contains('2')),
      );
    });

    test('删除不存在的卡片集抛 StateError', () async {
      final repository = FakeDeckRepository();

      expect(() => repository.deleteDeck('missing'), throwsStateError);
    });

    test('两个实例互不影响', () async {
      final a = FakeDeckRepository();
      final b = FakeDeckRepository();

      await a.createDeck(title: 'only-in-a');

      expect((await b.fetchDecks(limit: 100)).items.length, kSeedDecks.length);
    });

    test('局部更新只改传入的字段', () async {
      final repository = FakeDeckRepository();

      final Deck updated = await repository.updateDeck('1', title: '改名了');

      expect(updated.title, '改名了');
      expect(updated.description, '');
      expect(updated.color, '');

      final Deck reloaded = (await repository.fetchDecks(limit: 100)).items
          .firstWhere((Deck d) => d.id == '1');
      expect(reloaded.title, '改名了');
    });
  });
}
