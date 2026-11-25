import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'app_drawer.dart';
import '../../../core/l10n/app_strings.dart';

/// 主框架：底部三 Tab + 侧栏。
///
/// Tab 切换交给 [StatefulNavigationShell]：它持有三条独立 Navigator，
/// 所以进入二级页面（卡片集详情）时底部栏仍在，切走再回来也不丢状态。
class HomeShell extends StatelessWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(bottom: false, child: navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) => navigationShell.goBranch(
          index,
          // 再次点击当前 Tab 时回到该分支的根页面。
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.style_outlined), label: AppStrings.tabDecks),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            label: AppStrings.tabAssistant,
          ),
          NavigationDestination(icon: Icon(Icons.forum_outlined), label: AppStrings.tabCommunity),
        ],
      ),
    );
  }
}
