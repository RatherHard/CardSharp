import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/shell/presentation/home_shell.dart';
import '../../features/shell/presentation/placeholder_screen.dart';
import '../l10n/app_strings.dart';

/// 登录页路径。守卫与侧栏都引用它，避免字符串散落。
const String loginPath = '/login';

/// 路由表。
///
/// 约定：路径使用 kebab-case；需要深链的页面（推送跳转）必须在此注册。
/// 守卫只做一件事：未登录一律去登录页，已登录不再停留在登录页。
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final AuthState? auth = ref.read(authControllerProvider).value;
      final bool loggedIn = auth is AuthAuthenticated;
      final bool atLogin = state.matchedLocation == loginPath;
      if (!loggedIn) {
        return atLogin ? null : loginPath;
      }
      return atLogin ? '/' : null;
    },
    routes: <RouteBase>[
      GoRoute(path: loginPath, name: 'login', builder: (_, _) => const LoginPage()),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (_, _) => const HomeShell(),
        routes: <RouteBase>[
          GoRoute(
            path: 'deck/:id',
            name: 'deck-detail',
            builder: (_, GoRouterState state) =>
                PlaceholderScreen(title: state.pathParameters['id']),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (_, _) => const PlaceholderScreen(title: AppStrings.settings),
          ),
        ],
      ),
    ],
  );

  // 登录态变化时刷新路由，否则守卫不会重算（登录成功后仍会停在登录页）。
  ref.listen<AsyncValue<AuthState>>(authControllerProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});
