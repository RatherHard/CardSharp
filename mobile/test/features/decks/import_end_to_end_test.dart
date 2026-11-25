import 'package:cardsharp/core/di/repository_providers.dart';
import 'package:cardsharp/app.dart';
import 'package:cardsharp/features/auth/data/fake_auth_repository.dart';
import 'package:cardsharp/features/auth/domain/development_account.dart';
import 'package:cardsharp/features/cards/data/fake_card_repository.dart';
import 'package:cardsharp/features/decks/application/import_file_picker.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/in_memory_auth_storage.dart';

import 'package:material_ui/material_ui.dart';

const String _sampleJson = '''
{
  "title": "奶蛙家族图鉴",
  "description": "测试简介",
  "cards": [
    {"plaintext": "奶蛙最明显的特征是什么？", "ciphertext": "绿眼睛和浅色肚皮"},
    {"plaintext": "奶蛋是什么形状？", "ciphertext": "圆润的黄色蛋形"}
  ]
}
''';

class _FakePicker implements ImportFilePicker {
  const _FakePicker();

  @override
  Future<String?> pickJsonText() async => _sampleJson;
}

/// 端到端复现真机路径：登录 → 从菜单导入 → 点开卡片集 → 看卡片是否显示。
void main() {
  testWidgets('导入后点进详情页能看到卡片', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository(InMemoryAuthStorage())),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          cardRepositoryProvider.overrideWithValue(FakeCardRepository()),
          importFilePickerProvider.overrideWithValue(const _FakePicker()),
        ],
        child: const CardSharpApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 登录
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

    // 从「+」菜单导入
    await tester.tap(find.byKey(const ValueKey<String>('shelf_create_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('shelf_menu_import')));
    await tester.pumpAndSettle();

    // 打开导入的卡片集
    await tester.tap(find.text('奶蛙家族图鉴'));
    await tester.pumpAndSettle();

    expect(find.text('奶蛙最明显的特征是什么？'), findsOneWidget);
    expect(find.text('奶蛋是什么形状？'), findsOneWidget);
  });
}
