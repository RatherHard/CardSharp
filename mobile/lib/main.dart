import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/di/repository_providers.dart';
import 'core/di/service_providers.dart';
import 'core/storage/app_database.dart';
import 'core/storage/storage_providers.dart';
import 'features/auth/data/auth_storage.dart';
import 'features/auth/data/fake_auth_repository.dart';
import 'features/cards/data/local_card_repository.dart';
import 'features/decks/data/asset_bundled_deck_loader.dart';
import 'features/decks/data/file_deck_cover_service.dart';
import 'features/decks/data/local_deck_repository.dart';
import 'features/decks/data/system_import_file_picker.dart';

/// 组合根（composition root）：全仓库唯一一处把 domain 端口接到具体实现的地方。
///
/// 约定（`AGENTS.md` §2.1）：
/// - application 层只依赖 `core/di/repository_providers.dart` 里的端口；
/// - 实现类（`Local*` / `Fake*` / 将来的 `Http*`）只允许出现在这里；
/// - 接后端时改这里的 override 即可，业务代码零改动。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 本地库按用户分库：换账号就是换一个文件，用户之间物理隔离。
  // 用户 id **从 provider 读**（而不是直接用常量），这样接后端后只改
  // `currentUserIdProvider` 的实现，数据库文件名自动跟着变。
  final ProviderContainer container = ProviderContainer();
  final String userId = container.read(currentUserIdProvider);
  container.dispose();

  // 用 `driftDatabase` 而不是自己 `NativeDatabase(File)`：后者在安卓上会直接
  // 打开系统 `libsqlite3.so`，部分机型被限制（表现为「卡片集加载失败」）；
  // `driftDatabase` 走 `sqlite3_flutter_libs` 提供的原生库。
  final AppDatabase database = AppDatabase(driftDatabase(name: databaseFileNameFor(userId)));

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository(const SecureAuthStorage())),
        cardRepositoryProvider.overrideWithValue(LocalCardRepository(database)),
        deckRepositoryProvider.overrideWithValue(LocalDeckRepository(database)),
        // 本机能力：系统文件选择器、内置示例 asset、封面图存储。
        // 三者都是端口，实现类只允许出现在这个组合根里。
        importFilePickerProvider.overrideWithValue(const SystemImportFilePicker()),
        bundledDeckLoaderProvider.overrideWithValue(const AssetBundledDeckLoader()),
        deckCoverServiceProvider.overrideWithValue(FileDeckCoverService()),
      ],
      child: const CardSharpApp(),
    ),
  );
}
