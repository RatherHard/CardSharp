import 'package:cardsharp/core/di/repository_providers.dart';
import 'package:cardsharp/core/l10n/app_strings.dart';
import 'package:cardsharp/core/theme/app_theme.dart';
import 'package:cardsharp/core/theme/theme_controller.dart';
import 'package:cardsharp/features/auth/data/fake_auth_repository.dart';
import 'package:cardsharp/features/auth/domain/development_account.dart';
import 'package:cardsharp/features/cards/data/fake_card_repository.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/settings/presentation/settings_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/in_memory_auth_storage.dart';

/// 设置页：账号展示、退出登录、主题切换。
///
/// 主题由 `themeModeControllerProvider` 驱动，测试里把它的值接到
/// `MaterialApp.themeMode` 上，这样「点深色 → 真的切到深色」能被断言。
void main() {
  late InMemoryAuthStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    storage = InMemoryAuthStorage();
  });

  FakeAuthRepository authRepository() => FakeAuthRepository(storage);

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository()),
          cardRepositoryProvider.overrideWithValue(FakeCardRepository()),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
        ],
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final ThemeMode mode = ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;
            return MaterialApp(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: mode,
              home: const SettingsPage(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> signIn() => authRepository().signIn(
    username: DevelopmentAccount.username,
    password: DevelopmentAccount.password,
  );

  testWidgets('未登录时账号区显示「请登录」，退出按钮不可点', (WidgetTester tester) async {
    await pumpSettings(tester);

    expect(
      tester.widget<Text>(find.byKey(const ValueKey<String>('settings_username'))).data,
      AppStrings.drawerGuestName,
    );
    expect(find.text(AppStrings.settingsLocalAccountTag), findsOneWidget);
    final TextButton signOut = tester.widget<TextButton>(
      find.byKey(const ValueKey<String>('settings_sign_out_button')),
    );
    expect(signOut.onPressed, isNull);
  });

  testWidgets('登录后账号区显示用户名，退出登录可点', (WidgetTester tester) async {
    await signIn();
    await pumpSettings(tester);

    expect(
      tester.widget<Text>(find.byKey(const ValueKey<String>('settings_username'))).data,
      DevelopmentAccount.username,
    );
    final TextButton signOut = tester.widget<TextButton>(
      find.byKey(const ValueKey<String>('settings_sign_out_button')),
    );
    expect(signOut.onPressed, isNotNull);
  });

  testWidgets('点「深色」后 MaterialApp 的 themeMode 变成 dark', (WidgetTester tester) async {
    await pumpSettings(tester);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.system);

    await tester.tap(find.text(AppStrings.settingsThemeDark));
    await tester.pumpAndSettle();

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
  });

  testWidgets('点退出登录后回到未登录状态，存储被清空', (WidgetTester tester) async {
    await signIn();
    await pumpSettings(tester);

    await tester.tap(find.byKey(const ValueKey<String>('settings_sign_out_button')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const ValueKey<String>('settings_username'))).data,
      AppStrings.drawerGuestName,
    );
    expect(storage.username, isNull);
  });

  testWidgets('关于区显示版本号', (WidgetTester tester) async {
    await pumpSettings(tester);

    expect(find.byKey(const ValueKey<String>('settings_version_tile')), findsOneWidget);
    expect(find.text(AppStrings.appVersion), findsOneWidget);
  });
}
