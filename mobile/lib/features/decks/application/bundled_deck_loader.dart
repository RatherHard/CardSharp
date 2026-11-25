import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 读取**应用内置**的示例卡片集 JSON。
///
/// 用途：没有后端、手机里也没有现成文件时，仍能一键演示「导入 → 卡片列表」整条链路。
/// 与「用户自选文件」走同一套解析与写入逻辑，区别只在数据来源：
/// - 用户自选文件：`ImportFilePicker`（系统文件选择器，SAF）
/// - 内置示例：本接口（Flutter asset）
///
/// 抽成接口的理由与 `ImportFilePicker` 一致：测试可注入假实现，换数据来源只改实现。
abstract interface class BundledDeckLoader {
  /// 返回内置示例卡片集的 JSON 文本。
  Future<String> loadExampleDeckJson();
}

/// 从 Flutter asset 读取示例卡片集。
class AssetBundledDeckLoader implements BundledDeckLoader {
  const AssetBundledDeckLoader();

  /// 与 `pubspec.yaml` 的 `assets: - assets/examples/` 对应。
  static const String exampleDeckAsset = 'assets/examples/deck-sample.json';

  @override
  Future<String> loadExampleDeckJson() => rootBundle.loadString(exampleDeckAsset);
}

final Provider<BundledDeckLoader> bundledDeckLoaderProvider = Provider<BundledDeckLoader>(
  (Ref ref) => const AssetBundledDeckLoader(),
);
