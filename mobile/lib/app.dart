import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// 应用根组件。
///
/// 职责仅限于：装配主题、路由、本地化。业务逻辑一律下沉到 feature 层。
class CardSharpApp extends StatelessWidget {
  const CardSharpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CardSharp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
