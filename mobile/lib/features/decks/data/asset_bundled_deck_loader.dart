import 'package:flutter/services.dart';

import '../domain/bundled_deck_loader.dart';

/// 从 Flutter asset 读取内置示例卡片集。
class AssetBundledDeckLoader implements BundledDeckLoader {
  const AssetBundledDeckLoader();

  /// 与 `pubspec.yaml` 的 `assets: - assets/examples/` 对应。
  static const String kExampleDeckAsset = 'assets/examples/deck-sample.json';

  @override
  Future<String> loadExampleDeckJson() => rootBundle.loadString(kExampleDeckAsset);
}
