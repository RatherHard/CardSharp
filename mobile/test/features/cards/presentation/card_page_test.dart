import 'package:cardsharp/core/di/repository_providers.dart';
import 'package:cardsharp/core/l10n/app_strings.dart';
import 'package:cardsharp/core/network/page.dart';
import 'package:cardsharp/core/theme/app_theme.dart';
import 'package:cardsharp/features/cards/data/fake_card_repository.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/features/cards/presentation/card_page.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' hide Card;

const Deck _deck = Deck(id: '1', title: '奶蛙家族图鉴');

Card _card({
  String id = 'c1',
  String plaintext = '奶蛙',
  String ciphertext = '一只坐在地铁上的奶蛙',
  String? hint,
  String? extra,
}) {
  return Card(
    id: id,
    deckId: _deck.id,
    fields: CardFields(plaintext: plaintext, ciphertext: ciphertext, hint: hint, extra: extra),
  );
}

Future<void> _pumpCardPage(
  WidgetTester tester, {
  List<Card> cards = const <Card>[],
  String cardId = 'c1',
  bool failToLoad = false,
}) async {
  // 默认视口 800×600 太窄太高，卡片页正文会被挤出可见区（docs/05 §8.2）。
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      // Riverpod 3 未导出 Override 类型，交给类型推断。
      overrides: [
        deckRepositoryProvider.overrideWithValue(FakeDeckRepository(<Deck>[_deck])),
        cardRepositoryProvider.overrideWithValue(
          failToLoad
              ? _BrokenCardRepository()
              : FakeCardRepository(<String, List<Card>>{_deck.id: cards}),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: CardPage(deckId: _deck.id, cardId: cardId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('直接点卡片：大图、名字与「定义」标签都在', (WidgetTester tester) async {
    await _pumpCardPage(tester, cards: <Card>[_card()]);

    expect(find.byKey(const ValueKey<String>('card_detail_image')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('card_detail_name')), findsOneWidget);
    expect(find.text('奶蛙'), findsOneWidget);
    expect(find.text('定义'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('card_detail_definition')), findsOneWidget);
    expect(find.text('一只坐在地铁上的奶蛙'), findsOneWidget);
  });

  testWidgets('有对应成员图时显示图片，没有时才显示「还没有配图」占位', (WidgetTester tester) async {
    // 奶蛙在演示配图表里，奶蛋没有（用别的名字模拟未知角色）。
    await _pumpCardPage(
      tester,
      cards: <Card>[
        _card(),
        _card(id: 'c2', plaintext: '未知角色'),
      ],
      cardId: 'c1',
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('还没有配图'), findsNothing);
  });

  testWidgets('大图完整呈现：按原图比例留框，图片用 contain 不裁切', (WidgetTester tester) async {
    await _pumpCardPage(tester, cards: <Card>[_card()]);

    // 框的比例来自演示资源（奶蛙 614×859），尺寸与解码无关，所以测试里也能量到。
    final AspectRatio frame = tester.widget<AspectRatio>(
      find.ancestor(of: find.byType(Image), matching: find.byType(AspectRatio)),
    );
    expect(frame.aspectRatio, closeTo(614 / 859, 1e-6));

    final Image image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.contain);
    expect(image.width, isNull);
    expect(image.height, isNull);
  });

  testWidgets('没有匹配的成员图时显示占位文案', (WidgetTester tester) async {
    await _pumpCardPage(tester, cards: <Card>[_card(plaintext: '未知角色')]);

    expect(find.byType(Image), findsNothing);
    expect(find.text('还没有配图'), findsOneWidget);
  });

  testWidgets('卡片页只展示名字与定义，不出现 Agent 区、输入占位和星标', (WidgetTester tester) async {
    await _pumpCardPage(tester, cards: <Card>[_card()]);

    expect(find.byKey(const ValueKey<String>('card_agent_section')), findsNothing);
    expect(find.byKey(const ValueKey<String>('card_input_section')), findsNothing);
    expect(find.byKey(const ValueKey<String>('card_page_flip')), findsNothing);
    expect(find.byKey(const ValueKey<String>('card_favorite')), findsNothing);
  });

  testWidgets('答案就是名字本身时，不重复显示「定义」那一段', (WidgetTester tester) async {
    // 迷你世界示例：问的是「谁」，答案只给名字（docs/04 §14.7）。
    await _pumpCardPage(
      tester,
      cards: <Card>[_card(plaintext: '酋长', ciphertext: '酋长', extra: '原始人部落的首领')],
    );

    expect(find.text('酋长'), findsOneWidget);
    expect(find.text(AppStrings.cardDefinitionLabel), findsNothing);
    expect(find.byKey(const ValueKey<String>('card_detail_definition')), findsNothing);
  });

  testWidgets('没有提示与备注时不显示 Tips 区', (WidgetTester tester) async {
    await _pumpCardPage(tester, cards: <Card>[_card()]);

    expect(find.text('Tips'), findsNothing);
    expect(find.byKey(const ValueKey<String>('card_tips_header')), findsNothing);
  });

  testWidgets('Tips 默认折叠，点标题才展开提示与备注', (WidgetTester tester) async {
    await _pumpCardPage(
      tester,
      cards: <Card>[_card(hint: '看地铁', extra: 'naiwahub')],
    );

    // 折叠态：只有标题，内容不渲染。
    expect(find.byKey(const ValueKey<String>('card_tips_header')), findsOneWidget);
    expect(find.text('Tips'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('card_tips_body')), findsNothing);
    expect(find.text('看地铁'), findsNothing);
    expect(find.text('naiwahub'), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('card_tips_header')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('card_tips_body')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('card_detail_hint')), findsOneWidget);
    expect(find.text('看地铁'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('card_detail_extra')), findsOneWidget);
    expect(find.text('naiwahub'), findsOneWidget);

    // 再点一次收回。
    await tester.tap(find.byKey(const ValueKey<String>('card_tips_header')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('card_tips_body')), findsNothing);
  });

  testWidgets('浏览模式不显示问题：页面上没有问号句', (WidgetTester tester) async {
    await _pumpCardPage(tester, cards: <Card>[_card()]);

    // 问答正/背面只在复习页；卡片页出现问号句说明泄漏了问题。
    expect(find.textContaining('？'), findsNothing);
  });

  testWidgets('卡片 id 找不到时显示「这张卡片不存在」', (WidgetTester tester) async {
    await _pumpCardPage(tester, cards: <Card>[_card()], cardId: 'missing');

    expect(find.text('这张卡片不存在'), findsOneWidget);
  });

  testWidgets('卡片加载失败时显示失败与重试按钮', (WidgetTester tester) async {
    await _pumpCardPage(tester, failToLoad: true);

    expect(find.text('卡片加载失败'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('card_retry')), findsOneWidget);
  });
}

/// 读卡片就抛异常，用来验证失败态。
class _BrokenCardRepository extends FakeCardRepository {
  _BrokenCardRepository() : super(const <String, List<Card>>{});

  @override
  Future<PagedResult<Card>> fetchCards(String deckId, {String? cursor, int limit = 50}) {
    throw StateError('后端不可用');
  }
}
