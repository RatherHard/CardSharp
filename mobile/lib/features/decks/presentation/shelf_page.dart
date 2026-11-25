import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../application/decks_controller.dart';
import '../application/import_file_picker.dart';
import '../domain/deck.dart';
import '../domain/deck_import.dart';
import 'widgets/deck_cover.dart';
import '../../../core/l10n/app_strings.dart';

/// 书架首页：卡片集网格 + 搜索 + 新建入口。
///
/// 交互约定（人类已确认）：
/// - 每行固定 3 个卡片集；
/// - 点卡片集进入卡片集详情页；
/// - 长按卡片集二次确认后删除；
/// - 未完成的功能一律进纯白占位页，不做假数据。
class ShelfPage extends ConsumerStatefulWidget {
  const ShelfPage({this.onOpenDrawer, super.key});

  /// 打开侧栏的回调。外部注入时优先使用；为 null 时退回 `Scaffold.of`，
  /// 这样在 shell 路由里由路由直接构建（拿不到外层回调）时也能打开侧栏。
  final VoidCallback? onOpenDrawer;

  @override
  ConsumerState<ShelfPage> createState() => _ShelfPageState();
}

class _ShelfPageState extends ConsumerState<ShelfPage> {
  static const int _columns = 3;
  static const double _tileAspectRatio = 0.72;

  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreateDialog() async {
    final String? title = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => const _CreateDeckDialog(),
    );
    if (title == null || !mounted) {
      return;
    }
    try {
      await ref.read(decksControllerProvider.notifier).create(title);
    } on Object {
      _showError(AppStrings.shelfCreateFailed);
    }
  }

  /// 「+」先弹菜单：导入卡片集 / 新建卡片集。
  ///
  /// 菜单而不是直接新建，是因为导入与新建是两种入口，混在一个按钮里会让人以为
  /// 「+」只能新建。
  Future<void> _openAddMenu() async {
    final _AddAction? action = await showModalBottomSheet<_AddAction>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              key: const ValueKey<String>('shelf_menu_import'),
              leading: const Icon(Icons.file_open_outlined),
              title: const Text(AppStrings.shelfAddMenuImport),
              onTap: () => Navigator.of(context).pop(_AddAction.importDeck),
            ),
            ListTile(
              key: const ValueKey<String>('shelf_menu_create'),
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text(AppStrings.shelfAddMenuCreate),
              onTap: () => Navigator.of(context).pop(_AddAction.createDeck),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) {
      return;
    }
    if (action == _AddAction.createDeck) {
      await _openCreateDialog();
    } else {
      await _importDeck();
    }
  }

  /// 选文件 → 解析 → 写入。取消选择时静默返回。
  Future<void> _importDeck() async {
    final String? text = await ref.read(importFilePickerProvider).pickJsonText();
    if (text == null || !mounted) {
      return;
    }
    try {
      final DeckImport data = parseDeckImport(text);
      final Deck deck = await ref.read(decksControllerProvider.notifier).importDeck(data);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppStrings.importSucceeded(deck.title))));
    } on DeckImportException catch (error) {
      _showError(_importErrorMessage(error.error));
    } on Object {
      _showError(AppStrings.importFailed);
    }
  }

  String _importErrorMessage(DeckImportError error) => switch (error) {
    DeckImportError.invalidJson => AppStrings.importErrorInvalidJson,
    DeckImportError.notAnObject => AppStrings.importErrorNotAnObject,
    DeckImportError.missingTitle => AppStrings.importErrorMissingTitle,
    DeckImportError.missingCards => AppStrings.importErrorMissingCards,
    DeckImportError.invalidCard => AppStrings.importErrorInvalidCard,
  };

  Future<void> _confirmDelete(Deck deck) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(AppStrings.deleteDeckTitle),
        content: Text(AppStrings.deleteDeckConfirm(deck.title)),
        actions: <Widget>[
          TextButton(
            key: const ValueKey<String>('delete_deck_cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.actionCancel),
          ),
          FilledButton(
            key: const ValueKey<String>('delete_deck_confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      await ref.read(decksControllerProvider.notifier).delete(deck.id);
    } on Object {
      _showError(AppStrings.shelfDeleteFailed);
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Deck>> decksAsync = ref.watch(decksControllerProvider);
    return Column(
      children: <Widget>[
        _ShelfTopBar(
          searchController: _searchController,
          onOpenDrawer: widget.onOpenDrawer ?? () => Scaffold.of(context).openDrawer(),
          onKeywordChanged: (String value) => setState(() => _keyword = value),
          onClearKeyword: () {
            _searchController.clear();
            setState(() => _keyword = '');
          },
          onCreate: _openAddMenu,
        ),
        Expanded(
          child: switch (decksAsync) {
            AsyncData<List<Deck>>(:final List<Deck> value) => _buildGrid(context, value),
            AsyncError<List<Deck>>() => _ErrorState(
              onRetry: () => ref.invalidate(decksControllerProvider),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, List<Deck> decks) {
    final String keyword = _keyword.trim().toLowerCase();
    final List<Deck> visible = keyword.isEmpty
        ? decks
        : decks
              .where(
                (Deck deck) =>
                    deck.title.toLowerCase().contains(keyword) ||
                    deck.description.toLowerCase().contains(keyword),
              )
              .toList();

    if (decks.isEmpty) {
      return const _EmptyState(
        key: ValueKey<String>('shelf_no_data'),
        title: AppStrings.shelfEmptyTitle,
        subtitle: AppStrings.shelfEmptySubtitle,
      );
    }
    if (visible.isEmpty) {
      return const _EmptyState(
        key: ValueKey<String>('shelf_empty_state'),
        title: AppStrings.shelfNoMatchTitle,
        subtitle: AppStrings.shelfNoMatchSubtitle,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: _tileAspectRatio,
      ),
      itemCount: visible.length,
      itemBuilder: (BuildContext context, int index) {
        final Deck deck = visible[index];
        return DeckTile(
          deckId: deck.id,
          title: deck.title,
          cardCount: deck.cardCount,
          onTap: () => context.push('/deck/${deck.id}'),
          onLongPress: () => _confirmDelete(deck),
        );
      },
    );
  }
}

class _ShelfTopBar extends StatelessWidget {
  const _ShelfTopBar({
    required this.searchController,
    required this.onOpenDrawer,
    required this.onKeywordChanged,
    required this.onClearKeyword,
    required this.onCreate,
  });

  final TextEditingController searchController;
  final VoidCallback onOpenDrawer;
  final ValueChanged<String> onKeywordChanged;
  final VoidCallback onClearKeyword;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: <Widget>[
          IconButton(
            key: const ValueKey<String>('shelf_menu_button'),
            tooltip: AppStrings.shelfMenuTooltip,
            onPressed: onOpenDrawer,
            icon: const Icon(Icons.menu),
          ),
          Expanded(
            child: TextField(
              key: const ValueKey<String>('shelf_search_field'),
              controller: searchController,
              onChanged: onKeywordChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: AppStrings.shelfSearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (searchController.text.isNotEmpty)
            IconButton(
              tooltip: AppStrings.actionClear,
              onPressed: onClearKeyword,
              icon: const Icon(Icons.close),
            ),
          IconButton(
            key: const ValueKey<String>('shelf_create_button'),
            tooltip: AppStrings.shelfCreateTooltip,
            onPressed: onCreate,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

/// 「+」菜单的两个动作。
enum _AddAction { importDeck, createDeck }

class _CreateDeckDialog extends StatefulWidget {
  const _CreateDeckDialog();

  @override
  State<_CreateDeckDialog> createState() => _CreateDeckDialogState();
}

class _CreateDeckDialogState extends State<_CreateDeckDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.shelfCreateTooltip),
      content: TextField(
        key: const ValueKey<String>('create_deck_field'),
        controller: _controller,
        autofocus: true,
        maxLength: 30,
        decoration: const InputDecoration(
          labelText: AppStrings.createDeckFieldLabel,
          hintText: AppStrings.createDeckFieldHint,
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (String value) {
          if (_canSubmit) {
            Navigator.of(context).pop(value.trim());
          }
        },
      ),
      actions: <Widget>[
        TextButton(
          key: const ValueKey<String>('create_deck_cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.actionCancel),
        ),
        FilledButton(
          key: const ValueKey<String>('create_deck_confirm'),
          onPressed: _canSubmit ? () => Navigator.of(context).pop(_controller.text.trim()) : null,
          child: const Text(AppStrings.actionCreate),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.search_off, size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      key: const ValueKey<String>('shelf_error_state'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          const Text(AppStrings.shelfLoadErrorTitle),
          const SizedBox(height: 12),
          FilledButton.tonal(
            key: const ValueKey<String>('shelf_retry_button'),
            onPressed: onRetry,
            child: const Text(AppStrings.actionRetry),
          ),
        ],
      ),
    );
  }
}
