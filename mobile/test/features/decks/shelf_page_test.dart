import 'package:cardsharp/features/decks/application/decks_controller.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:cardsharp/features/decks/domain/deck_repository.dart';
import 'package:cardsharp/features/decks/presentation/shelf_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pumpShelf(
  WidgetTester tester, {
  DeckRepository? repository,
  VoidCallback? onOpenDrawer,
}) async {
  // 默认测试视口 800x600 放不下 7 个瓦片（第 7 个不会被 build），这里加高视口。
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [deckRepositoryProvider.overrideWithValue(repository ?? FakeDeckRepository())],
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

  testWidgets('搜索按名称过滤，无匹配时显示空态', (WidgetTester tester) async {
    await _pumpShelf(tester);

    await tester.enterText(find.byKey(const ValueKey<String>('shelf_search_field')), '卡片集3');
    await tester.pumpAndSettle();
    // 搜索框里也有同样的文字，必须限定在网格内断言。
    expect(_inGrid('卡片集3'), findsOneWidget);
    expect(_inGrid('卡片集1'), findsNothing);

    await tester.enterText(find.byKey(const ValueKey<String>('shelf_search_field')), '不存在的关键词');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('shelf_empty_state')), findsOneWidget);
  });

  testWidgets('新建卡片集：对话框空名时创建按钮禁用', (WidgetTester tester) async {
    await _pumpShelf(tester);

    await tester.tap(find.byKey(const ValueKey<String>('shelf_create_button')));
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
    await tester.enterText(find.byKey(const ValueKey<String>('create_deck_field')), 'TestDeck');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('create_deck_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('TestDeck'), findsOneWidget);
    expect(find.text('0 张卡片'), findsNWidgets(7));
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
  Future<List<Deck>> fetchDecks() async => throw StateError('boom');

  @override
  Future<Deck> createDeck({required String title}) async => throw StateError('boom');

  @override
  Future<void> deleteDeck(String id) async => throw StateError('boom');
}
