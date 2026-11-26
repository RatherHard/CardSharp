import 'package:cardsharp/core/di/repository_providers.dart';
import 'package:cardsharp/app.dart';
import 'package:cardsharp/features/auth/data/fake_auth_repository.dart';
import 'package:cardsharp/features/auth/domain/development_account.dart';
import 'package:cardsharp/features/cards/data/fake_card_repository.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/core/di/service_providers.dart';
import 'package:cardsharp/features/decks/data/asset_bundled_deck_loader.dart';
import 'package:cardsharp/features/decks/domain/bundled_deck_loader.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck_import.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/in_memory_auth_storage.dart';

import 'package:material_ui/material_ui.dart';

/// 把已经读到的 JSON 直接交给页面。
///
/// 不在 widget 测试里真的走 `rootBundle`：`pumpAndSettle` 用的是假时钟，
/// 真实文件 IO 的 Future 不会在这里完成，导入会静默卡住。资源的真实性由下面
/// 第一个用例单独校验（那里的 `await` 发生在测试体里，是真异步）。
class _InMemoryBundledLoader implements BundledDeckLoader {
  const _InMemoryBundledLoader(this.json);

  final String json;

  @override
  Future<String> loadExampleDeckJson() async => json;
}

/// 内置示例卡片集：资源存在、能被解析、能从菜单一键导入并显示卡片。
///
/// 这条测试挡的是「演示时点了导入示例却没反应」——数据缺失或格式不符都会在这里失败。
void main() {
  test('内置示例资源存在且能被解析成卡片集', () async {
    final String text = await const AssetBundledDeckLoader().loadExampleDeckJson();
    final DeckImport data = parseDeckImport(text);

    expect(data.title, isNotEmpty);
    expect(data.cards.length, greaterThanOrEqualTo(1));

    // 与 docs/03 §4.4 的字数限制保持一致，防止示例自己先违规。
    for (final CardFields card in data.cards) {
      expect(card.plaintext, isNotEmpty);
      expect(card.ciphertext, isNotEmpty);
      expect(card.plaintext.length, lessThanOrEqualTo(kPlaintextMaxLength));
      expect(card.ciphertext.length, lessThanOrEqualTo(kCiphertextMaxLength));
    }
  });

  testWidgets('从「+」菜单导入示例后，详情页能看到卡片', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // 真实文件 IO 必须在 runAsync 里跑：testWidgets 默认是假时钟，
    // 直接 await rootBundle 会永远不返回。
    final String? sampleJson = await tester.runAsync(
      () => const AssetBundledDeckLoader().loadExampleDeckJson(),
    );
    expect(sampleJson, isNotNull);
    final DeckImport expected = parseDeckImport(sampleJson!);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository(InMemoryAuthStorage())),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          cardRepositoryProvider.overrideWithValue(FakeCardRepository()),
          bundledDeckLoaderProvider.overrideWithValue(_InMemoryBundledLoader(sampleJson)),
        ],
        child: const CardSharpApp(),
      ),
    );
    await tester.pumpAndSettle();

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

    // 「+」→ 导入示例卡片集
    await tester.tap(find.byKey(const ValueKey<String>('shelf_create_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('shelf_menu_import_sample')));
    await tester.pumpAndSettle();

    expect(find.text(expected.title), findsOneWidget);

    await tester.tap(find.text(expected.title));
    await tester.pumpAndSettle();

    // 详情页应显示第一张卡的明文，而不是空态。
    expect(find.text('还没有卡片'), findsNothing);
    expect(find.text(expected.cards.first.plaintext), findsOneWidget);
  });
}
