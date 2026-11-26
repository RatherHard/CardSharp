import 'package:material_ui/material_ui.dart';

/// 全局主题。
///
/// 设计约束：复习场景以「内容优先」为原则，卡片区域留白充足、
/// 正文行高不低于 1.5，避免长时间阅读疲劳。
abstract final class AppTheme {
  /// 品牌主色（靛蓝），用于强调与进度指示。
  static const Color kSeedColor = Color(0xFF4F46E5);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: kSeedColor, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        // 只统一圆角与内边距，**不设 minimumSize**：
        // Size.fromHeight 会把宽度设成 infinity，按钮一旦放进 Row 就会触发
        // 「BoxConstraints forces an infinite width」并让整块内容渲染失败。
        // 需要通栏的地方（如登录按钮）由页面自己设置。
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(height: 1.55),
        bodyMedium: TextStyle(height: 1.55),
      ),
    );
  }
}
