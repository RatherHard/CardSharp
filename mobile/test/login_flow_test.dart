import 'package:cardsharp/app.dart';
import 'package:cardsharp/features/auth/application/auth_controller.dart';
import 'package:cardsharp/features/auth/data/fake_auth_repository.dart';
import 'package:cardsharp/features/auth/domain/development_account.dart';
import 'package:cardsharp/features/decks/application/decks_controller.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
      ],
      child: const CardSharpApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('未登录先进登录页，看不到任何卡片集', (WidgetTester tester) async {
    await _pumpApp(tester);

    expect(find.byKey(const ValueKey<String>('login_submit_button')), findsOneWidget);
    expect(find.text('卡片集1'), findsNothing);
  });

  testWidgets('账号密码错误显示错误提示', (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.enterText(find.byKey(const ValueKey<String>('login_username_field')), 'test');
    await tester.enterText(find.byKey(const ValueKey<String>('login_password_field')), 'bad');
    await tester.tap(find.byKey(const ValueKey<String>('login_submit_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('login_error_text')), findsOneWidget);
  });

  testWidgets('测试账号登录后进入书架，显示 6 个内置卡片集', (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.enterText(
      find.byKey(const ValueKey<String>('login_username_field')),
      DevelopmentAccount.username,
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('login_password_field')),
      DevelopmentAccount.password,
    );
    await tester.tap(find.byKey(const ValueKey<String>('login_submit_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('shelf_search_field')), findsOneWidget);
    for (int i = 1; i <= 6; i++) {
      expect(find.text('卡片集$i'), findsOneWidget);
    }
  });

  testWidgets('侧栏显示用户名与退出登录，退出后回到登录页', (WidgetTester tester) async {
    await _pumpApp(tester);
    await tester.enterText(
      find.byKey(const ValueKey<String>('login_username_field')),
      DevelopmentAccount.username,
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('login_password_field')),
      DevelopmentAccount.password,
    );
    await tester.tap(find.byKey(const ValueKey<String>('login_submit_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('shelf_menu_button')));
    await tester.pumpAndSettle();
    expect(find.text('test'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('drawer_sign_out_button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('drawer_sign_out_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('login_submit_button')), findsOneWidget);
  });
}
