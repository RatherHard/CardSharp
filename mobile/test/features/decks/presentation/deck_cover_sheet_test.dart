import 'dart:io';

import 'package:cardsharp/core/di/repository_providers.dart';
import 'package:cardsharp/core/di/service_providers.dart';
import 'package:cardsharp/core/theme/app_theme.dart';
import 'package:cardsharp/features/cards/data/fake_card_repository.dart';
import 'package:cardsharp/features/decks/domain/deck_cover_service.dart';
import 'package:cardsharp/features/decks/application/decks_controller.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:cardsharp/features/decks/presentation/deck_detail_page.dart';
import 'package:cardsharp/features/decks/presentation/widgets/deck_cover.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' hide Card;

/// 假封面服务：记住调用、返回预设路径，用于验证「长按封面 → 菜单 → 选图」的接线。
class _FakeDeckCoverService implements DeckCoverService {
  _FakeDeckCoverService({this.savedPath});

  final String? savedPath;
  final List<String> pickCalls = <String>[];
  final List<String> removeCalls = <String>[];
  String? currentPath;

  @override
  Future<String?> readCoverPath(String deckId) async => currentPath;

  @override
  Future<String?> pickAndSaveCover(String deckId) async {
    pickCalls.add(deckId);
    currentPath = savedPath;
    return savedPath;
  }

  @override
  Future<void> removeCover(String deckId) async {
    removeCalls.add(deckId);
    currentPath = null;
  }
}

const Deck _deck = Deck(id: '1', title: '生物学基础');

/// 造一个临时封面文件，测试结束自动删掉。
///
/// 必须用同步 IO：`testWidgets` 跑在 fake-async 区，`await` 真实 IO 的 Future 永远不完成，
/// 会把 `flutter test` 整个挂死（连 `--timeout` 都不触发）。
File _tempCover() {
  final Directory dir = Directory.systemTemp.createTempSync('cover_widget_');
  addTearDown(() => dir.deleteSync(recursive: true));
  final File cover = File('${dir.path}${Platform.pathSeparator}cover.png');
  cover.writeAsBytesSync(<int>[137, 80, 78, 71]);
  return cover;
}

Future<void> _pumpDetail(WidgetTester tester, _FakeDeckCoverService service) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        deckRepositoryProvider.overrideWithValue(FakeDeckRepository(<Deck>[_deck])),
        cardRepositoryProvider.overrideWithValue(FakeCardRepository()),
        deckCoverServiceProvider.overrideWithValue(service),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const DeckDetailPage(deckId: '1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('长按封面弹出菜单：换图 / 换颜色，没有封面图时不显示移除项', (WidgetTester tester) async {
    final _FakeDeckCoverService service = _FakeDeckCoverService();
    await _pumpDetail(tester, service);

    await tester.longPress(find.byType(DeckCover));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('deck_cover_sheet')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('deck_cover_pick_image')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('deck_cover_pick_color')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('deck_cover_remove_image')), findsNothing);
  });

  testWidgets('菜单里选「选择本地图片」会调用封面服务', (WidgetTester tester) async {
    final File cover = _tempCover();

    final _FakeDeckCoverService service = _FakeDeckCoverService(savedPath: cover.path);
    await _pumpDetail(tester, service);

    await tester.longPress(find.byType(DeckCover));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('deck_cover_pick_image')));
    await tester.pumpAndSettle();

    expect(service.pickCalls, <String>['1']);
  });

  testWidgets('已有自定义封面时，菜单出现「移除封面图」并能移除', (WidgetTester tester) async {
    final File cover = _tempCover();

    final _FakeDeckCoverService service = _FakeDeckCoverService(savedPath: cover.path)
      ..currentPath = cover.path;
    await _pumpDetail(tester, service);

    await tester.longPress(find.byType(DeckCover));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('deck_cover_remove_image')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('deck_cover_remove_image')));
    await tester.pumpAndSettle();

    expect(service.removeCalls, <String>['1']);
  });

  testWidgets('右上角「导入封面」按钮和「多选」并排，点击会调用封面服务', (WidgetTester tester) async {
    final File cover = _tempCover();
    final _FakeDeckCoverService service = _FakeDeckCoverService(savedPath: cover.path);
    await _pumpDetail(tester, service);

    expect(find.byKey(const ValueKey<String>('deck_cover_import')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('multi_select_enter')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('deck_cover_import')));
    await tester.pumpAndSettle();

    expect(service.pickCalls, <String>['1']);
  });

  test('删除卡片集时清掉本机封面副本', () async {
    final _FakeDeckCoverService service = _FakeDeckCoverService();
    final ProviderContainer container = ProviderContainer.test(
      overrides: [
        deckRepositoryProvider.overrideWithValue(FakeDeckRepository(<Deck>[_deck])),
        deckCoverServiceProvider.overrideWithValue(service),
      ],
    );

    await container.read(decksControllerProvider.future);
    await container.read(decksControllerProvider.notifier).delete('1');

    expect(service.removeCalls, <String>['1']);
  });
}
