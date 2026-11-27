import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/app_strings.dart';
import '../../cards/domain/trashed_card.dart';
import '../../decks/domain/trashed_deck.dart';
import '../application/trash_providers.dart';
import 'trash_body.dart';

/// 回收站首页：按天倒序分组，同一天里先列卡片集、再列卡片。
///
/// 布局规则来自 grill 决策（见 `docs/decisions-trash.md`）：
/// - 卡片集显示封面 + 名字 + 卡片数，点进去还能单独恢复里面的卡片；
/// - 卡片只显示名字 + 来源卡片集，方便用户判断这是哪张；
/// - 右上角「选择」进入多选：可以逐条勾，也可以「全选」后一次永久删除
///   （永久删除是物理删除，不可恢复，确认框里写明）。
///
/// 正文与各行的渲染在 `trash_body.dart`（本文件只负责页面骨架与多选状态）。
class TrashPage extends ConsumerStatefulWidget {
  const TrashPage({super.key});

  @override
  ConsumerState<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends ConsumerState<TrashPage> {
  bool _selecting = false;
  final Set<String> _selectedDeckIds = <String>{};
  final Set<String> _selectedCardIds = <String>{};

  int get _selectedCount => _selectedDeckIds.length + _selectedCardIds.length;

  void _enterSelecting() => setState(() => _selecting = true);

  void _exitSelecting() => setState(() {
    _selecting = false;
    _selectedDeckIds.clear();
    _selectedCardIds.clear();
  });

  void _toggleDeck(String deckId) => setState(() {
    if (!_selectedDeckIds.remove(deckId)) {
      _selectedDeckIds.add(deckId);
    }
  });

  void _toggleCard(String cardId) => setState(() {
    if (!_selectedCardIds.remove(cardId)) {
      _selectedCardIds.add(cardId);
    }
  });

  void _selectAll(List<TrashedDeck> decks, List<TrashedCard> cards) => setState(() {
    _selectedDeckIds.addAll(decks.map((TrashedDeck item) => item.deck.id));
    _selectedCardIds.addAll(cards.map((TrashedCard item) => item.card.id));
  });

  Future<void> _purgeSelected() async {
    final int count = _selectedCount;
    if (count == 0) {
      return;
    }
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text(AppStrings.trashPurgeTitle),
        content: Text(AppStrings.trashPurgeConfirm(count)),
        actions: <Widget>[
          TextButton(
            key: const ValueKey<String>('trash_purge_cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.multiSelectCancel),
          ),
          FilledButton(
            key: const ValueKey<String>('trash_purge_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.trashPurge),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      final TrashActions actions = ref.read(trashActionsProvider);
      if (_selectedDeckIds.isNotEmpty) {
        await actions.purgeDecks(_selectedDeckIds.toList());
      }
      if (_selectedCardIds.isNotEmpty) {
        await actions.purgeCards(_selectedCardIds.toList());
      }
      if (!mounted) {
        return;
      }
      _exitSelecting();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          key: ValueKey<String>('trash_purged_toast'),
          content: Text(AppStrings.trashPurgeDone),
        ),
      );
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          key: ValueKey<String>('trash_purge_failed_toast'),
          content: Text(AppStrings.trashPurgeFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<TrashedDeck>> decksAsync = ref.watch(trashedDecksProvider);
    final AsyncValue<List<TrashedCard>> cardsAsync = ref.watch(standaloneTrashedCardsProvider);
    final List<TrashedDeck> decks = decksAsync.value ?? const <TrashedDeck>[];
    final List<TrashedCard> cards = cardsAsync.value ?? const <TrashedCard>[];
    final bool hasItems = decks.isNotEmpty || cards.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        key: const ValueKey<String>('trash_app_bar'),
        title: Text(
          _selecting ? AppStrings.multiSelectSelected(_selectedCount) : AppStrings.trashTitle,
        ),
        leading: _selecting
            ? IconButton(
                key: const ValueKey<String>('trash_select_cancel'),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: const Icon(Icons.close),
                onPressed: _exitSelecting,
              )
            : IconButton(
                key: const ValueKey<String>('trash_back'),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
        actions: <Widget>[
          if (_selecting)
            TextButton(
              key: const ValueKey<String>('trash_select_all'),
              onPressed: () => _selectAll(decks, cards),
              child: const Text(AppStrings.multiSelectSelectAll),
            )
          else if (hasItems)
            TextButton(
              key: const ValueKey<String>('trash_select_enter'),
              onPressed: _enterSelecting,
              child: const Text(AppStrings.trashSelect),
            ),
        ],
      ),
      body: switch ((decksAsync, cardsAsync)) {
        (AsyncValue<List<TrashedDeck>>(hasError: true), _) ||
        (_, AsyncValue<List<TrashedCard>>(hasError: true)) => TrashMessage(
          message: AppStrings.trashLoadFailed,
          onRetry: () {
            ref.invalidate(trashedDecksProvider);
            ref.invalidate(standaloneTrashedCardsProvider);
          },
        ),
        (
          AsyncValue<List<TrashedDeck>>(hasValue: true),
          AsyncValue<List<TrashedCard>>(hasValue: true),
        ) =>
          TrashBody(
            decks: decks,
            cards: cards,
            selecting: _selecting,
            selectedDeckIds: _selectedDeckIds,
            selectedCardIds: _selectedCardIds,
            onToggleDeck: _toggleDeck,
            onToggleCard: _toggleCard,
          ),
        _ => const Center(child: CircularProgressIndicator(key: ValueKey<String>('trash_loading'))),
      },
      bottomNavigationBar: _selecting
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(AppStrings.multiSelectSelected(_selectedCount))),
                  FilledButton(
                    key: const ValueKey<String>('trash_purge_selected'),
                    onPressed: _selectedCount == 0 ? null : _purgeSelected,
                    child: const Text(AppStrings.trashPurge),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
