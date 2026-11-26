import 'package:cardsharp/core/di/repository_providers.dart';
import 'package:cardsharp/core/theme/app_theme.dart';
import 'package:cardsharp/features/cards/data/fake_card_repository.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/features/cards/presentation/card_page.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:cardsharp/features/decks/presentation/deck_detail_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' hide Card;

const Deck _deck = Deck(id: '1', title: '奶蛙家族图鉴');

const Card _naiwa = Card(
  id: 'c1',
  deckId: '1',
  fields: CardFields(plaintext: '奶蛙', ciphertext: '一只坐在地铁上的奶蛙'),
);

/// 只搭「详情页 → 卡片页」这一段路由，避免把登录守卫/外壳一起拉进测试。
GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/deck/1',
    routes: <RouteBase>[
      GoRoute(
        path: '/deck/:id',
        builder: (_, GoRouterState state) => DeckDetailPage(deckId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/deck/:id/card/:cardId',
        builder: (_, GoRouterState state) =>
            CardPage(deckId: state.pathParameters['id']!, cardId: state.pathParameters['cardId']!),
      ),
    ],
  );
}

void main() {
  testWidgets('点卡片条进入该卡片的浏览页，看到名字与定义', (WidgetTester tester) async {
    final GoRouter router = _buildRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        // Riverpod 3 未导出 Override 类型，交给类型推断。
        overrides: [
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository(<Deck>[_deck])),
          cardRepositoryProvider.overrideWithValue(
            FakeCardRepository(<String, List<Card>>{
              _deck.id: <Card>[_naiwa],
            }),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('deck_card_c1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('card_detail_name')), findsOneWidget);
    expect(find.text('奶蛙'), findsOneWidget);
    expect(find.text('一只坐在地铁上的奶蛙'), findsOneWidget);
    // 跳的是这一张卡，不是占位页。
    expect(find.byType(CardPage), findsOneWidget);
    expect(router.state.uri.path, '/deck/1/card/c1');
  });
}
