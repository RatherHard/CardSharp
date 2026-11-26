import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/cards/presentation/card_page.dart';
import '../../features/decks/presentation/deck_detail_page.dart';
import '../../features/decks/presentation/shelf_page.dart';
import '../../features/review/presentation/review_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/shell/presentation/home_shell.dart';
import '../../features/shell/presentation/placeholder_screen.dart';

/// 登录页路径。守卫与侧栏都引用它，避免字符串散落。
const String kLoginPath = '/login';

/// 助手 / 社区两个占位 Tab 的路径。三个 Tab 各自需要一条根路径。
const String kAssistantPath = '/assistant';
const String kCommunityPath = '/community';

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
      final bool atLogin = state.matchedLocation == kLoginPath;
      if (!loggedIn) {
        return atLogin ? null : kLoginPath;
      }
      return atLogin ? '/' : null;
    },
    routes: <RouteBase>[
      GoRoute(path: kLoginPath, name: 'login', builder: (_, _) => const LoginPage()),
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
                      // 点卡片进浏览页：只看配图/名字/定义/Tips，不显示问题。
                      GoRoute(
                        path: 'card/:cardId',
                        name: 'card-detail',
                        builder: (_, GoRouterState state) => CardPage(
                          deckId: state.pathParameters['id']!,
                          cardId: state.pathParameters['cardId']!,
                        ),
                      ),
                      // 运行按钮进入复习：进度条 + 问答翻面（E4 的第一版）。
                      GoRoute(
                        path: 'review',
                        name: 'review',
                        builder: (_, GoRouterState state) =>
                            ReviewPage(deckId: state.pathParameters['id']!),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'settings',
                    name: 'settings',
                    builder: (_, _) => const SettingsPage(),
                  ),
                ],
              ),
            ],
          ),
          // Tab 2 / 3：暂为空白占位，但同样保留独立导航栈。
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: kAssistantPath,
                name: 'assistant',
                builder: (_, _) => const PlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: kCommunityPath,
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
