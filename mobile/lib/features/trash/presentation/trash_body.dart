import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/app_strings.dart';
import '../../cards/domain/trashed_card.dart';
import '../../decks/application/deck_cover_providers.dart';
import '../../decks/domain/deck.dart';
import '../../decks/domain/trashed_deck.dart';
import '../../decks/presentation/widgets/deck_cover.dart';
import '../../decks/presentation/widgets/demo_deck_covers.dart';
import '../application/trash_providers.dart';
import 'trash_widgets.dart';

/// 回收站正文：按天倒序分组，同一天里先列卡片集、再列卡片。
class TrashBody extends StatelessWidget {
  const TrashBody({
    super.key,
    required this.decks,
    required this.cards,
    required this.selecting,
    required this.selectedDeckIds,
    required this.selectedCardIds,
    required this.onToggleDeck,
    required this.onToggleCard,
  });

  final List<TrashedDeck> decks;
  final List<TrashedCard> cards;
  final bool selecting;
  final Set<String> selectedDeckIds;
  final Set<String> selectedCardIds;
  final void Function(String deckId) onToggleDeck;
  final void Function(String cardId) onToggleCard;

  @override
  Widget build(BuildContext context) {
    if (decks.isEmpty && cards.isEmpty) {
      return const _TrashEmpty();
    }
    final List<_TrashDayGroup> groups = _groupByDay(decks, cards);
    final DateTime now = DateTime.now();
    final List<Widget> children = <Widget>[];
    for (final _TrashDayGroup group in groups) {
      children.add(_DayHeader(day: group.day, now: now));
      if (group.decks.isNotEmpty) {
        children.add(
          const _SectionLabel(
            labelKey: ValueKey<String>('trash_section_decks'),
            text: AppStrings.trashSectionDecks,
          ),
        );
        for (final TrashedDeck item in group.decks) {
          children.add(
            _TrashedDeckRow(
              item: item,
              selecting: selecting,
              selected: selectedDeckIds.contains(item.deck.id),
              onToggle: () => onToggleDeck(item.deck.id),
            ),
          );
        }
      }
      if (group.cards.isNotEmpty) {
        children.add(
          const _SectionLabel(
            labelKey: ValueKey<String>('trash_section_cards'),
            text: AppStrings.trashSectionCards,
          ),
        );
        for (final TrashedCard item in group.cards) {
          children.add(
            _TrashedCardRow(
              item: item,
              selecting: selecting,
              selected: selectedCardIds.contains(item.card.id),
              onToggle: () => onToggleCard(item.card.id),
            ),
          );
        }
      }
    }
    return ListView(
      key: const ValueKey<String>('trash_list'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: children,
    );
  }
}

/// 一天一组：同一天内的卡片集与卡片分区展示。
class _TrashDayGroup {
  const _TrashDayGroup({required this.day, required this.decks, required this.cards});

  final DateTime day;
  final List<TrashedDeck> decks;
  final List<TrashedCard> cards;
}

List<_TrashDayGroup> _groupByDay(List<TrashedDeck> decks, List<TrashedCard> cards) {
  DateTime dayOf(DateTime value) => DateTime(value.year, value.month, value.day);
  final Map<DateTime, _TrashDayGroup> groups = <DateTime, _TrashDayGroup>{};

  _TrashDayGroup groupOf(DateTime day) =>
      groups[day] ?? _TrashDayGroup(day: day, decks: <TrashedDeck>[], cards: <TrashedCard>[]);

  for (final TrashedDeck deck in decks) {
    final DateTime day = dayOf(deck.deletedAt);
    final _TrashDayGroup current = groupOf(day);
    groups[day] = _TrashDayGroup(
      day: day,
      decks: <TrashedDeck>[...current.decks, deck],
      cards: current.cards,
    );
  }
  for (final TrashedCard card in cards) {
    final DateTime day = dayOf(card.deletedAt);
    final _TrashDayGroup current = groupOf(day);
    groups[day] = _TrashDayGroup(
      day: day,
      decks: current.decks,
      cards: <TrashedCard>[...current.cards, card],
    );
  }

  final List<_TrashDayGroup> result = groups.values.toList()
    ..sort((_TrashDayGroup a, _TrashDayGroup b) => b.day.compareTo(a.day));
  return result;
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.now});

  final DateTime day;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        AppStrings.trashDayHeader(day, now),
        key: ValueKey<String>('trash_day_${day.year}_${day.month}_${day.day}'),
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.labelKey});

  final String text;
  final Key labelKey;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        text,
        key: labelKey,
        style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// 多选模式下每条前面的勾选框。
class _SelectBox extends StatelessWidget {
  const _SelectBox({required this.selected, required this.boxKey, required this.onTap});

