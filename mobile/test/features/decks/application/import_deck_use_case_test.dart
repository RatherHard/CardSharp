import 'package:cardsharp/features/cards/data/fake_card_repository.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/features/decks/application/use_cases/import_deck_use_case.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:cardsharp/features/decks/domain/deck_import.dart';
import 'package:cardsharp/features/decks/domain/deck_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImportDeckUseCase', () {
    test('导入后能用返回的 deck.id 读回全部卡片（含 images 与 hint/extra）', () async {
      final FakeDeckRepository decks = FakeDeckRepository();
      final FakeCardRepository cards = FakeCardRepository();
      final ImportDeckUseCase useCase = ImportDeckUseCase(decks, cards);

      final Deck deck = await useCase(
        const DeckImport(
          title: '导入的卡片集',
          description: '简介',
          color: '#10B981',
          cards: <CardFields>[
            CardFields(
              plaintext: '问一',
              ciphertext: '答一',
              images: <CardImage>[CardImage(key: 'img/1.png', width: 800, height: 600)],
              hint: '提示一',
            ),
            CardFields(plaintext: '问二', ciphertext: '答二'),
          ],
        ),
      );

      final List<Card> stored = (await cards.fetchCards(deck.id, limit: 100)).items;
      expect(stored, hasLength(2));
      expect(stored.first.fields.plaintext, '问一');
      expect(stored.first.fields.hint, '提示一');
      expect(stored.first.fields.images.single.key, 'img/1.png');
      expect(stored.last.fields.plaintext, '问二');
    });

    test('导入后卡片集的 card_type / config / 简介 / 颜色都写入了', () async {
      final FakeDeckRepository decks = FakeDeckRepository();
      final FakeCardRepository cards = FakeCardRepository();
      final ImportDeckUseCase useCase = ImportDeckUseCase(decks, cards);

      final Deck deck = await useCase(
        const DeckImport(
          title: '统计检查',
          description: '一句简介',
          color: '#5B5BD6',
          config: <String, dynamic>{
            'runner': <String, dynamic>{'scheduler': 'fsrs'},
          },
          cards: <CardFields>[CardFields(plaintext: 'a', ciphertext: 'b')],
        ),
      );

      final Deck? reloaded = (await decks.fetchDecks(limit: 100)).items
          .where((Deck d) => d.id == deck.id)
          .firstOrNull;
      expect(reloaded, isNotNull);
      expect(reloaded!.description, '一句简介');
      expect(reloaded.color, '#5B5BD6');
      expect(reloaded.cardType, kMemoryCardType);
      expect(reloaded.config, containsPair('runner', isNotNull));
      // 导入用例不再写卡片数：统计归服务端 `stats`。
      expect(reloaded.cardCount, 0);
      // 但卡片确实写进去了。
      expect((await cards.fetchCards(deck.id, limit: 100)).items, hasLength(1));
    });
  });

  group('ImportDeckUseCase 权威编号（source_key）', () {
    test('首次拉取带编号的卡片集：新建一条并记住编号', () async {
      final FakeDeckRepository decks = FakeDeckRepository();
      final FakeCardRepository cards = FakeCardRepository();
      final ImportDeckUseCase useCase = ImportDeckUseCase(decks, cards);

      final Deck deck = await useCase(_authorityImport(sourceKey: 'example.naiwa-family'));

      final Deck? byKey = await decks.findVisibleDeckBySourceKey('example.naiwa-family');
      expect(byKey?.id, deck.id);
      expect(await decks.hasTrashedDeckWithSourceKey('example.naiwa-family'), isFalse);
    });

    test('同编号重复拉取：不新增卡片集，权威版整条覆盖（标题/元数据/卡片全换）', () async {
      final FakeDeckRepository decks = FakeDeckRepository();
      final FakeCardRepository cards = FakeCardRepository();
      final ImportDeckUseCase useCase = ImportDeckUseCase(decks, cards);
      final int before = (await decks.fetchDecks(limit: 100)).items.length;

      final Deck first = await useCase(_authorityImport(sourceKey: 'example.mini-world'));
      // 第二次：标题/简介/颜色/卡片全变，编号不变——“权威版覆盖缓存”。
      final Deck second = await useCase(
        const DeckImport(
          title: '迷你世界角色图鉴（权威版）',
          description: '权威简介',
          color: '#3B82F6',
          sourceKey: 'example.mini-world',
          cards: <CardFields>[CardFields(plaintext: '新卡', ciphertext: '新答')],
        ),
      );

      expect(second.id, first.id);
      expect((await decks.fetchDecks(limit: 100)).items, hasLength(before + 1));
      final List<Card> stored = (await cards.fetchCards(second.id, limit: 100)).items;
      expect(stored, hasLength(1));
      expect(stored.single.fields.plaintext, '新卡');
      final Deck? reloaded = (await decks.fetchDecks(limit: 100)).items
          .where((Deck d) => d.id == first.id)
          .firstOrNull;
      expect(reloaded?.title, '迷你世界角色图鉴（权威版）');
      expect(reloaded?.description, '权威简介');
      expect(reloaded?.color, '#3B82F6');
    });

    test('同编号但只在回收站里：跳过并报 authorityInTrash，不复活也不建副本', () async {
      final FakeDeckRepository decks = FakeDeckRepository();
      final FakeCardRepository cards = FakeCardRepository();
      final ImportDeckUseCase useCase = ImportDeckUseCase(decks, cards);

      final Deck deck = await useCase(_authorityImport(sourceKey: 'example.naiwa-family'));
      await decks.deleteDeck(deck.id);

      await expectLater(
        useCase(_authorityImport(sourceKey: 'example.naiwa-family')),
        throwsA(
          isA<DeckException>().having(
            (DeckException e) => e.failure,
            'failure',
            DeckFailure.authorityInTrash,
          ),
        ),
      );

      expect(await decks.findVisibleDeckBySourceKey('example.naiwa-family'), isNull);
      expect(await decks.hasTrashedDeckWithSourceKey('example.naiwa-family'), isTrue);
      expect((await decks.fetchTrashedDecks()), hasLength(1));
    });

    test('不带编号的同名导入：拒绝并报 duplicateTitle（禁止同名）', () async {
      final FakeDeckRepository decks = FakeDeckRepository();
      final FakeCardRepository cards = FakeCardRepository();
      final ImportDeckUseCase useCase = ImportDeckUseCase(decks, cards);

      await useCase(_authorityImport(sourceKey: 'example.naiwa-family'));

      await expectLater(
        useCase(_authorityImport()),
        throwsA(
          isA<DeckException>().having(
            (DeckException e) => e.failure,
            'failure',
            DeckFailure.duplicateTitle,
          ),
        ),
      );
      expect(
        (await decks.fetchDecks(limit: 100)).items.where((Deck d) => d.title == '奶蛙家族图鉴'),
        hasLength(1),
      );
    });
  });
}

/// 一份最小的、可指定权威编号的导入数据。
DeckImport _authorityImport({String? sourceKey}) {
  return DeckImport(
    title: '奶蛙家族图鉴',
    description: '按外形特征认出奶蛙家族的成员',
    color: '#10B981',
    sourceKey: sourceKey,
    cards: const <CardFields>[
      CardFields(plaintext: '奶蛙', ciphertext: '圆头绿身'),
      CardFields(plaintext: '小奶蛙', ciphertext: '更小的圆头'),
    ],
  );
}
