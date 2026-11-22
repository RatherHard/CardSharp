import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';

/// 路由表。
///
/// 约定：路径使用 kebab-case；需要深链的页面（推送跳转）必须在此注册。
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (_, _) => const HomeScreen(),
    ),
  ],
);
