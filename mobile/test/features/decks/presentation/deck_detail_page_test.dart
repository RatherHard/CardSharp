import 'package:cardsharp/core/di/repository_providers.dart';
import 'package:cardsharp/core/theme/app_theme.dart';
import 'package:cardsharp/features/cards/data/fake_card_repository.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:cardsharp/features/decks/presentation/deck_detail_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' hide Card;

Future<void> _pumpDetail(
  WidgetTester tester, {
  required Deck deck,
  List<Card> cards = const <Card>[],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      // Riverpod 3 未导出 Override 类型，交给类型推断。
      overrides: [
        deckRepositoryProvider.overrideWithValue(FakeDeckRepository(<Deck>[deck])),
        cardRepositoryProvider.overrideWithValue(
          FakeCardRepository(<String, List<Card>>{deck.id: cards}),
        ),
      ],
      // 用真实主题：否则「主题里的按钮 minimumSize 导致 Row 内无限宽」这类问题测不出来。
      child: MaterialApp(
        theme: AppTheme.light,
        home: DeckDetailPage(deckId: deck.id),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Card _card(String id, String plaintext, String ciphertext, int order) {
  return Card(
    id: id,
    deckId: '1',
    sortOrder: order,
    fields: CardFields(plaintext: plaintext, ciphertext: ciphertext),
  );
}

void main() {
  const Deck deckWithDescription = Deck(
    id: '1',
    title: '生物学基础',
    description: '细胞结构与代谢',
    color: '#FF0000',
  );

  testWidgets('显示卡片集名称、简介与封面', (WidgetTester tester) async {
    await _pumpDetail(tester, deck: deckWithDescription);

    expect(find.byKey(const ValueKey<String>('deck_detail_title')), findsOneWidget);
    expect(find.text('生物学基础'), findsWidgets);
    expect(find.text('细胞结构与代谢'), findsOneWidget);
    expect(find.text('0 张卡片'), findsOneWidget);
  });

  testWidgets('简介为空时显示灰色占位「添加简介」', (WidgetTester tester) async {
    await _pumpDetail(
      tester,
      deck: const Deck(id: '1', title: '空简介'),
    );

    expect(find.byKey(const ValueKey<String>('deck_detail_description')), findsOneWidget);
    expect(find.text('添加简介'), findsOneWidget);
  });

  testWidgets('长按占位可以新增简介', (WidgetTester tester) async {
    await _pumpDetail(
      tester,
      deck: const Deck(id: '1', title: '空简介'),
    );

    await tester.longPress(find.byKey(const ValueKey<String>('deck_detail_description')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('deck_edit_description_field')),
      '新写的简介',
    );
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('新写的简介'), findsOneWidget);
    expect(find.text('添加简介'), findsNothing);
  });

  testWidgets('没有卡片时显示空态', (WidgetTester tester) async {
    await _pumpDetail(tester, deck: deckWithDescription);

    expect(find.byKey(const ValueKey<String>('deck_detail_no_cards')), findsOneWidget);
  });

  testWidgets('有卡片时按顺序显示序号与卡片名，暗文不显示', (WidgetTester tester) async {
    await _pumpDetail(
      tester,
      deck: deckWithDescription,
      cards: <Card>[_card('c1', '奶蛙', '绿眼睛和浅色的肚皮', 0), _card('c2', '奶蛋', '圆润的黄色蛋形角色', 1)],
    );

    // 每张卡是一个独立的圆角长条，序号和卡片名都在条内。
    expect(find.byKey(const ValueKey<String>('deck_card_bar_c1')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('deck_card_bar_c2')), findsOneWidget);
    expect(find.text('奶蛙'), findsOneWidget);
    expect(find.text('奶蛋'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    // 列表不展示暗文内容，避免剧透答案。
    expect(find.text('绿眼睛和浅色的肚皮'), findsNothing);
    expect(find.text('圆润的黄色蛋形角色'), findsNothing);
  });

  testWidgets('运行按钮存在', (WidgetTester tester) async {
    await _pumpDetail(tester, deck: deckWithDescription);

    expect(find.byKey(const ValueKey<String>('deck_run_button')), findsOneWidget);
  });

  testWidgets('长按名称进入原地编辑，回车后标题更新', (WidgetTester tester) async {
    await _pumpDetail(tester, deck: deckWithDescription);

    await tester.longPress(find.byKey(const ValueKey<String>('deck_detail_title')));
    await tester.pumpAndSettle();

    // 原地出现输入框，而不是弹窗。
    final Finder field = find.byKey(const ValueKey<String>('deck_edit_name_field'));
    expect(field, findsOneWidget);

    await tester.enterText(field, '改过的名字');
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('改过的名字'), findsWidgets);
  });

  testWidgets('卡片编辑框里的序号从 1 开始', (WidgetTester tester) async {
    await _pumpDetail(
      tester,
      deck: deckWithDescription,
      cards: <Card>[_card('c1', '第一张', '答案', 0)],
    );

    await tester.longPress(find.byKey(const ValueKey<String>('deck_card_c1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('card_action_edit')));
    await tester.pumpAndSettle();

    final TextField orderField = tester.widget<TextField>(
      find.byKey(const ValueKey<String>('card_edit_order')),
    );
    expect(orderField.controller?.text, '1');
  });

  testWidgets('长按卡片弹出操作，选删除并确认后卡片消失', (WidgetTester tester) async {
    await _pumpDetail(
      tester,
      deck: deckWithDescription,
      cards: <Card>[_card('c1', '会被删掉的卡片', '答案', 0)],
    );

    await tester.longPress(find.byKey(const ValueKey<String>('deck_card_c1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('card_action_delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('card_delete_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('会被删掉的卡片'), findsNothing);
  });

  testWidgets('多选模式批量删除', (WidgetTester tester) async {
    await _pumpDetail(
      tester,
      deck: deckWithDescription,
      cards: <Card>[_card('c1', '第一张卡片', '答案一', 0), _card('c2', '第二张卡片', '答案二', 1)],
    );

    await tester.tap(find.byKey(const ValueKey<String>('multi_select_enter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('deck_card_c1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('multi_select_delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('batch_delete_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('第一张卡片'), findsNothing);
    expect(find.text('第二张卡片'), findsOneWidget);
  });

  testWidgets('没有卡片时多选入口不可点', (WidgetTester tester) async {
    await _pumpDetail(tester, deck: deckWithDescription);

    final TextButton button = tester.widget<TextButton>(
      find.byKey(const ValueKey<String>('multi_select_enter')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('窄屏 360dp + 长标题：右上角「导入封面」「多选」不撑破 AppBar', (WidgetTester tester) async {
    // 真机宽度按 360dp 算是本项目的下限；AppBar 里塞两个文字按钮后最容易在这里溢出。
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await _pumpDetail(
      tester,
      deck: const Deck(id: '1', title: '一个很长很长的卡片集标题用来挤压导航栏'),
    );

    expect(find.byKey(const ValueKey<String>('deck_cover_import')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('multi_select_enter')), findsOneWidget);
    // 溢出会以 FlutterError 形式挂在测试上，这里显式取出并断言没有。
    expect(tester.takeException(), isNull);
  });
}
