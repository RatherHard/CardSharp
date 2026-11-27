import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../application/decks_controller.dart';
import '../application/deck_list_state.dart';
import '../domain/deck.dart';
import '../domain/deck_import.dart';
import '../domain/deck_repository.dart';
import '../domain/sample_deck.dart';
import '../../search/application/search_controller.dart';
import '../../search/application/search_query.dart';
import '../../search/domain/search_results.dart';
import '../../search/presentation/search_results_view.dart';
import 'widgets/deck_cover.dart';
import '../../../core/di/service_providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/network/api_error.dart';

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
    } on DeckException catch (error) {
      // 数据层只给失败原因，文案在这里翻译（`AppStrings`）。
      _showError(switch (error.failure) {
        DeckFailure.titleRequired => AppStrings.deckTitleRequired,
        DeckFailure.notFound => AppStrings.shelfCreateFailed,
      });
    } on ApiError catch (error) {
      // 后端已给出可展示的说明，直接用，不再套「请重试」。
      _showError(error.message ?? AppStrings.unknownError);
    } on Object {
      _showError(AppStrings.shelfCreateFailed);
    }
  }

  /// 「+」先弹菜单：导入卡片集 / 导入示例卡片集 / 新建卡片集。
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
            // 内置示例：没有后端、手机里也没有现成 json 时的演示入口。
            ListTile(
              key: const ValueKey<String>('shelf_menu_import_sample'),
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text(AppStrings.shelfAddMenuImportSample),
              onTap: () => Navigator.of(context).pop(_AddAction.importSampleDeck),
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
    switch (action) {
      case _AddAction.createDeck:
        await _openCreateDialog();
      case _AddAction.importDeck:
        await _pickAndImportDeck();
      case _AddAction.importSampleDeck:
        await _importSampleDeck();
    }
  }

  /// 用户自选文件 → 解析 → 写入。取消选择时静默返回。
  Future<void> _pickAndImportDeck() async {
    final String? text = await ref.read(importFilePickerProvider).pickJsonText();
    if (text == null || !mounted) {
      return;
    }
    await _applyImport(text);
  }

  /// 应用内置示例 → 解析 → 写入。与自选文件共用 `_applyImport`，避免两条导入路径分叉。
  ///
  /// 有多个内置示例时先让用户选一个（`SampleDeck`），再走同一条导入链路。
  Future<void> _importSampleDeck() async {
    final SampleDeck? sample = await showModalBottomSheet<SampleDeck>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
              child: Text(
                AppStrings.shelfSamplePickerTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              key: const ValueKey<String>('shelf_sample_naiwa'),
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(AppStrings.sampleDeckTitle),
              subtitle: const Text(AppStrings.shelfSampleNaiwaHint),
              onTap: () => Navigator.of(context).pop(SampleDeck.naiwaFamily),
            ),
            ListTile(
              key: const ValueKey<String>('shelf_sample_mini_world'),
              leading: const Icon(Icons.extension_outlined),
              title: const Text(AppStrings.sampleDeckMiniWorldTitle),
              subtitle: const Text(AppStrings.shelfSampleMiniWorldHint),
              onTap: () => Navigator.of(context).pop(SampleDeck.miniWorld),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (sample == null || !mounted) {
      return;
    }
    try {
      final String text = await ref.read(bundledDeckLoaderProvider).loadSampleDeck(sample);
      if (!mounted) {
        return;
      }
      await _applyImport(text);
    } on Object {
      _showError(AppStrings.importFailed);
    }
  }

  /// 把一份卡片集 JSON 写入本地仓储，并给出反馈。
  Future<void> _applyImport(String text) async {
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
    } on ApiError catch (error) {
      _showError(error.message ?? AppStrings.unknownError);
    } on Object {
      _showError(AppStrings.importFailed);
    }
  }

  String _importErrorMessage(DeckImportError error) => switch (error) {
    DeckImportError.invalidJson => AppStrings.importErrorInvalidJson,
    DeckImportError.notAnObject => AppStrings.importErrorNotAnObject,
    DeckImportError.missingTitle => AppStrings.importErrorMissingTitle,
    DeckImportError.missingCards => AppStrings.importErrorMissingCards,
    DeckImportError.invalidDeck => AppStrings.importErrorInvalidDeck,
    DeckImportError.invalidCard => AppStrings.importErrorInvalidCard,
    DeckImportError.unsupportedCardType => AppStrings.importErrorUnsupportedCardType,
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
    } on DeckException catch (error) {
      _showError(switch (error.failure) {
        DeckFailure.notFound => AppStrings.deckNotFound(deck.id),
        DeckFailure.titleRequired => AppStrings.shelfDeleteFailed,
      });
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
    final AsyncValue<DeckListState> decksAsync = ref.watch(decksControllerProvider);
    final SearchQuery query = ref.watch(searchQueryProvider);
    return Column(
      children: <Widget>[
        _ShelfTopBar(
          searchController: _searchController,
          hasKeyword: query.isActive,
          onOpenDrawer: widget.onOpenDrawer ?? () => Scaffold.of(context).openDrawer(),
          onKeywordChanged: (String value) =>
              ref.read(searchQueryProvider.notifier).setKeyword(value),
          onClearKeyword: () {
            _searchController.clear();
            ref.read(searchQueryProvider.notifier).clear();
          },
          onCreate: _openAddMenu,
        ),
        Expanded(
          child: query.isActive
              ? _buildSearchBody(context)
              : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
                      ref.read(decksControllerProvider.notifier).loadMore();
                    }
                    return false;
                  },
                  child: switch (decksAsync) {
                    AsyncData<DeckListState>(:final DeckListState value) => _buildGrid(
                      context,
                      value,
                    ),
                    AsyncError<DeckListState>() => _ErrorState(
                      onRetry: () => ref.invalidate(decksControllerProvider),
                    ),
                    _ => const Center(child: CircularProgressIndicator()),
                  },
                ),
        ),
      ],
    );
  }

  /// 搜索态：一次全量搜索，结果按层级分档（同级卡片集在上、下级卡片在下）。
  Widget _buildSearchBody(BuildContext context) {
    return ref
        .watch(shelfSearchResultsProvider)
        .when(
          data: (ShelfSearchResults results) => ShelfSearchResultView(
            results: results,
            onOpenDeck: (String deckId) => context.push('/deck/$deckId'),
            onOpenCard: (String deckId, String cardId) =>
                context.push('/deck/$deckId/card/$cardId'),
            onShowMore: () => ref.read(searchQueryProvider.notifier).showMore(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text(AppStrings.deckDetailLoadFailed)),
        );
  }

  Widget _buildGrid(BuildContext context, DeckListState state) {
    final List<Deck> decks = state.decks;

    if (decks.isEmpty) {
      return const _EmptyState(
        key: ValueKey<String>('shelf_no_data'),
        title: AppStrings.shelfEmptyTitle,
        subtitle: AppStrings.shelfEmptySubtitle,
      );
    }

    return Stack(
      children: <Widget>[
        GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: _tileAspectRatio,
          ),
          itemCount: decks.length,
          itemBuilder: (BuildContext context, int index) {
            final Deck deck = decks[index];
            return DeckTile(
              deckId: deck.id,
              title: deck.title,
              cardCount: deck.cardCount,
              color: deck.color,
              onTap: () => context.push('/deck/${deck.id}'),
              onLongPress: () => _confirmDelete(deck),
            );
          },
        ),
        if (state.loadingMore)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LinearProgressIndicator(
              key: ValueKey<String>('shelf_loading_more'),
              minHeight: 2,
            ),
          ),
      ],
    );
  }
}

class _ShelfTopBar extends StatelessWidget {
  const _ShelfTopBar({
    required this.searchController,
    required this.hasKeyword,
    required this.onOpenDrawer,
    required this.onKeywordChanged,
    required this.onClearKeyword,
    required this.onCreate,
  });

  final TextEditingController searchController;
  final bool hasKeyword;
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
          // 搜索框整体是一个圆角容器：放大镜 → 输入区。
          // 搜索是一次全量搜索、按层级分档展示，所以没有模式下拉。
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 12),
                  Icon(Icons.search, size: 20, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      key: const ValueKey<String>('shelf_search_field'),
                      controller: searchController,
                      onChanged: onKeywordChanged,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: AppStrings.searchHint,
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (hasKeyword)
                    IconButton(
                      key: const ValueKey<String>('shelf_search_clear'),
                      tooltip: AppStrings.actionClear,
                      onPressed: onClearKeyword,
                      icon: const Icon(Icons.close, size: 18),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
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

enum _AddAction { importDeck, importSampleDeck, createDeck }

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