  final bool selected;
  final Key boxKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      key: boxKey,
      value: selected,
      onChanged: (_) => onTap(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// 回收站里的一条卡片集：封面 + 名字 + 卡片数，点进详情可单张恢复。
///
/// 多选模式下点这一行是「勾选」，不再跳详情。
class _TrashedDeckRow extends ConsumerWidget {
  const _TrashedDeckRow({
    required this.item,
    required this.selecting,
    required this.selected,
    required this.onToggle,
  });

  final TrashedDeck item;
  final bool selecting;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final String deckId = item.deck.id;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: theme.colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey<String>('trash_deck_row_$deckId'),
        onTap: selecting ? onToggle : () => context.push('/trash/deck/$deckId'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 56,
                height: 56,
                child: DeckCover(
                  tint: deckTint(item.deck.color),
                  coverAsset: demoCoverFor(item.deck.title),
                  coverFilePath: ref.watch(deckCoverPathProvider(deckId)).value,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.deck.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.deckCardCount(item.deck.cardCount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (selecting)
                _SelectBox(
                  selected: selected,
                  boxKey: ValueKey<String>('trash_deck_check_$deckId'),
                  onTap: onToggle,
                )
              else
                TextButton(
                  key: ValueKey<String>('trash_restore_deck_$deckId'),
                  onPressed: () => restoreWholeDeck(context, ref, item),
                  child: const Text(AppStrings.trashRestore),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 回收站里的一条单独删除的卡片：名字 + 来源卡片集。
class _TrashedCardRow extends ConsumerWidget {
  const _TrashedCardRow({
    required this.item,
    required this.selecting,
    required this.selected,
    required this.onToggle,
  });

  final TrashedCard item;
  final bool selecting;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      key: ValueKey<String>('trash_card_row_${item.card.id}'),
      onTap: selecting ? onToggle : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.card.fields.plaintext,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.trashCardSource(item.sourceDeckTitle),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (selecting)
              _SelectBox(
                selected: selected,
                boxKey: ValueKey<String>('trash_card_check_${item.card.id}'),
                onTap: onToggle,
              )
            else
              TextButton(
                key: ValueKey<String>('trash_restore_card_${item.card.id}'),
                onPressed: () => restoreTrashedCard(context, ref, item),
                child: const Text(AppStrings.trashRestore),
              ),
          ],
        ),
      ),
    );
  }
}

/// 恢复整个卡片集（跟着它删的卡片一起回来）。
Future<void> restoreWholeDeck(BuildContext context, WidgetRef ref, TrashedDeck item) async {
  if (!await confirmRestoreDeck(context, item.deck.title) || !context.mounted) {
    return;
  }
  try {
    await ref.read(trashActionsProvider).restoreDeck(item.deck.id);
    if (!context.mounted) {
      return;
    }
    showRestoredToast(context);
  } on Object {
    if (!context.mounted) {
      return;
    }
    showRestoreFailedToast(context);
  }
}

/// 恢复一张「单独删除」的卡片：先选恢复到哪，再动手。
Future<void> restoreTrashedCard(BuildContext context, WidgetRef ref, TrashedCard item) async {
  final List<TrashedDeck> trashedDecks =
      ref.read(trashedDecksProvider).value ?? const <TrashedDeck>[];
  final bool originalInTrash = trashedDecks.any(
    (TrashedDeck deck) => deck.deck.id == item.card.deckId,
  );

  final RestoreDestination? destination = await pickRestoreDestination(
    context,
    sourceDeckTitle: item.sourceDeckTitle,
    originalAvailable: true,
    originalHint: originalInTrash ? AppStrings.trashRestoreCascadeHint(item.sourceDeckTitle) : null,
  );
  if (destination == null || !context.mounted) {
    return;
  }

  try {
    final TrashActions actions = ref.read(trashActionsProvider);
    String targetDeckId = item.card.deckId;
    if (destination.createNew) {
      final Deck created = await actions.createDeckForRestore(destination.newTitle);
      targetDeckId = created.id;
    } else if (originalInTrash) {
      // 原卡片集还在回收站：先恢复它，卡片才有地方落。
      await actions.restoreDeck(item.card.deckId);
    }
    await actions.restoreCard(item.card.id, targetDeckId: targetDeckId);
    if (!context.mounted) {
      return;
    }
    showRestoredToast(context);
  } on Object {
    if (!context.mounted) {
      return;
    }
    showRestoreFailedToast(context);
  }
}

class _TrashEmpty extends StatelessWidget {
  const _TrashEmpty();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      key: const ValueKey<String>('trash_empty'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.delete_outline, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(AppStrings.trashEmpty, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            AppStrings.trashEmptyHint,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// 加载失败态（回收站列表拉不下来时给重试）。
class TrashMessage extends StatelessWidget {
  const TrashMessage({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey<String>('trash_load_failed'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message),
          const SizedBox(height: 8),
          FilledButton(
            key: const ValueKey<String>('trash_retry'),
            onPressed: onRetry,
            child: const Text(AppStrings.cardRetry),
          ),
        ],
      ),
    );
  }
}
