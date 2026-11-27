import 'dart:io';

import 'package:cardsharp/core/network/page.dart';
import 'package:cardsharp/core/storage/app_database.dart';
import 'package:cardsharp/features/cards/data/local_card_repository.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/features/decks/data/local_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:cardsharp/features/decks/domain/deck_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// 本地库测试：用临时文件而不是内存库，才能验证「关掉再打开数据还在」。
void main() {
  late Directory dir;
  late File dbFile;
  late AppDatabase db;

  AppDatabase open() => AppDatabase(NativeDatabase(dbFile));

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('cardsharp_db_');
    dbFile = File('${dir.path}/cache_test.db');
    db = open();
  });

  tearDown(() async {
    await db.close();
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  test('新建卡片集后能读回，且卡片数为 0', () async {
    final LocalDeckRepository decks = LocalDeckRepository(db);

    final Deck created = await decks.createDeck(title: '  奶蛙  ');

    expect(created.title, '奶蛙');
    final PagedResult<Deck> page = await decks.fetchDecks(limit: 20);
    expect(page.items, hasLength(1));
    expect(page.items.single.title, '奶蛙');
    expect(page.items.single.cardCount, 0);
  });

  test('空标题抛 titleRequired', () async {
    final LocalDeckRepository decks = LocalDeckRepository(db);

    await expectLater(
      decks.createDeck(title: '   '),
      throwsA(
        isA<DeckException>().having(
          (DeckException e) => e.failure,
          'failure',
          DeckFailure.titleRequired,
        ),
      ),
    );
  });

  test('关掉数据库再打开，卡片集与卡片都还在', () async {
    final LocalDeckRepository decks = LocalDeckRepository(db);
    final LocalCardRepository cards = LocalCardRepository(db);

    final Deck deck = await decks.createDeck(title: '持久化');
    await cards.addCards(deck.id, <CardFields>[
      const CardFields(plaintext: '问一', ciphertext: '答一'),
      const CardFields(plaintext: '问二', ciphertext: '答二'),
    ]);

    await db.close();
    db = open();

    final LocalDeckRepository reopenedDecks = LocalDeckRepository(db);
    final LocalCardRepository reopenedCards = LocalCardRepository(db);
    final PagedResult<Deck> page = await reopenedDecks.fetchDecks(limit: 20);

    expect(page.items, hasLength(1));
    expect(page.items.single.cardCount, 2);
    final PagedResult<Card> stored = await reopenedCards.fetchCards(deck.id, limit: 50);
    expect(stored.items, hasLength(2));
    expect(stored.items.first.fields.plaintext, '问一');
  });

  test('局部更新只改传入字段', () async {
    final LocalDeckRepository decks = LocalDeckRepository(db);
    final Deck deck = await decks.createDeck(title: '原名');

    await decks.updateDeck(deck.id, color: '#10B981');

    final Deck reloaded = (await decks.fetchDecks(limit: 20)).items.single;
    expect(reloaded.title, '原名');
    expect(reloaded.color, '#10B981');
  });

  test('删除卡片集是软删除：列表里消失，卡片一并消失', () async {
    final LocalDeckRepository decks = LocalDeckRepository(db);
    final LocalCardRepository cards = LocalCardRepository(db);
    final Deck deck = await decks.createDeck(title: '待删');
    await cards.addCards(deck.id, <CardFields>[const CardFields(plaintext: '问', ciphertext: '答')]);

    await decks.deleteDeck(deck.id);

    expect((await decks.fetchDecks(limit: 20)).items, isEmpty);
    expect((await cards.fetchCards(deck.id, limit: 50)).items, isEmpty);
  });

  test('删除不存在的卡片集抛 notFound', () async {
    final LocalDeckRepository decks = LocalDeckRepository(db);

    await expectLater(
      decks.deleteDeck('missing'),
      throwsA(
        isA<DeckException>().having(
          (DeckException e) => e.failure,
          'failure',
          DeckFailure.notFound,
        ),
      ),
    );
  });
}
