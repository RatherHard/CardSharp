import 'package:flutter/widgets.dart';

/// 卡片渲染器协议（扩展点）。
///
/// 新增卡片类型（日程、灵感……）时，只需实现本接口并注册到
/// [cardRenderers]，**不需要**修改通用卡片列表/详情页。
abstract interface class CardRenderer {
  /// 与后端 `card_type` 一致的标识。
  String get typeId;

  /// 正面（自检提示）。
  Widget buildFront(BuildContext context, Map<String, dynamic> fields);

  /// 背面（答案）。
  Widget buildBack(BuildContext context, Map<String, dynamic> fields);
}

/// 未知类型的兜底渲染器，保证向前兼容（后端新增类型时不崩溃）。
class FallbackCardRenderer implements CardRenderer {
  const FallbackCardRenderer();

  @override
  String get typeId => '__fallback__';

  @override
  Widget buildFront(BuildContext context, Map<String, dynamic> fields) => Text(fields.toString());

  @override
  Widget buildBack(BuildContext context, Map<String, dynamic> fields) => Text(fields.toString());
}

/// 渲染器注册表。
final Map<String, CardRenderer> cardRenderers = <String, CardRenderer>{};

/// 按类型取渲染器，未注册时降级。
CardRenderer rendererFor(String typeId) => cardRenderers[typeId] ?? const FallbackCardRenderer();
