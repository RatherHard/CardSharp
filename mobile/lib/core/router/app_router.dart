import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/decks/presentation/deck_detail_page.dart';
import '../../features/decks/presentation/shelf_page.dart';
import '../../features/shell/presentation/home_shell.dart';
import '../../features/shell/presentation/placeholder_screen.dart';
import '../l10n/app_strings.dart';

/// 登录页路径。守卫与侧栏都引用它，避免字符串散落。
const String loginPath = '/login';

/// 助手 / 社区两个占位 Tab 的路径。三个 Tab 各自需要一条根路径。
const String assistantPath = '/assistant';
const String communityPath = '/community';

/// 路由表。
///
/// 三个 Tab 用 [StatefulShellRoute] 承载，每个 Tab 拥有独立的 Navigator：
/// - 进入卡片集详情页时底部导航栏仍然可见（设计稿第二屏要求）；
/// - 切到别的 Tab 再回来，仍停留在原页面，不丢状态。
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
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) => HomeShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          // Tab 1：卡片。书架首页 → 卡片集详情 →（将来）卡片页面，都在这条分支里。
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                name: 'home',
                builder: (_, _) => const ShelfPage(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'deck/:id',
                    name: 'deck-detail',
                    builder: (_, GoRouterState state) =>
                        DeckDetailPage(deckId: state.pathParameters['id']!),
                    routes: <RouteBase>[
                      // 运行按钮 / 点卡片都先跳空白占位页，真正的卡片页面属于 E4。
                      GoRoute(
                        path: 'card',
                        name: 'card-page',
                        builder: (_, _) => const PlaceholderScreen(title: AppStrings.cardPageTitle),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'settings',
                    name: 'settings',
                    builder: (_, _) => const PlaceholderScreen(title: AppStrings.settings),
                  ),
                ],
              ),
            ],
          ),
          // Tab 2 / 3：暂为空白占位，但同样保留独立导航栈。
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: assistantPath,
                name: 'assistant',
                builder: (_, _) => const PlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: communityPath,
                name: 'community',
                builder: (_, _) => const PlaceholderScreen(),
              ),
            ],
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
