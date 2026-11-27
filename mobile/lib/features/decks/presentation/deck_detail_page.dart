import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// 与 Flutter 自带的 Card 组件同名，本文件以业务模型为准，隐藏组件版本。
import 'package:material_ui/material_ui.dart' hide Card;

import '../../../core/di/service_providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/network/api_error.dart';
import '../../cards/application/cards_controller.dart';
import '../../cards/domain/card.dart';
import '../../search/application/search_controller.dart';
import '../../search/domain/search_limits.dart';
import '../../search/domain/search_results.dart';
import '../../search/presentation/search_results_view.dart';
import '../application/deck_cover_providers.dart';
import '../application/decks_controller.dart';
import '../application/deck_list_state.dart';
import '../domain/deck.dart';
import '../domain/deck_repository.dart';
import 'deck_failure_message.dart';
import 'widgets/deck_cover.dart';
import 'widgets/demo_deck_covers.dart';

/// 封面可选的预设色。后端 `decks.color` 是 `varchar(9)`，这里只用 `#RRGGBB`。
const List<String> _coverPalette = <String>[
  '#5B5BD6',
  '#0EA5E9',
  '#10B981',
  '#F59E0B',
  '#EF4444',
  '#8B5CF6',
  '#EC4899',
  '#64748B',
];

/// 卡片集详情页（设计稿第二屏）。
///
/// 本期能力：
/// - 展示封面 / 名称 / 简介 / 运行按钮 / 卡片列表；
/// - 长按名称、简介、封面可修改（单击时给一次缩放 + 提示，作为「这里能改」的引导）；
/// - 卡片长按 → 编辑 / 删除；
/// - 右上角「导入封面」→ 选本地图片当封面（与长按封面的「选择本地图片」是同一动作）；
/// - 右上角「多选」→ 勾选后批量删除。
///
/// 底部导航栏由外层 shell 提供，本页只管内容区。
class DeckDetailPage extends ConsumerStatefulWidget {
  const DeckDetailPage({required this.deckId, super.key});

  final String deckId;

  @override
  ConsumerState<DeckDetailPage> createState() => _DeckDetailPageState();
}

class _DeckDetailPageState extends ConsumerState<DeckDetailPage> {
  /// 每次「更多搜索结果」增加的条数。
  static const int _searchPageSize = kSearchHitLimit;

