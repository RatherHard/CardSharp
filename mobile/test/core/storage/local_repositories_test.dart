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

  group('卡片集身份：禁止同名', () {
    Matcher throwsDeckFailure(DeckFailure failure) =>
        throwsA(isA<DeckException>().having((DeckException e) => e.failure, 'failure', failure));

    test('同名新建被拒：比较前去掉首尾空格', () async {
      final LocalDeckRepository decks = LocalDeckRepository(db);
      await decks.createDeck(title: '奶蛙');

      await expectLater(
        decks.createDeck(title: '  奶蛙  '),
        throwsDeckFailure(DeckFailure.duplicateTitle),
      );
      expect((await decks.fetchDecks(limit: 20)).items, hasLength(1));
    });

    test('同名新建被拒：不区分大小写', () async {
      final LocalDeckRepository decks = LocalDeckRepository(db);
      await decks.createDeck(title: 'Naiwa');

      await expectLater(
        decks.createDeck(title: 'nAiWa'),
        throwsDeckFailure(DeckFailure.duplicateTitle),
      );
    });

    test('改名撞名被拒；只改简介/颜色不触发查重', () async {
      final LocalDeckRepository decks = LocalDeckRepository(db);
      final Deck a = await decks.createDeck(title: '卡片集 A');
      await decks.createDeck(title: '卡片集 B');

      await expectLater(
        decks.updateDeck(a.id, title: ' 卡片集 b '),
        throwsDeckFailure(DeckFailure.duplicateTitle),
      );

      // 只动简介和颜色：标题没变，不该被同名检查挡住。
      final Deck patched = await decks.updateDeck(a.id, description: '新简介', color: '#FF0000');
      expect(patched.title, '卡片集 A');
      expect(patched.description, '新简介');
      expect(patched.color, '#FF0000');
    });

    test('回收站不占名：删除后可用原名新建，但恢复旧集会撞名', () async {
      final LocalDeckRepository decks = LocalDeckRepository(db);
      final Deck removed = await decks.createDeck(title: '奶蛙');
      await decks.deleteDeck(removed.id);

      // 回收站里的集不参与同名判定，所以同名新建应当成功。
      final Deck recreated = await decks.createDeck(title: '奶蛙');
      expect(recreated.id, isNot(removed.id));

      // 此时恢复旧集就会撞名，且旧集原样留在回收站。
      await expectLater(
        decks.restoreDeck(removed.id),
        throwsDeckFailure(DeckFailure.duplicateTitle),
      );
      expect(await decks.fetchTrashedDecks(), hasLength(1));
    });
  });

  group('卡片集身份：权威编号与整集覆盖', () {
    test('编号随卡片集落库，可按编号找回；软删后只算回收站里的', () async {
      final LocalDeckRepository decks = LocalDeckRepository(db);
      final Deck deck = await decks.createDeck(title: '奶蛙家族图鉴', sourceKey: 'example.naiwa-family');

      final Deck? found = await decks.findVisibleDeckBySourceKey('example.naiwa-family');
      expect(found?.id, deck.id);
      expect(await decks.hasTrashedDeckWithSourceKey('example.naiwa-family'), isFalse);

      await decks.deleteDeck(deck.id);
      expect(await decks.findVisibleDeckBySourceKey('example.naiwa-family'), isNull);
      expect(await decks.hasTrashedDeckWithSourceKey('example.naiwa-family'), isTrue);
    });

    test('overwriteDeck 覆盖元数据但保留 id 与编号', () async {
      final LocalDeckRepository decks = LocalDeckRepository(db);
      final Deck deck = await decks.createDeck(title: '旧标题', sourceKey: 'example.mini-world');

      final Deck overwritten = await decks.overwriteDeck(
        deck.id,
        title: '迷你世界角色图鉴',
        description: '权威简介',
        color: '#3B82F6',
        cardType: 'memory',
        config: <String, dynamic>{
          'runner': <String, dynamic>{'scheduler': 'fsrs'},
        },
      );

      expect(overwritten.id, deck.id);
      expect(overwritten.title, '迷你世界角色图鉴');
      expect(overwritten.description, '权威简介');
      expect(overwritten.color, '#3B82F6');
      expect(overwritten.config, containsPair('runner', isNotNull));
      // 编号没丢，下次拉取还能命中同一条。
      expect((await decks.findVisibleDeckBySourceKey('example.mini-world'))?.id, deck.id);
    });

    test('overwriteDeck 改成别人的名字报 duplicateTitle', () async {
      final LocalDeckRepository decks = LocalDeckRepository(db);
      final Deck target = await decks.createDeck(title: '要覆盖的集', sourceKey: 'example.a');
      await decks.createDeck(title: '别人的集');

      await expectLater(
        decks.overwriteDeck(
          target.id,
          title: ' 别人的集 ',
          description: '',
          color: '',
          cardType: 'memory',
          config: const <String, dynamic>{},
        ),
        throwsA(
          isA<DeckException>().having(
            (DeckException e) => e.failure,
            'failure',
            DeckFailure.duplicateTitle,
          ),
        ),
      );
    });

    test('replaceCards 物理换掉整集卡片（含已单删的），按新顺序重排', () async {
      final LocalDeckRepository decks = LocalDeckRepository(db);
      final LocalCardRepository cards = LocalCardRepository(db);
      final Deck deck = await decks.createDeck(title: '待覆盖');
      await cards.addCards(deck.id, <CardFields>[
        const CardFields(plaintext: '旧一', ciphertext: 'A'),
        const CardFields(plaintext: '旧二', ciphertext: 'B'),
      ]);
      final List<Card> oldCards = (await cards.fetchCards(deck.id, limit: 10)).items;
      await cards.deleteCard(oldCards.first.id); // 一张进回收站，也必须被换掉
      // 单删的卡片落在「回收站里的独立卡片」里，随后 replaceCards 要一并抹掉。
      expect(await cards.fetchStandaloneTrashedCards(), hasLength(1));

      await cards.replaceCards(deck.id, <CardFields>[
        const CardFields(plaintext: '新一', ciphertext: 'X'),
        const CardFields(plaintext: '新二', ciphertext: 'Y'),
        const CardFields(plaintext: '新三', ciphertext: 'Z'),
      ]);

      final List<Card> rebuilt = (await cards.fetchCards(deck.id, limit: 10)).items;
      expect(rebuilt.map((Card c) => c.fields.plaintext), <String>['新一', '新二', '新三']);
      expect(rebuilt.map((Card c) => c.sortOrder), <int>[0, 1, 2]);
      expect(await cards.fetchTrashedCardsOfDeck(deck.id), isEmpty);
      expect(await cards.fetchStandaloneTrashedCards(), isEmpty);
      // 卡片数统计跟着更新。
      expect((await decks.fetchDecks(limit: 20)).items.single.cardCount, 3);
    });
  });

  test('v2 老库升级到 v3：补上 source_key，旧数据保留、新写入能带编号', () async {
    final LocalDeckRepository decks = LocalDeckRepository(db);
    final Deck old = await decks.createDeck(title: '升级前建的集');

    // 把库降级成 v2 形状：删掉 v3 才有的列，再把 user_version 改回 2。
    await db.customStatement('ALTER TABLE local_decks DROP COLUMN source_key');
    await db.customStatement('PRAGMA user_version = 2');
    await db.close();

    db = open(); // 重新打开触发 onUpgrade(2 → 3)
    final LocalDeckRepository upgraded = LocalDeckRepository(db);

    final PagedResult<Deck> page = await upgraded.fetchDecks(limit: 20);
    expect(page.items.single.id, old.id);
    expect(page.items.single.title, '升级前建的集');
    expect(await upgraded.findVisibleDeckBySourceKey('example.migration'), isNull);

    final Deck fresh = await upgraded.createDeck(title: '升级后建的集', sourceKey: 'example.migration');
    expect((await upgraded.findVisibleDeckBySourceKey('example.migration'))?.id, fresh.id);
  });
}
