import 'package:cardsharp/core/di/repository_providers.dart';
import 'package:cardsharp/core/di/service_providers.dart';
import 'package:cardsharp/features/cards/data/fake_card_repository.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:cardsharp/features/decks/domain/deck_cover_service.dart';
import 'package:cardsharp/features/decks/domain/trashed_deck.dart';
import 'package:cardsharp/features/trash/application/trash_providers.dart';
import 'package:cardsharp/features/trash/presentation/trash_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' hide Card;

/// 不落地任何文件：回收站只读封面路径，这里统一当「没有自定义封面」。
class _NoCoverService implements DeckCoverService {
  const _NoCoverService();

  @override
  Future<String?> readCoverPath(String deckId) async => null;

  @override
  Future<String?> pickAndSaveCover(String deckId) async => null;

  @override
  Future<void> removeCover(String deckId) async {}
}

Deck _deck(String id, String title) => Deck(id: id, title: title);

Card _card(String id, String deckId, String plaintext) => Card(
  id: id,
  deckId: deckId,
  fields: CardFields(plaintext: plaintext, ciphertext: '$plaintext 定义'),
);

/// 造一组「一个卡片集带一张卡 + 另一个集里单删一张卡」的回收站数据。
({FakeDeckRepository decks, FakeCardRepository cards}) _seedTrash() {
  final Map<String, List<Card>> seed = <String, List<Card>>{
    '1': <Card>[_card('c1', '1', '奶蛙')],
    '2': <Card>[_card('c2', '2', '奶蛋')],
  };
  final Map<String, String> titles = <String, String>{'1': '奶蛙家族图鉴', '2': '其他集'};
  final FakeCardRepository cards = FakeCardRepository(
    seed,
    (String deckId) => titles[deckId] ?? '',
  );
  final FakeDeckRepository decks =
      FakeDeckRepository(<Deck>[_deck('1', '奶蛙家族图鉴'), _deck('2', '其他集')])
        ..onDeleted = cards.trashDeckCards
        ..onRestored = cards.restoreDeckCards
        ..onPurged = cards.purgeDeckCards;
  return (decks: decks, cards: cards);
}

