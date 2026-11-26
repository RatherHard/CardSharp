import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'core/l10n/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

/// 应用根组件。
///
/// 职责仅限于：装配主题、路由、本地化。业务逻辑一律下沉到 feature 层。
class CardSharpApp extends ConsumerWidget {
  const CardSharpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    // 偏好还没读出来时按「跟随系统」处理：与用户无操作时的默认行为一致。
    final ThemeMode themeMode = ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;
    return MaterialApp.router(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
