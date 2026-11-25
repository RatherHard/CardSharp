import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/auth_repository.dart';
import '../../features/cards/domain/card_repository.dart';
import '../../features/decks/domain/deck_repository.dart';

/// 仓储端口（domain 接口）的唯一声明处。
///
/// 分层约定（`AGENTS.md` §5.2：Widget → Notifier → UseCase → Repository）：
/// - 这里**只 import domain**，不出现任何 data 层实现；
/// - 具体实现（`Fake*Repository` / 将来的 `Http*Repository`）由组合根
///   `main.dart` 通过 `overrideWithValue` 注入；
/// - 因此 application 层永远看不到实现类，接后端时只改组合根一行。
///
/// 故意不提供「默认实现」：忘记注入时立刻抛错，比悄悄用上假数据安全——
/// 否则线上会带着假仓储发版。
final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>(
  (Ref ref) => throw StateError('authRepositoryProvider 未注入：请在组合根 main.dart 覆盖'),
);

final Provider<CardRepository> cardRepositoryProvider = Provider<CardRepository>(
  (Ref ref) => throw StateError('cardRepositoryProvider 未注入：请在组合根 main.dart 覆盖'),
);

final Provider<DeckRepository> deckRepositoryProvider = Provider<DeckRepository>(
  (Ref ref) => throw StateError('deckRepositoryProvider 未注入：请在组合根 main.dart 覆盖'),
);