  bool _selecting = false;
  final Set<String> _selected = <String>{};

  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  int _searchLimit = _searchPageSize;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _exitSelection() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
  }

  void _toggleSelect(String cardId) {
    setState(() {
      if (!_selected.remove(cardId)) {
        _selected.add(cardId);
      }
    });
  }

  void _toggleSelectAll(List<Card> cards) {
    setState(() {
      if (_selected.length == cards.length) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..addAll(cards.map((Card card) => card.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<DeckListState> decksAsync = ref.watch(decksControllerProvider);
    final List<Deck>? decks = switch (decksAsync) {
      AsyncData<DeckListState>(:final DeckListState value) => value.decks,
      _ => null,
    };
    final Deck? deck = _findDeck(decks);

    final AsyncValue<List<Card>> cardsAsync = ref.watch(cardsForDeckProvider(widget.deckId));
    final List<Card> cards = switch (cardsAsync) {
      AsyncData<List<Card>>(:final List<Card> value) => value,
      _ => const <Card>[],
    };
    final bool searching = _searchKeyword.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        // 卡片集名称在下方头部已经完整显示，AppBar 不再重复；这一栏放搜索框。
        titleSpacing: 0,
        title: TextField(
          key: const ValueKey<String>('deck_search_field'),
          controller: _searchController,
          onChanged: (String value) => setState(() {
            _searchKeyword = value;
            _searchLimit = _searchPageSize;
          }),
          textInputAction: TextInputAction.search,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: AppStrings.searchDeckSearchHint,
            prefixIcon: const Icon(Icons.search, size: 20),
            isDense: true,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: _buildActions(deck, cards),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: searching
                  ? _buildSearchResults()
                  : switch (decksAsync) {
                      AsyncData<DeckListState>() when deck != null => _buildBody(
                        deck,
                        cardsAsync,
                        cards,
                      ),
                      AsyncData<DeckListState>() => const _CenteredHint(
                        AppStrings.deckDetailNotFound,
                      ),
                      AsyncError<DeckListState>() => const _CenteredHint(
                        AppStrings.deckDetailLoadFailed,
                      ),
                      _ => const Center(child: CircularProgressIndicator()),
                    },
            ),
            if (_selecting && !searching)
              _SelectionBar(
                count: _selected.length,
                onDelete: () => _confirmBatchDelete(deck, cards),
              ),
          ],
        ),
      ),
    );
  }

  /// 详情页搜索：一次搜全部——同级（本集卡片）在前，上级（本卡片集自己）在后。
  Widget _buildSearchResults() {
    final DeckSearchArgs args = (
      deckId: widget.deckId,
      keyword: _searchKeyword,
      hitLimit: _searchLimit,
    );
    return ref
        .watch(deckSearchResultsProvider(args))
        .when(
          data: (DeckSearchResults results) => DeckSearchResultView(
            results: results,
            onOpenCard: (String deckId, String cardId) =>
                context.push('/deck/$deckId/card/$cardId'),
            onOpenDeck: (String deckId) => context.push('/deck/$deckId'),
            onShowMore: () => setState(() => _searchLimit += _searchPageSize),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text(AppStrings.deckDetailLoadFailed)),
        );
  }

  List<Widget> _buildActions(Deck? deck, List<Card> cards) {
    if (deck == null) {
      return const <Widget>[];
    }
    if (_selecting) {
      return <Widget>[
        TextButton(
          key: const ValueKey<String>('multi_select_cancel'),
          onPressed: _exitSelection,
          child: const Text(AppStrings.multiSelectCancel),
        ),
        TextButton(
          key: const ValueKey<String>('multi_select_all'),
          onPressed: () => _toggleSelectAll(cards),
          child: const Text(AppStrings.multiSelectSelectAll),
        ),
      ];
    }
    return <Widget>[
      // 图片导入入口放在「多选」旁边。本期只导入封面：后端 `decks` 契约里没有封面图
      // 字段，图片先由 `FileDeckCoverService` 存在本机；接入后端时换成服务端上传即可，
      // 这一层只依赖 `DeckCoverService` 端口，页面不用改。
      TextButton(
        key: const ValueKey<String>('deck_cover_import'),
        onPressed: () => _pickCoverImage(deck),
        child: const Text(AppStrings.deckCoverImportAction),
      ),
      TextButton(
        key: const ValueKey<String>('multi_select_enter'),
        onPressed: cards.isEmpty
            ? null
            : () => setState(() {
                _selecting = true;
                _selected.clear();
              }),
        child: const Text(AppStrings.multiSelectEnter),
      ),
    ];
  }

  Widget _buildBody(Deck deck, AsyncValue<List<Card>> cardsAsync, List<Card> cards) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: <Widget>[
        _Header(
          deck: deck,
          onPatch: ({String? title, String? description, String? color}) =>
              _patchDeck(title: title, description: description, color: color),
          onPickCoverImage: () => _pickCoverImage(deck),
          onRemoveCoverImage: () => _removeCoverImage(deck),
          onPickColor: () => _pickDeckColor(deck),
        ),
        const SizedBox(height: 24),
        Text(AppStrings.deckDetailCardsTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        switch (cardsAsync) {
          AsyncData<List<Card>>() => _CardList(
            cards: cards,
            deckId: widget.deckId,
            selecting: _selecting,
            selected: _selected,
            onToggle: _toggleSelect,
            onLongPress: (Card card) => _openCardActions(deck, card),
            onTapCard: (Card card) => context.push('/deck/${widget.deckId}/card/${card.id}'),
          ),
          AsyncError<List<Card>>() => _ListError(deckId: widget.deckId),
          _ => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
        },
      ],
    );
  }

  Deck? _findDeck(List<Deck>? decks) {
    if (decks == null) {
      return null;
    }
    for (final Deck deck in decks) {
      if (deck.id == widget.deckId) {
        return deck;
      }
    }
    return null;
  }

  Future<void> _patchDeck({String? title, String? description, String? color}) async {
    try {
      await ref
          .read(decksControllerProvider.notifier)
          .updateDeck(widget.deckId, title: title, description: description, color: color);
    } on DeckException catch (error) {
      _showMessage(
        deckFailureMessage(error.failure, deckId: widget.deckId) ?? AppStrings.deckEditFailed,
      );
    } on ApiError catch (error) {
      _showMessage(error.message ?? AppStrings.unknownError);
    } on Object {
      _showMessage(AppStrings.deckEditFailed);
    }
  }

  void _showMessage(String text) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// 选一张本地图片作为该卡片集的封面。
  ///
  /// 用户取消（返回 null）时不提示、不改动原封面；成功后让封面路径重新读取。
  Future<void> _pickCoverImage(Deck deck) async {
    try {
      final String? saved = await ref.read(deckCoverServiceProvider).pickAndSaveCover(deck.id);
      if (saved == null) {
        return;
      }
      ref.invalidate(deckCoverPathProvider(deck.id));
    } on Object {
      _showMessage(AppStrings.deckCoverUpdateFailed);
    }
  }

  /// 移除自定义封面，回到默认白色卡堆。
  Future<void> _removeCoverImage(Deck deck) async {
    try {
      await ref.read(deckCoverServiceProvider).removeCover(deck.id);
      ref.invalidate(deckCoverPathProvider(deck.id));
    } on Object {
      _showMessage(AppStrings.deckCoverUpdateFailed);
    }
  }

  /// 选封面色（走后端契约里的 `color` 字段，与封面图互不影响）。
  Future<void> _pickDeckColor(Deck deck) async {
    final String? picked = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) => _ColorSheet(current: deck.color),
    );
    if (picked != null) {
      await _patchDeck(color: picked);
    }
  }

  /// 卡片长按：弹出「编辑 / 删除」。
  Future<void> _openCardActions(Deck deck, Card card) async {
    final _CardAction? action = await showModalBottomSheet<_CardAction>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              key: const ValueKey<String>('card_action_edit'),
              leading: const Icon(Icons.edit_outlined),
              title: const Text(AppStrings.actionEdit),
              onTap: () => Navigator.of(context).pop(_CardAction.edit),
            ),
            ListTile(
              key: const ValueKey<String>('card_action_delete'),
              leading: const Icon(Icons.delete_outline),
              title: const Text(AppStrings.actionDelete),
              onTap: () => Navigator.of(context).pop(_CardAction.delete),
            ),
          ],
        ),
      ),
    );
    if (action == _CardAction.edit) {
      await _editCard(deck, card);
    } else if (action == _CardAction.delete) {
      await _deleteCard(deck, card);
    }
  }

  Future<void> _editCard(Deck deck, Card card) async {
    final Card? edited = await showDialog<Card>(
      context: context,
      builder: (BuildContext context) => _CardEditDialog(card: card),
    );
    if (edited == null) {
      return;
    }
    try {
      await ref.read(cardActionsProvider).update(edited);
    } on ApiError catch (error) {
      _showMessage(error.message ?? AppStrings.unknownError);
    } on Object {
      _showMessage(AppStrings.cardUpdateFailed);
    }
  }

  Future<void> _deleteCard(Deck deck, Card card) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(AppStrings.cardDeleteTitle),
        content: const Text(AppStrings.cardDeleteConfirmText),
        actions: <Widget>[
          TextButton(
            key: const ValueKey<String>('card_delete_cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.actionCancel),
          ),
          FilledButton(
            key: const ValueKey<String>('card_delete_confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await ref.read(cardActionsProvider).delete(deck.id, card.id);
    } on ApiError catch (error) {
      _showMessage(error.message ?? AppStrings.unknownError);
    } on Object {
      _showMessage(AppStrings.cardDeleteFailed);
    }
  }

  Future<void> _confirmBatchDelete(Deck? deck, List<Card> cards) async {
    if (deck == null) {
      return;
    }
    if (_selected.isEmpty) {
      _showMessage(AppStrings.multiSelectEmpty);
      return;
    }
    final int count = _selected.length;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(AppStrings.multiSelectDeleteTitle),
        content: Text(AppStrings.multiSelectDeleteConfirm(count)),
        actions: <Widget>[
          TextButton(
            key: const ValueKey<String>('batch_delete_cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.actionCancel),
          ),
          FilledButton(
            key: const ValueKey<String>('batch_delete_confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await ref.read(cardActionsProvider).deleteMany(deck.id, _selected.toList());
      _exitSelection();
    } on ApiError catch (error) {
      _showMessage(error.message ?? AppStrings.unknownError);
    } on Object {
      _showMessage(AppStrings.cardDeleteFailed);
    }
  }
}

enum _CardAction { edit, delete }

/// 头部：封面 + 名称 + 简介 + 运行按钮。名称/简介/封面支持长按修改。
class _Header extends ConsumerWidget {
  const _Header({
    required this.deck,
    required this.onPatch,
    required this.onPickCoverImage,
    required this.onRemoveCoverImage,
    required this.onPickColor,
  });

  final Deck deck;

  /// 局部更新：只传要改的字段，对应后端 `PATCH /decks/{id}`。
  final void Function({String? title, String? description, String? color}) onPatch;

  /// 选本地图片当封面。
  final Future<void> Function() onPickCoverImage;

  /// 移除本地封面图。
  final Future<void> Function() onRemoveCoverImage;

  /// 选封面色（内部走 `PATCH` 的 color 字段）。
  final Future<void> Function() onPickColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final String? coverFilePath = ref.watch(deckCoverPathProvider(deck.id)).value;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _EditableTarget(
          hint: AppStrings.hintLongPressToEdit,
          onLongPress: () => _showCoverSheet(context, hasCustomCover: coverFilePath != null),
          child: SizedBox(
            width: 88,
            height: 88,
            child: DeckCover(
              tint: deckTint(deck.color),
              coverAsset: demoCoverFor(deck.title),
              coverFilePath: coverFilePath,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ExpandableInline(
                textKey: const ValueKey<String>('deck_detail_title'),
                fieldKey: const ValueKey<String>('deck_edit_name_field'),
                toggleKey: const ValueKey<String>('deck_title_toggle'),
                value: deck.title,
                style: theme.textTheme.titleLarge,
                collapsedLines: 1,
                allowEmpty: false,
                onCommit: (String value) => onPatch(title: value),
              ),
              // 简介为空时也渲染一行灰色占位，否则用户没有可长按的地方来新增简介。
              const SizedBox(height: 6),
              _ExpandableInline(
                textKey: const ValueKey<String>('deck_detail_description'),
                fieldKey: const ValueKey<String>('deck_edit_description_field'),
                toggleKey: const ValueKey<String>('deck_description_toggle'),
                value: deck.description,
                placeholder: AppStrings.deckAddDescriptionHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                collapsedLines: 2,
                allowEmpty: true,
                onCommit: (String value) => onPatch(description: value),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.deckCardCount(deck.cardCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.tonal(
          key: const ValueKey<String>('deck_run_button'),
          onPressed: () => context.push('/deck/${deck.id}/review'),
          child: const Text(AppStrings.deckDetailRun),
        ),
      ],
    );
  }

  /// 封面长按：一个入口收拢「换图 / 换颜色 / 移除图」。
  Future<void> _showCoverSheet(BuildContext context, {required bool hasCustomCover}) async {
    final _CoverAction? action = await showModalBottomSheet<_CoverAction>(
      context: context,
      builder: (BuildContext context) => _CoverSheet(hasCustomCover: hasCustomCover),
    );
    switch (action) {
      case _CoverAction.pickImage:
        await onPickCoverImage();
      case _CoverAction.pickColor:
        await onPickColor();
      case _CoverAction.removeImage:
        await onRemoveCoverImage();
      case null:
        break;
    }
  }
}

/// 封面长按菜单的三个动作。
enum _CoverAction { pickImage, pickColor, removeImage }

/// 封面长按弹出的菜单。
class _CoverSheet extends StatelessWidget {
  const _CoverSheet({required this.hasCustomCover});

  /// 已经有自定义封面图时才显示「移除封面图」。
  final bool hasCustomCover;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SafeArea(
      key: const ValueKey<String>('deck_cover_sheet'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(AppStrings.deckCoverSheetTitle, style: theme.textTheme.titleMedium),
            ),
          ),
          ListTile(
            key: const ValueKey<String>('deck_cover_pick_image'),
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text(AppStrings.deckCoverPickImage),
            onTap: () => Navigator.of(context).pop(_CoverAction.pickImage),
          ),
          ListTile(
            key: const ValueKey<String>('deck_cover_pick_color'),
            leading: const Icon(Icons.palette_outlined),
            title: const Text(AppStrings.deckCoverChangeColor),
            onTap: () => Navigator.of(context).pop(_CoverAction.pickColor),
          ),
          if (hasCustomCover)
            ListTile(
              key: const ValueKey<String>('deck_cover_remove_image'),
              leading: const Icon(Icons.hide_image_outlined),
              title: const Text(AppStrings.deckCoverRemoveImage),
              onTap: () => Navigator.of(context).pop(_CoverAction.removeImage),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// 单击时给一次「缩放 + 描边 + 提示」的引导动画，长按触发真正的修改。
class _EditableTarget extends StatefulWidget {
  const _EditableTarget({required this.child, required this.onLongPress, required this.hint});

  final Widget child;
  final VoidCallback onLongPress;
  final String hint;

  @override
  State<_EditableTarget> createState() => _EditableTargetState();
}

class _EditableTargetState extends State<_EditableTarget> {
  static const Duration _pulse = Duration(milliseconds: 220);
  static const Duration _hold = Duration(milliseconds: 1400);

  bool _hinting = false;

  Future<void> _showHint() async {
    if (_hinting) {
      return;
    }
    setState(() => _hinting = true);
    await Future<void>.delayed(_hold);
    if (mounted) {
      setState(() => _hinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _showHint,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _hinting ? 1.04 : 1,
        duration: _pulse,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: _pulse,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _hinting ? scheme.primary : Colors.transparent, width: 1.5),
          ),
          padding: const EdgeInsets.all(2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              widget.child,
              AnimatedSize(
                duration: _pulse,
                alignment: Alignment.topLeft,
                child: _hinting
                    ? Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          widget.hint,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.primary),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 原地编辑的文本：长按进入编辑，回车或点别处保存；单击仍给一次引导动画。
class _InlineEditable extends StatefulWidget {
  const _InlineEditable({
    required this.value,
    required this.textKey,
    required this.fieldKey,
    required this.style,
    required this.onCommit,
    required this.allowEmpty,
    this.placeholder,
    this.maxLines = 1,
  });

  final String value;
  final Key textKey;
  final Key fieldKey;
  final TextStyle? style;
  final ValueChanged<String> onCommit;
  final bool allowEmpty;

  /// 值为空时显示的灰色提示，同时作为输入框的 hintText。
  final String? placeholder;

  /// null 表示不限行数（长文本换行显示完整）。
  final int? maxLines;

  @override
  State<_InlineEditable> createState() => _InlineEditableState();
}

class _InlineEditableState extends State<_InlineEditable> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);
  late final FocusNode _focus = FocusNode();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    // 失焦即保存：点画面别处也算「改完了」，不用再找一个确认按钮。
    _focus.addListener(() {
      if (!_focus.hasFocus && _editing) {
        _commit();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _controller.text = widget.value;
      _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
      _focus.requestFocus();
    });
  }

  void _commit() {
    if (!_editing) {
      return;
    }
    final String next = _controller.text.trim();
    setState(() => _editing = false);
    // 名称不允许为空；简介允许清空。
    if (next.isEmpty && !widget.allowEmpty) {
      return;
    }
    if (next == widget.value) {
      return;
    }
    widget.onCommit(next);
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return TextField(
        key: widget.fieldKey,
        controller: _controller,
        focusNode: _focus,
        style: widget.style,
        maxLines: widget.maxLines,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: widget.placeholder,
        ),
        onSubmitted: (_) => _commit(),
        onTapOutside: (_) => _commit(),
      );
    }
    final bool showPlaceholder = widget.value.trim().isEmpty && widget.placeholder != null;
    return _EditableTarget(
      hint: AppStrings.hintLongPressToEdit,
      onLongPress: _startEditing,
      child: Text(
        showPlaceholder ? widget.placeholder! : widget.value,
        key: widget.textKey,
        maxLines: widget.maxLines,
        // 不限行数时不截断，长名称/长简介直接换行显示完整。
        overflow: widget.maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
        style: showPlaceholder
            ? widget.style?.copyWith(color: Theme.of(context).colorScheme.outline)
            : widget.style,
      ),
    );
  }
}

/// 默认折叠、末尾带展开箭头的原地编辑文本。
///
/// 折叠时只显示 [collapsedLines] 行，末尾出现「∨」；点击展开显示全文，箭头变「∧」，
/// 再点折叠。箭头只在文本确实超出时才出现，短文本不会多出一个无用控件。
class _ExpandableInline extends StatefulWidget {
  const _ExpandableInline({
    required this.value,
    required this.textKey,
    required this.fieldKey,
    required this.toggleKey,
    required this.style,
    required this.collapsedLines,
    required this.allowEmpty,
    required this.onCommit,
    this.placeholder,
  });

  final String value;
  final Key textKey;
  final Key fieldKey;
  final Key toggleKey;
  final TextStyle? style;
  final int collapsedLines;
  final bool allowEmpty;
  final ValueChanged<String> onCommit;
  final String? placeholder;

  @override
  State<_ExpandableInline> createState() => _ExpandableInlineState();
}

class _ExpandableInlineState extends State<_ExpandableInline> {
  /// 箭头占位宽度，测量文本可用宽度时要扣掉。
  static const double _toggleWidth = 28;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final String shown = widget.value.trim().isEmpty
            ? (widget.placeholder ?? '')
            : widget.value;
        final TextPainter painter = TextPainter(
          text: TextSpan(text: shown, style: widget.style),
          maxLines: widget.collapsedLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: (constraints.maxWidth - _toggleWidth).clamp(0, double.infinity));
        final bool overflows = painter.didExceedMaxLines;
        painter.dispose();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _InlineEditable(
                textKey: widget.textKey,
                fieldKey: widget.fieldKey,
                value: widget.value,
                placeholder: widget.placeholder,
                style: widget.style,
                maxLines: _expanded ? null : widget.collapsedLines,
                allowEmpty: widget.allowEmpty,
                onCommit: widget.onCommit,
              ),
            ),
            if (overflows || _expanded)
              InkWell(
                key: widget.toggleKey,
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.only(left: 2, top: 2),
                  child: Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CardList extends StatelessWidget {
  const _CardList({
    required this.cards,
    required this.deckId,
    required this.selecting,
    required this.selected,
    required this.onToggle,
    required this.onLongPress,
    required this.onTapCard,
  });

  final List<Card> cards;
  final String deckId;
  final bool selecting;
  final Set<String> selected;
  final void Function(String cardId) onToggle;
  final void Function(Card card) onLongPress;
  final void Function(Card card) onTapCard;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const _EmptyCards();
    }
    return Column(
      children: <Widget>[
        for (int i = 0; i < cards.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 10),
          _CardBar(
            key: ValueKey<String>('deck_card_bar_${cards[i].id}'),
            card: cards[i],
            index: i,
            selecting: selecting,
            selected: selected.contains(cards[i].id),
            onToggle: () => onToggle(cards[i].id),
            onLongPress: () => onLongPress(cards[i]),
            onTap: () => onTapCard(cards[i]),
          ),
        ],
      ],
    );
  }
}

/// 列表里的一张卡片：圆角长条，左侧序号（或多选框），右侧卡片名（明文）。
///
/// 列表**不展示暗文**，避免剧透答案；卡片正文留给卡片页（`/deck/:id/card`）。
class _CardBar extends StatelessWidget {
  const _CardBar({
    super.key,
    required this.card,
    required this.index,
    required this.selecting,
    required this.selected,
    required this.onToggle,
    required this.onLongPress,
    required this.onTap,
  });

  final Card card;
  final int index;
  final bool selecting;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        key: ValueKey<String>('deck_card_${card.id}'),
        onTap: selecting ? onToggle : onTap,
        onLongPress: selecting ? null : onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 56,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 40,
                  child: selecting
                      ? Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Checkbox(
                            key: ValueKey<String>('deck_card_checkbox_${card.id}'),
                            value: selected,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onChanged: (_) => onToggle(),
                          ),
                        )
                      : Text(
                          '${index + 1}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card.fields.plaintext,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 多选时固定在底部的操作条。
class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.count, required this.onDelete});

  final int count;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(AppStrings.multiSelectSelected(count))),
            FilledButton(
              key: const ValueKey<String>('multi_select_delete'),
              onPressed: count == 0 ? null : onDelete,
              child: Text(AppStrings.multiSelectDeleteCount(count)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCards extends StatelessWidget {
  const _EmptyCards();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      key: const ValueKey<String>('deck_detail_no_cards'),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: <Widget>[
          Icon(Icons.style_outlined, size: 40, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(AppStrings.deckDetailNoCards, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            AppStrings.deckDetailNoCardsHint,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ListError extends ConsumerWidget {
  const _ListError({required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: <Widget>[
          const Text(AppStrings.deckDetailLoadFailed),
          const SizedBox(height: 12),
          FilledButton.tonal(
            key: const ValueKey<String>('deck_cards_retry'),
            onPressed: () => ref.invalidate(cardsForDeckProvider(deckId)),
            child: const Text(AppStrings.actionRetry),
          ),
        ],
      ),
    );
  }
}

class _CenteredHint extends StatelessWidget {
  const _CenteredHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text));
  }
}

/// 封面颜色选择面板。
class _ColorSheet extends StatelessWidget {
  const _ColorSheet({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(AppStrings.deckEditColorTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                for (final String color in _coverPalette)
                  InkWell(
                    key: ValueKey<String>('color_option_$color'),
                    onTap: () => Navigator.of(context).pop(color),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: deckTint(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: current == color
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                InkWell(
                  key: const ValueKey<String>('color_option_default'),
                  onTap: () => Navigator.of(context).pop(''),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Text(
                      AppStrings.deckEditColorDefault,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 卡片编辑对话框：序号、明文、暗文、提示、备注。
class _CardEditDialog extends StatefulWidget {
  const _CardEditDialog({required this.card});

  final Card card;

  @override
  State<_CardEditDialog> createState() => _CardEditDialogState();
}

class _CardEditDialogState extends State<_CardEditDialog> {
  late final TextEditingController _plaintext = TextEditingController(
    text: widget.card.fields.plaintext,
  );
  late final TextEditingController _ciphertext = TextEditingController(
    text: widget.card.fields.ciphertext,
  );
  late final TextEditingController _hint = TextEditingController(
    text: widget.card.fields.hint ?? '',
  );
  late final TextEditingController _extra = TextEditingController(
    text: widget.card.fields.extra ?? '',
  );
  // 列表里展示的是「第几张」，从 1 开始；而 sortOrder 是内部排序值，从 0 开始。
  // 这里统一按 1 基显示给用户，保存时再减 1 存回，避免出现「序号 0」。
  late final TextEditingController _orderController = TextEditingController(
    text: (widget.card.sortOrder + 1).toString(),
  );
  late int _order = widget.card.sortOrder + 1;
  String? _error;

  @override
  void dispose() {
    _plaintext.dispose();
    _ciphertext.dispose();
    _hint.dispose();
    _extra.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _submit() {
    final String plaintext = _plaintext.text.trim();
    final String ciphertext = _ciphertext.text.trim();
    // 约束来自 `docs/03` §4.4：明文 ≤200、暗文 ≤500，且都不可为空。
    if (plaintext.isEmpty || ciphertext.isEmpty) {
      setState(() => _error = AppStrings.cardEditRequired);
      return;
    }
    if (plaintext.length > kPlaintextMaxLength || ciphertext.length > kCiphertextMaxLength) {
      setState(
        () => _error = AppStrings.cardEditTooLong(kPlaintextMaxLength, kCiphertextMaxLength),
      );
      return;
    }
    Navigator.of(context).pop(
      widget.card.copyWith(
        sortOrder: _order - 1,
        fields: widget.card.fields.copyWith(
          plaintext: plaintext,
          ciphertext: ciphertext,
          hint: _hint.text.trim().isEmpty ? null : _hint.text.trim(),
          extra: _extra.text.trim().isEmpty ? null : _extra.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.cardEditTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              key: const ValueKey<String>('card_edit_plaintext'),
              controller: _plaintext,
              maxLength: kPlaintextMaxLength,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(labelText: AppStrings.cardEditPlaintextLabel),
            ),
            TextField(
              key: const ValueKey<String>('card_edit_ciphertext'),
              controller: _ciphertext,
              maxLength: kCiphertextMaxLength,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(labelText: AppStrings.cardEditCiphertextLabel),
            ),
            TextField(
              key: const ValueKey<String>('card_edit_hint'),
              controller: _hint,
              decoration: const InputDecoration(labelText: AppStrings.cardEditHintLabel),
            ),
            TextField(
              key: const ValueKey<String>('card_edit_extra'),
              controller: _extra,
              decoration: const InputDecoration(labelText: AppStrings.cardEditExtraLabel),
            ),
            TextField(
              key: const ValueKey<String>('card_edit_order'),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: AppStrings.cardEditOrderLabel),
              controller: _orderController,
              onChanged: (String value) => _order = int.tryParse(value) ?? _order,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  key: const ValueKey<String>('card_edit_error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          key: const ValueKey<String>('card_edit_cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.actionCancel),
        ),
        FilledButton(
          key: const ValueKey<String>('card_edit_save'),
          onPressed: _submit,
          child: const Text(AppStrings.actionSave),
        ),
      ],
    );
  }
}