Future<void> _pumpTrash(
  WidgetTester tester, {
  required FakeDeckRepository decks,
  required FakeCardRepository cards,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        deckRepositoryProvider.overrideWithValue(decks),
        cardRepositoryProvider.overrideWithValue(cards),
        deckCoverServiceProvider.overrideWithValue(const _NoCoverService()),
      ],
      child: const MaterialApp(home: TrashPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('回收站按天分组：同一天先列卡片集、再列单删的卡片', (WidgetTester tester) async {
    final ({FakeDeckRepository decks, FakeCardRepository cards}) seed = _seedTrash();
    // 单删一张卡，再把卡片集删掉（卡片随集一起进回收站）。
    await seed.cards.deleteCard('c2');
    await seed.decks.deleteDeck('1');

    await _pumpTrash(tester, decks: seed.decks, cards: seed.cards);

    expect(find.byKey(const ValueKey<String>('trash_day_1')), findsNothing);
    // 日期头存在（按当前时间分天，标题形如「11月27日」）。
    expect(find.textContaining('月'), findsWidgets);
    expect(find.byKey(const ValueKey<String>('trash_section_decks')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('trash_section_cards')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('trash_deck_row_1')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('trash_card_row_c2')), findsOneWidget);
    // 单删的卡片要标明来源，否则用户不知道它属于哪个集。
    expect(find.textContaining('其他集'), findsOneWidget);
  });

  testWidgets('点「恢复」把整个卡片集恢复回书架', (WidgetTester tester) async {
    final ({FakeDeckRepository decks, FakeCardRepository cards}) seed = _seedTrash();
    await seed.decks.deleteDeck('1');
    await _pumpTrash(tester, decks: seed.decks, cards: seed.cards);

    await tester.tap(find.byKey(const ValueKey<String>('trash_restore_deck_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('trash_restore_deck_confirm')));
    await tester.pumpAndSettle();

    final List<TrashedDeck> trashed = await seed.decks.fetchTrashedDecks();
    expect(trashed, isEmpty);
    expect((await seed.decks.fetchDecks(limit: 20)).items, hasLength(2));
    // 卡片跟着集一起回来。
    expect((await seed.cards.fetchCards('1', limit: 10)).items, hasLength(1));
  });

  testWidgets('恢复撞上同名卡片集：提示重名，回收站里的集原样留着', (WidgetTester tester) async {
    final ({FakeDeckRepository decks, FakeCardRepository cards}) seed = _seedTrash();
    await seed.decks.deleteDeck('1');
    // 回收站不占名：删除后又能用同名新建一个。
    await seed.decks.createDeck(title: '奶蛙家族图鉴');
    await _pumpTrash(tester, decks: seed.decks, cards: seed.cards);

    await tester.tap(find.byKey(const ValueKey<String>('trash_restore_deck_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('trash_restore_deck_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('书架里已有同名卡片集，换一个名字吧'), findsOneWidget);
    expect(await seed.decks.fetchTrashedDecks(), hasLength(1));
  });

  testWidgets('单张恢复：选「新建卡片集」后卡片进新集', (WidgetTester tester) async {
    final ({FakeDeckRepository decks, FakeCardRepository cards}) seed = _seedTrash();
    await seed.cards.deleteCard('c2');
    await _pumpTrash(tester, decks: seed.decks, cards: seed.cards);

    await tester.tap(find.byKey(const ValueKey<String>('trash_restore_card_c2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('trash_restore_to_new')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey<String>('trash_restore_new_title')), '奶蛋恢复');
    await tester.tap(find.byKey(const ValueKey<String>('trash_restore_card_confirm')));
    await tester.pumpAndSettle();

    expect(await seed.cards.fetchStandaloneTrashedCards(), isEmpty);
    final List<Deck> decks = (await seed.decks.fetchDecks(limit: 20)).items;
    final Deck restored = decks.singleWhere((Deck deck) => deck.title == '奶蛋恢复');
    expect((await seed.cards.fetchCards(restored.id, limit: 10)).items, hasLength(1));
  });

  testWidgets('多选：逐条勾选后永久删除，回收站里的东西被抹掉', (WidgetTester tester) async {
    final ({FakeDeckRepository decks, FakeCardRepository cards}) seed = _seedTrash();
    await seed.cards.deleteCard('c2');
    await seed.decks.deleteDeck('1');
    await _pumpTrash(tester, decks: seed.decks, cards: seed.cards);

    // 进入多选：此时还没有选中，底部按钮不可点。
    await tester.tap(find.byKey(const ValueKey<String>('trash_select_enter')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('trash_restore_deck_1')), findsNothing);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey<String>('trash_purge_selected')))
          .onPressed,
      isNull,
    );

    // 逐条勾：先勾卡片集，再勾那张单删的卡片。
    await tester.tap(find.byKey(const ValueKey<String>('trash_deck_row_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('trash_card_row_c2')));
    await tester.pumpAndSettle();
    expect(find.text('已选 2 项'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('trash_purge_selected')));
    await tester.pumpAndSettle();
    // 确认框必须写清「无法恢复」。
    expect(find.textContaining('无法恢复'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('trash_purge_confirm')));
    await tester.pumpAndSettle();

    expect(await seed.decks.fetchTrashedDecks(), isEmpty);
    expect(await seed.cards.fetchStandaloneTrashedCards(), isEmpty);
    expect(find.byKey(const ValueKey<String>('trash_empty')), findsOneWidget);
    // 永久删除不动正常数据：另一个卡片集还在书架上。
    expect((await seed.decks.fetchDecks(limit: 20)).items, hasLength(1));
  });

  testWidgets('全选后永久删除：一次清空回收站', (WidgetTester tester) async {
    final ({FakeDeckRepository decks, FakeCardRepository cards}) seed = _seedTrash();
    await seed.cards.deleteCard('c2');
    await seed.decks.deleteDeck('1');
    await _pumpTrash(tester, decks: seed.decks, cards: seed.cards);

    await tester.tap(find.byKey(const ValueKey<String>('trash_select_enter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('trash_select_all')));
    await tester.pumpAndSettle();
    expect(find.text('已选 2 项'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('trash_purge_selected')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('trash_purge_confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('trash_empty')), findsOneWidget);
    expect(await seed.decks.fetchTrashedDecks(), isEmpty);
    expect(await seed.cards.fetchStandaloneTrashedCards(), isEmpty);
  });

  testWidgets('永久删除确认框点取消：回收站原样保留', (WidgetTester tester) async {
    final ({FakeDeckRepository decks, FakeCardRepository cards}) seed = _seedTrash();
    await seed.decks.deleteDeck('1');
    await _pumpTrash(tester, decks: seed.decks, cards: seed.cards);

    await tester.tap(find.byKey(const ValueKey<String>('trash_select_enter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('trash_select_all')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('trash_purge_selected')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('trash_purge_cancel')));
    await tester.pumpAndSettle();

    expect(await seed.decks.fetchTrashedDecks(), hasLength(1));
    expect(find.byKey(const ValueKey<String>('trash_deck_row_1')), findsOneWidget);
  });

  test('回收站角标数量 = 卡片集数 + 单删卡片数', () async {
    final ({FakeDeckRepository decks, FakeCardRepository cards}) seed = _seedTrash();
    await seed.cards.deleteCard('c2');
    await seed.decks.deleteDeck('1');

    final ProviderContainer container = ProviderContainer.test(
      overrides: [
        deckRepositoryProvider.overrideWithValue(seed.decks),
        cardRepositoryProvider.overrideWithValue(seed.cards),
      ],
    );

    expect(await container.read(trashCountProvider.future), 2);
  });
}
