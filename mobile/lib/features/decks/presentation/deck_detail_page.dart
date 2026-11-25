import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// 与 Flutter 自带的 Card 组件同名，本文件以业务模型为准，隐藏组件版本。
import 'package:material_ui/material_ui.dart' hide Card;

import '../../../core/l10n/app_strings.dart';
import '../../../core/network/api_error.dart';
import '../../cards/application/cards_controller.dart';
import '../../cards/domain/card.dart';
import '../application/decks_controller.dart';
import '../domain/deck.dart';
import 'widgets/deck_cover.dart';

/// 封面可选的预设色。后端 `decks.color` 是 `varchar(9)`，这里只用 `#RRGGBB`。
const List<String> _kCoverPalette = <String>[
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
  bool _selecting = false;
  final Set<String> _selected = <String>{};

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

    return Scaffold(
      appBar: AppBar(
        title: Text(deck?.title ?? AppStrings.deckDetailNotFound),
        actions: _buildActions(deck, cards),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: switch (decksAsync) {
                AsyncData<DeckListState>() when deck != null => _buildBody(deck, cardsAsync, cards),
                AsyncData<DeckListState>() => const _CenteredHint(AppStrings.deckDetailNotFound),
                AsyncError<DeckListState>() => const _CenteredHint(AppStrings.deckDetailLoadFailed),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
            if (_selecting)
              _SelectionBar(
                count: _selected.length,
                onDelete: () => _confirmBatchDelete(deck, cards),
              ),
          ],
        ),
      ),
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
        ),
        const SizedBox(height: 24),
        Text(AppStrings.deckDetailCardsTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const _ColumnHeader(),
        const Divider(height: 1),
        switch (cardsAsync) {
          AsyncData<List<Card>>() => _CardList(
            cards: cards,
            deckId: widget.deckId,
            selecting: _selecting,
            selected: _selected,
            onToggle: _toggleSelect,
            onLongPress: (Card card) => _openCardActions(deck, card),
            onTapCard: () => context.push('/deck/${widget.deckId}/card'),
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
    } on ApiError catch (error) {
      _showMessage(error.message);
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
      _showMessage(error.message);
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
      _showMessage(error.message);
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
      _showMessage(error.message);
    } on Object {
      _showMessage(AppStrings.cardDeleteFailed);
    }
  }
}

enum _CardAction { edit, delete }

/// 头部：封面 + 名称 + 简介 + 运行按钮。名称/简介/封面支持长按修改。
class _Header extends StatelessWidget {
  const _Header({required this.deck, required this.onPatch});

  final Deck deck;

  /// 局部更新：只传要改的字段，对应后端 `PATCH /decks/{id}`。
  final void Function({String? title, String? description, String? color}) onPatch;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _EditableTarget(
          hint: AppStrings.hintLongPressToEdit,
          onLongPress: () => _pickColor(context),
          child: SizedBox(
            width: 88,
            height: 88,
            child: DeckCover(tint: _parseHexColor(deck.color)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _InlineEditable(
                textKey: const ValueKey<String>('deck_detail_title'),
                fieldKey: const ValueKey<String>('deck_edit_name_field'),
                value: deck.title,
                style: theme.textTheme.titleLarge,
                maxLines: 1,
                allowEmpty: false,
                onCommit: (String value) => onPatch(title: value),
              ),
              // 简介为空时也渲染一行灰色占位，否则用户没有可长按的地方来新增简介。
              const SizedBox(height: 6),
              _InlineEditable(
                textKey: const ValueKey<String>('deck_detail_description'),
                fieldKey: const ValueKey<String>('deck_edit_description_field'),
                value: deck.description,
                placeholder: AppStrings.deckAddDescriptionHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
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
          onPressed: () => context.push('/deck/${deck.id}/card'),
          child: const Text(AppStrings.deckDetailRun),
        ),
      ],
    );
  }

  Future<void> _pickColor(BuildContext context) async {
    final String? picked = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) => _ColorSheet(current: deck.color),
    );
    if (picked != null) {
      onPatch(color: picked);
    }
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

  final int maxLines;

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
        overflow: TextOverflow.ellipsis,
        style: showPlaceholder
            ? widget.style?.copyWith(color: Theme.of(context).colorScheme.outline)
            : widget.style,
      ),
    );
  }
}

/// 列表表头：序号 / 卡片明文 / 暗文。
class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          SizedBox(width: 52, child: Text(AppStrings.deckDetailColumnIndex, style: style)),
          Expanded(child: Text(AppStrings.deckDetailColumnPlaintext, style: style)),
          SizedBox(
            width: 48,
            child: Text(
              AppStrings.deckDetailColumnCiphertext,
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
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
  final VoidCallback onTapCard;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const _EmptyCards();
    }
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        for (int i = 0; i < cards.length; i++) ...<Widget>[
          InkWell(
            key: ValueKey<String>('deck_card_${cards[i].id}'),
            onTap: selecting ? () => onToggle(cards[i].id) : onTapCard,
            onLongPress: selecting ? null : () => onLongPress(cards[i]),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 52,
                    child: selecting
                        ? Checkbox(
                            key: ValueKey<String>('deck_card_checkbox_${cards[i].id}'),
                            value: selected.contains(cards[i].id),
                            onChanged: (_) => onToggle(cards[i].id),
                          )
                        : Text('${i + 1}', style: theme.textTheme.bodyMedium),
                  ),
                  Expanded(
                    child: Text(
                      cards[i].fields.plaintext,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      AppStrings.deckCiphertextHidden,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
        ],
      ],
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
                for (final String color in _kCoverPalette)
                  InkWell(
                    key: ValueKey<String>('color_option_$color'),
                    onTap: () => Navigator.of(context).pop(color),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _parseHexColor(color),
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
    if (plaintext.length > 200 || ciphertext.length > 500) {
      setState(() => _error = AppStrings.cardEditTooLong);
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
              maxLength: 200,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(labelText: AppStrings.cardEditPlaintextLabel),
            ),
            TextField(
              key: const ValueKey<String>('card_edit_ciphertext'),
              controller: _ciphertext,
              maxLength: 500,
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

/// 把 `#RRGGBB` 或 `#AARRGGBB` 解析成 [Color]；空串或格式不合法时返回 null。
///
/// 后端 `decks.color` 是 `varchar(9)` 且允许空值，所以这里必须能安全地失败。
Color? _parseHexColor(String value) {
  final String hex = value.trim().replaceFirst('#', '');
  if (hex.length != 6 && hex.length != 8) {
    return null;
  }
  final int? parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) {
    return null;
  }
  return Color(hex.length == 6 ? 0xFF000000 | parsed : parsed);
}
