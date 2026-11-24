import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../decks/presentation/shelf_page.dart';
import 'app_drawer.dart';
import 'placeholder_screen.dart';
import '../../../core/l10n/app_strings.dart';

/// 主框架：底部三 Tab（卡片 / 助手 / 社区）+ 侧栏。
///
/// Tab 数量与顺序以设计稿 `docs/卡片页面.png` 为准（人类 2026-11-24 确认三 Tab）。
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            ShelfPage(onOpenDrawer: _openDrawer),
            const PlaceholderScreen(),
            const PlaceholderScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
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
