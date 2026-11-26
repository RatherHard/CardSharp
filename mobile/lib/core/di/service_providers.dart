import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/decks/domain/bundled_deck_loader.dart';
import '../../features/decks/domain/deck_cover_service.dart';
import '../../features/decks/domain/import_file_picker.dart';

/// 平台服务的端口声明处（与 `repository_providers.dart` 分开）。
///
/// 分工（`docs/05-工程规范.md` §2）：
/// - `repository_providers.dart` 只放「数据来源」的 domain 端口；
/// - 这里放「本机能力」（文件选择、封面存储、asset 读取等），
///   端口类型（抽象接口）在对应 feature 的 `domain/` 下，实现类在 `data/` 下；
/// - 一律**不提供默认实现**：忘记在组合根注入时立刻抛错，
///   避免带着某个本机实现或假实现悄悄发版。
final Provider<DeckCoverService> deckCoverServiceProvider = Provider<DeckCoverService>(
  (Ref ref) => throw StateError('deckCoverServiceProvider 未注入：请在组合根 main.dart 覆盖'),
);

final Provider<ImportFilePicker> importFilePickerProvider = Provider<ImportFilePicker>(
  (Ref ref) => throw StateError('importFilePickerProvider 未注入：请在组合根 main.dart 覆盖'),
);

final Provider<BundledDeckLoader> bundledDeckLoaderProvider = Provider<BundledDeckLoader>(
  (Ref ref) => throw StateError('bundledDeckLoaderProvider 未注入：请在组合根 main.dart 覆盖'),
);
