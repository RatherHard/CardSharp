import 'package:cardsharp/core/di/repository_providers.dart';
import 'package:cardsharp/core/network/page.dart';
import 'package:cardsharp/features/cards/data/fake_card_repository.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/core/di/service_providers.dart';
import 'package:cardsharp/features/decks/domain/import_file_picker.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:cardsharp/features/decks/domain/deck_repository.dart';
import 'package:cardsharp/features/decks/domain/trashed_deck.dart';
import 'package:cardsharp/features/decks/presentation/shelf_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' hide Card;

Future<void> _pumpShelf(
  WidgetTester tester, {
  DeckRepository? repository,
  VoidCallback? onOpenDrawer,
  ImportFilePicker? picker,
  Map<String, List<Card>> seedCards = const <String, List<Card>>{},
}) async {
  // 默认测试视口 800x600 放不下 7 个瓦片（第 7 个不会被 build），这里加高视口。
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  // 与 deckRepositoryProvider 的装配保持一致：卡片数由卡片仓储统计。
  final FakeCardRepository cards = FakeCardRepository(seedCards);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cardRepositoryProvider.overrideWithValue(cards),
        deckRepositoryProvider.overrideWithValue(
          repository ?? FakeDeckRepository(kSeedDecks, cards.countFor),
        ),
        if (picker != null) importFilePickerProvider.overrideWithValue(picker),
      ],
      child: MaterialApp(
        home: Scaffold(body: ShelfPage(onOpenDrawer: onOpenDrawer ?? () {})),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _inGrid(String text) =>
    find.descendant(of: find.byType(GridView), matching: find.text(text));

void main() {
  testWidgets('渲染 6 个种子卡片集，卡片数都是 0', (WidgetTester tester) async {
    await _pumpShelf(tester);

    for (int i = 1; i <= 6; i++) {
      expect(find.text('卡片集$i'), findsOneWidget);
    }
    expect(find.text('0 张卡片'), findsNWidgets(6));
  });

  testWidgets('网格固定每行 3 个卡片集', (WidgetTester tester) async {
    await _pumpShelf(tester);

    final GridView grid = tester.widget<GridView>(find.byType(GridView));
    final SliverGridDelegate delegate = grid.gridDelegate;
    expect(delegate, isA<SliverGridDelegateWithFixedCrossAxisCount>());
    expect((delegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount, 3);
  });

  testWidgets('一次搜索：卡片集（同级）在上、卡片（下级）在下', (WidgetTester tester) async {
    await _pumpShelf(tester);

    await tester.enterText(find.byKey(const ValueKey<String>('shelf_search_field')), '卡片集3');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('search_deck_3')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('search_deck_1')), findsNothing);
    expect(find.byKey(const ValueKey<String>('search_section_decks')), findsOneWidget);
    // 这一集没有卡片命中，所以「卡片」那一段不出现。
    expect(find.byKey(const ValueKey<String>('search_section_cards')), findsNothing);
  });

  testWidgets('没有搜索模式切换：搜索框旁只有输入区', (WidgetTester tester) async {
    await _pumpShelf(tester);

    expect(find.byKey(const ValueKey<String>('shelf_search_mode')), findsNothing);
  });

  testWidgets('无匹配时显示搜索空态', (WidgetTester tester) async {
    await _pumpShelf(tester);

    await tester.enterText(find.byKey(const ValueKey<String>('shelf_search_field')), '不存在的关键词');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('search_empty_state')), findsOneWidget);
  });

  testWidgets('清空关键词后回到卡片集网格', (WidgetTester tester) async {
    await _pumpShelf(tester);

    await tester.enterText(find.byKey(const ValueKey<String>('shelf_search_field')), '卡片集3');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('shelf_search_clear')));
    await tester.pumpAndSettle();

    expect(_inGrid('卡片集1'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('search_empty_state')), findsNothing);
  });

  testWidgets('搜卡片内容：卡片集一段为空、卡片一段有结果', (WidgetTester tester) async {
    await _pumpShelf(
      tester,
      seedCards: <String, List<Card>>{
        '1': <Card>[
          const Card(
            id: 'c1',
            deckId: '1',
            fields: CardFields(plaintext: '线粒体的功能是什么？', ciphertext: '产生 ATP'),
          ),
        ],
      },
    );

    await tester.enterText(find.byKey(const ValueKey<String>('shelf_search_field')), 'ATP');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('search_section_decks')), findsNothing);
    expect(find.byKey(const ValueKey<String>('search_section_cards')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('search_card_c1')), findsOneWidget);
    expect(find.text('暗文命中'), findsOneWidget);
  });

  testWidgets('新建卡片集：对话框空名时创建按钮禁用', (WidgetTester tester) async {
    await _pumpShelf(tester);

    await tester.tap(find.byKey(const ValueKey<String>('shelf_create_button')));
    await tester.pumpAndSettle();
    // 「+」现在先弹菜单，需再点「新建卡片集」。
    await tester.tap(find.byKey(const ValueKey<String>('shelf_menu_create')));
    await tester.pumpAndSettle();

    final FilledButton confirm = tester.widget<FilledButton>(
      find.byKey(const ValueKey<String>('create_deck_confirm')),
    );
    expect(confirm.onPressed, isNull);
  });

  testWidgets('新建卡片集后列表多一项', (WidgetTester tester) async {
    await _pumpShelf(tester);

    await tester.tap(find.byKey(const ValueKey<String>('shelf_create_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('shelf_menu_create')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey<String>('create_deck_field')), 'TestDeck');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('create_deck_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('TestDeck'), findsOneWidget);
    expect(find.text('0 张卡片'), findsNWidgets(7));
  });

  testWidgets('从菜单导入卡片集后列表出现新卡片集', (WidgetTester tester) async {
    await _pumpShelf(
      tester,
      picker: const _FakePicker(
        '{"title":"导入的卡片集","cards":[{"fields":{"plaintext":"问一","ciphertext":"答一"}}]}',
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('shelf_create_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('shelf_menu_import')));
    await tester.pumpAndSettle();

    expect(find.text('导入的卡片集'), findsOneWidget);
    expect(find.text('1 张卡片'), findsOneWidget);
  });

  testWidgets('导入非法 JSON 时给出错误提示', (WidgetTester tester) async {
    await _pumpShelf(tester, picker: const _FakePicker('not json at all'));

    await tester.tap(find.byKey(const ValueKey<String>('shelf_create_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('shelf_menu_import')));
    await tester.pumpAndSettle();

    expect(find.text('文件不是有效的 JSON'), findsOneWidget);
  });

  testWidgets('长按卡片集二次确认后删除', (WidgetTester tester) async {
    await _pumpShelf(tester);

    await tester.longPress(find.byKey(const ValueKey<String>('deck_tile_1')));
    await tester.pumpAndSettle();
    expect(find.text('删除卡片集'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('delete_deck_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('卡片集1'), findsNothing);
    expect(find.text('0 张卡片'), findsNWidgets(5));
  });

  testWidgets('取消删除时卡片集保留', (WidgetTester tester) async {
    await _pumpShelf(tester);

    await tester.longPress(find.byKey(const ValueKey<String>('deck_tile_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('delete_deck_cancel')));
    await tester.pumpAndSettle();

    expect(find.text('卡片集2'), findsOneWidget);
  });

  testWidgets('点菜单按钮回调到外层', (WidgetTester tester) async {
    int taps = 0;
    await _pumpShelf(tester, onOpenDrawer: () => taps++);

    await tester.tap(find.byKey(const ValueKey<String>('shelf_menu_button')));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });

  testWidgets('加载失败时显示错误态并可重试', (WidgetTester tester) async {
    await _pumpShelf(tester, repository: _BrokenRepository());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('shelf_error_state')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('shelf_retry_button')), findsOneWidget);
  });
}

class _BrokenRepository implements DeckRepository {
  @override
  Future<PagedResult<Deck>> fetchDecks({String? cursor, int limit = 20}) async =>
      throw StateError('boom');

  @override
  Future<Deck> createDeck({
    required String title,
    String cardType = 'memory',
    Map<String, dynamic> config = const <String, dynamic>{},
  }) async => throw StateError('boom');

  @override
  Future<Deck> updateDeck(String id, {String? title, String? description, String? color}) async =>
      throw StateError('boom');

  @override
  Future<void> deleteDeck(String id) async => throw StateError('boom');

  @override
  Future<List<TrashedDeck>> fetchTrashedDecks() async => throw StateError('boom');

  @override
  Future<void> restoreDeck(String id) async => throw StateError('boom');

  @override
  Future<void> purgeDeck(String id) async => throw StateError('boom');
}

/// 固定返回一段 JSON 文本，用来替代系统文件选择器。
class _FakePicker implements ImportFilePicker {
  const _FakePicker(this.text);

  final String text;

  @override
  Future<String?> pickJsonText() async => text;
}
