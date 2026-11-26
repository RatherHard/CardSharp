import 'package:cardsharp/core/di/repository_providers.dart';
import 'package:cardsharp/core/network/page.dart';
import 'package:cardsharp/core/theme/app_theme.dart';
import 'package:cardsharp/features/cards/data/fake_card_repository.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:cardsharp/features/review/presentation/review_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' hide Card;

const Deck _deck = Deck(id: '1', title: '奶蛙家族图鉴');

Card _card(String id, String plaintext, String ciphertext, {String? question}) {
  return Card(
    id: id,
    deckId: _deck.id,
    fields: CardFields(plaintext: plaintext, ciphertext: ciphertext, question: question),
  );
}

final List<Card> _twoCards = <Card>[
  _card('c1', '奶蛙', '绿眼睛和浅色的肚皮', question: '奶蛙最明显的两个外观特征是什么？'),
  _card('c2', '奶蛋', '圆滚滚、还没长出四肢', question: '奶蛋的整体外形是什么样的？'),
];

Future<void> _pumpReview(WidgetTester tester, {List<Card>? cards, bool failToLoad = false}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        deckRepositoryProvider.overrideWithValue(FakeDeckRepository(<Deck>[_deck])),
        cardRepositoryProvider.overrideWithValue(
          failToLoad
              ? _BrokenCardRepository()
              : FakeCardRepository(<String, List<Card>>{_deck.id: cards ?? _twoCards}),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const ReviewPage(deckId: '1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('进入复习先看到第一张问题（问句）、进度条，答案不显示', (WidgetTester tester) async {
    await _pumpReview(tester);

    expect(find.byKey(const ValueKey<String>('review_progress')), findsOneWidget);
    expect(find.text('第 1 / 2 张'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('review_question')), findsOneWidget);
    expect(find.text('奶蛙最明显的两个外观特征是什么？'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('review_answer')), findsNothing);
    expect(find.byKey(const ValueKey<String>('review_show_answer')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('review_next')), findsNothing);
  });

  testWidgets('没有 question 字段时问题回退成明文（卡片名）', (WidgetTester tester) async {
    await _pumpReview(tester, cards: <Card>[_card('c1', '奶蛙', '绿眼睛')]);

    expect(find.text('奶蛙'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('review_question')), findsOneWidget);
  });

  testWidgets('点「查看」翻面显示答案，并出现「查看本卡片」与「下一个」', (WidgetTester tester) async {
    await _pumpReview(tester);

    await tester.tap(find.byKey(const ValueKey<String>('review_show_answer')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('review_answer')), findsOneWidget);
    expect(find.text('绿眼睛和浅色的肚皮'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('review_question')), findsNothing);
    expect(find.byKey(const ValueKey<String>('review_open_card')), findsOneWidget);
    expect(find.text('查看本卡片'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('review_next')), findsOneWidget);
    expect(find.text('下一个'), findsOneWidget);
  });

  testWidgets('点「查看本卡片」在不跳页的情况下翻出卡片正文，可「收起」翻回答案', (WidgetTester tester) async {
    await _pumpReview(tester);

    await tester.tap(find.byKey(const ValueKey<String>('review_show_answer')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('review_open_card')));
    await tester.pumpAndSettle();

    // 卡片正文：名字、暗文、Agent 区、输入占位都在，答案面消失。
    expect(find.byKey(const ValueKey<String>('card_detail_name')), findsOneWidget);
    expect(find.text('奶蛙'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('card_detail_definition')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('card_agent_section')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('card_input_section')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('review_answer')), findsNothing);
    expect(find.byKey(const ValueKey<String>('review_hide_card')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('review_next')), findsOneWidget);

    // 小图完整显示：96×96 框内 contain，不裁切。
    final Image thumb = tester.widget<Image>(find.byType(Image));
    expect(thumb.fit, BoxFit.contain);
    expect(thumb.width, 96);
    expect(thumb.height, 96);

    await tester.tap(find.byKey(const ValueKey<String>('review_hide_card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('review_answer')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('card_detail_name')), findsNothing);
  });

  testWidgets('点「下一个」推进到第二张并翻回问题面，最后一张按钮变「完成」', (WidgetTester tester) async {
    await _pumpReview(tester);

    await tester.tap(find.byKey(const ValueKey<String>('review_show_answer')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('review_next')));
    await tester.pumpAndSettle();

    expect(find.text('第 2 / 2 张'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('review_question')), findsOneWidget);
    expect(find.text('奶蛋的整体外形是什么样的？'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('review_answer')), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('review_show_answer')));
    await tester.pumpAndSettle();
    expect(find.text('完成'), findsOneWidget);
    expect(find.text('下一个'), findsNothing);
  });

  testWidgets('看完最后一张显示总结，可「再看一遍」回到第一张', (WidgetTester tester) async {
    await _pumpReview(tester, cards: <Card>[_twoCards.first]);

    await tester.tap(find.byKey(const ValueKey<String>('review_show_answer')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('review_next')));
    await tester.pumpAndSettle();

    expect(find.text('这一轮看完了'), findsOneWidget);
    expect(find.text('共看完 1 张卡片'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('review_restart')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('review_restart')));
    await tester.pumpAndSettle();

    expect(find.text('第 1 / 1 张'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('review_question')), findsOneWidget);
  });

  testWidgets('卡片集没有卡片时给出空态提示', (WidgetTester tester) async {
    await _pumpReview(tester, cards: const <Card>[]);

    expect(find.text('这个卡片集还没有卡片'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('review_show_answer')), findsNothing);
  });

  testWidgets('卡片加载失败时给出提示与重试', (WidgetTester tester) async {
    await _pumpReview(tester, failToLoad: true);

    expect(find.text('卡片加载失败'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('review_retry')), findsOneWidget);
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
