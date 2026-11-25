import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/di/repository_providers.dart';
import 'features/auth/data/auth_storage.dart';
import 'features/auth/data/fake_auth_repository.dart';
import 'features/cards/data/fake_card_repository.dart';
import 'features/decks/data/fake_deck_repository.dart';

/// 组合根（composition root）：全仓库唯一一处把 domain 端口接到具体实现的地方。
///
/// 约定（`AGENTS.md` §5.2）：
/// - application 层只依赖 `core/di/repository_providers.dart` 里的端口；
/// - 实现类（`Fake*` / 将来的 `Http*`）只允许出现在这里；
/// - 接后端时改这个文件的 4 行 override 即可，业务代码零改动。
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 卡片仓储先建出来：假卡片集仓储需要用它统计每个卡片集里的卡片数。
  final FakeCardRepository cards = FakeCardRepository();

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository(const SecureAuthStorage())),
        cardRepositoryProvider.overrideWithValue(cards),
        deckRepositoryProvider.overrideWithValue(FakeDeckRepository(kSeedDecks, cards.countFor)),
      ],
      child: const CardSharpApp(),
    ),
  );
}
