import 'dart:io';

import 'package:cardsharp/core/network/page.dart';
import 'package:cardsharp/core/storage/app_database.dart';
import 'package:cardsharp/features/cards/data/local_card_repository.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/features/decks/data/local_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:cardsharp/features/decks/domain/deck_repository.dart';
import 'package:cardsharp/features/cards/domain/trashed_card.dart';
import 'package:cardsharp/features/decks/domain/trashed_deck.dart';
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

  test('删除进回收站后：集与卡片都能查到，恢复后整集回来', () async {
    final LocalDeckRepository decks = LocalDeckRepository(db);
    final LocalCardRepository cards = LocalCardRepository(db);
    final Deck deck = await decks.createDeck(title: '待恢复');
    await cards.addCards(deck.id, <CardFields>[
      const CardFields(plaintext: '问一', ciphertext: '答一'),
      const CardFields(plaintext: '问二', ciphertext: '答二'),
    ]);

    await decks.deleteDeck(deck.id);

    final List<TrashedDeck> trashed = await decks.fetchTrashedDecks();
    expect(trashed, hasLength(1));
    expect(trashed.single.deck.id, deck.id);
    // 回收站里的卡片集要能显示「几张卡片」，否则用户不知道删掉了什么。
    expect(trashed.single.deck.cardCount, 2);
    expect(await cards.fetchTrashedCardsOfDeck(deck.id), hasLength(2));

    await decks.restoreDeck(deck.id);

    expect((await decks.fetchDecks(limit: 20)).items, hasLength(1));
    expect((await cards.fetchCards(deck.id, limit: 50)).items, hasLength(2));
    expect(await decks.fetchTrashedDecks(), isEmpty);
  });

  test('单独删除的卡片进回收站并带来源标题，可恢复到新建的卡片集', () async {
    final LocalDeckRepository decks = LocalDeckRepository(db);
    final LocalCardRepository cards = LocalCardRepository(db);
    final Deck deck = await decks.createDeck(title: '来源集');
    await cards.addCards(deck.id, <CardFields>[const CardFields(plaintext: '问', ciphertext: '答')]);
    final Card card = (await cards.fetchCards(deck.id, limit: 10)).items.single;

    await cards.deleteCard(card.id);

    final List<TrashedCard> standalone = await cards.fetchStandaloneTrashedCards();
    expect(standalone, hasLength(1));
    expect(standalone.single.sourceDeckTitle, '来源集');

    final Deck target = await decks.createDeck(title: '新建恢复');
    await cards.restoreCard(card.id, targetDeckId: target.id);

    expect(await cards.fetchStandaloneTrashedCards(), isEmpty);
    expect((await cards.fetchCards(target.id, limit: 10)).items, hasLength(1));
  });

  test('先单删卡片、后删卡片集：卡片合并进卡片集批次，不出现两处', () async {
    final LocalDeckRepository decks = LocalDeckRepository(db);
    final LocalCardRepository cards = LocalCardRepository(db);
    final Deck deck = await decks.createDeck(title: '先删卡再删集');
    await cards.addCards(deck.id, <CardFields>[
      const CardFields(plaintext: '甲', ciphertext: 'A'),
      const CardFields(plaintext: '乙', ciphertext: 'B'),
    ]);
    final List<Card> all = (await cards.fetchCards(deck.id, limit: 10)).items;

    await cards.deleteCard(all.first.id);
    expect(await cards.fetchStandaloneTrashedCards(), hasLength(1));

    await decks.deleteDeck(deck.id);

    // 单卡那条被并进卡片集批次：顶层只有卡片集，卡片在集里。
    expect(await cards.fetchStandaloneTrashedCards(), isEmpty);
    expect(await cards.fetchTrashedCardsOfDeck(deck.id), hasLength(2));
  });

  test('永久删除卡片集：集与它带走的卡片一起从库里抹掉', () async {
    final LocalDeckRepository decks = LocalDeckRepository(db);
    final LocalCardRepository cards = LocalCardRepository(db);
    final Deck deck = await decks.createDeck(title: '要彻底删');
    await cards.addCards(deck.id, <CardFields>[
      const CardFields(plaintext: '甲', ciphertext: 'A'),
      const CardFields(plaintext: '乙', ciphertext: 'B'),
    ]);
    await decks.deleteDeck(deck.id);

    await decks.purgeDeck(deck.id);

    expect(await decks.fetchTrashedDecks(), isEmpty);
    expect(await cards.fetchTrashedCardsOfDeck(deck.id), isEmpty);
    // 也不该以「正常卡片」的形式冒出来。
    expect((await cards.fetchCards(deck.id, limit: 10)).items, isEmpty);
    // 幂等：再删一次不报错。
    await decks.purgeDeck(deck.id);
  });

  test('永久删除单删的卡片：只抹掉回收站里的那张，正常卡片与卡片集都不动', () async {
    final LocalDeckRepository decks = LocalDeckRepository(db);
    final LocalCardRepository cards = LocalCardRepository(db);
    final Deck deck = await decks.createDeck(title: '留着的集');
    await cards.addCards(deck.id, <CardFields>[
      const CardFields(plaintext: '留下', ciphertext: 'K'),
      const CardFields(plaintext: '抹掉', ciphertext: 'X'),
    ]);
    final List<Card> all = (await cards.fetchCards(deck.id, limit: 10)).items;
    final Card doomed = all.firstWhere((Card item) => item.fields.plaintext == '抹掉');
    await cards.deleteCard(doomed.id);
    expect(await cards.fetchStandaloneTrashedCards(), hasLength(1));

    await cards.purgeCards(<String>[doomed.id]);

    expect(await cards.fetchStandaloneTrashedCards(), isEmpty);
    // 卡片集与剩下那张正常卡片都还在。
    expect((await decks.fetchDecks(limit: 20)).items, hasLength(1));
    final List<Card> alive = (await cards.fetchCards(deck.id, limit: 10)).items;
    expect(alive, hasLength(1));
    expect(alive.single.fields.plaintext, '留下');
    // 正常卡片的 id 传进 purgeCards 也不会被误删。
    await cards.purgeCards(<String>[alive.single.id]);
    expect((await cards.fetchCards(deck.id, limit: 10)).items, hasLength(1));
  });
}
