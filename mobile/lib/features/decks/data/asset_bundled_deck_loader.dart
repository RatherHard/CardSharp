import 'package:flutter/services.dart';

import '../domain/bundled_deck_loader.dart';
import '../domain/sample_deck.dart';

/// 从 Flutter asset 读取内置示例卡片集。
class AssetBundledDeckLoader implements BundledDeckLoader {
  const AssetBundledDeckLoader();

  /// 与 `pubspec.yaml` 的 `assets: - assets/examples/` 对应。
  ///
  /// 路径放在 data 层：domain 只认 [SampleDeck]，换存储方式（远端下载等）只改这里。
  static const String kExampleDeckAsset = 'assets/examples/deck-sample.json';
  static const String kMiniWorldDeckAsset = 'assets/examples/mini-world-deck.json';

  @override
  Future<String> loadSampleDeck(SampleDeck sample) => rootBundle.loadString(switch (sample) {
    SampleDeck.naiwaFamily => kExampleDeckAsset,
    SampleDeck.miniWorld => kMiniWorldDeckAsset,
  });
}
