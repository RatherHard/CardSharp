import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// material_ui 也导出了 `Card`（Material 卡片组件），与卡片领域模型重名，这里只留领域模型。
import 'package:material_ui/material_ui.dart' hide Card;

import '../../../core/l10n/app_strings.dart';
import '../../cards/domain/card.dart';
import '../../decks/application/deck_cover_providers.dart';
import '../../decks/domain/deck.dart';
import '../../decks/domain/trashed_deck.dart';
import '../../decks/presentation/widgets/deck_cover.dart';
import '../../decks/presentation/widgets/demo_deck_covers.dart';
import '../application/trash_providers.dart';
import 'trash_body.dart';
import 'trash_widgets.dart';

/// 回收站里的一个卡片集：只读列表 + 每行恢复 + 顶部「恢复整个卡片集」。
///
/// 单张恢复的语义（grill 决策）：卡片必须有归属的卡片集，所以只有两条路——
/// 新建一个卡片集装它，或者把整个卡片集（含这张卡）一起恢复。
class TrashDeckPage extends ConsumerWidget {
  const TrashDeckPage({super.key, required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<TrashedDeck>> decksAsync = ref.watch(trashedDecksProvider);
    final AsyncValue<List<Card>> cardsAsync = ref.watch(trashedDeckCardsProvider(deckId));

    final List<TrashedDeck> decks = decksAsync.value ?? const <TrashedDeck>[];
    TrashedDeck? deck;
    for (final TrashedDeck item in decks) {
      if (item.deck.id == deckId) {
        deck = item;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        key: const ValueKey<String>('trash_deck_app_bar'),
        title: Text(deck?.deck.title ?? AppStrings.trashTitle),
        leading: IconButton(
          key: const ValueKey<String>('trash_deck_back'),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: deck == null
          ? const Center(
              key: ValueKey<String>('trash_deck_not_found'),
              child: Text(AppStrings.trashDeckNotFound),
            )
          : switch (cardsAsync) {
              AsyncValue<List<Card>>(hasError: true) => Center(
                key: const ValueKey<String>('trash_deck_load_failed'),
                child: FilledButton(
                  key: const ValueKey<String>('trash_deck_retry'),
                  onPressed: () => ref.invalidate(trashedDeckCardsProvider(deckId)),
                  child: const Text(AppStrings.cardRetry),
                ),
              ),
              AsyncValue<List<Card>>(hasValue: true) => _TrashDeckBody(
                deck: deck,
                cards: cardsAsync.value ?? const <Card>[],
              ),
              _ => const Center(
                child: CircularProgressIndicator(key: ValueKey<String>('trash_deck_loading')),
              ),
            },
    );
  }
}

class _TrashDeckBody extends ConsumerWidget {
  const _TrashDeckBody({required this.deck, required this.cards});

  final TrashedDeck deck;
  final List<Card> cards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 64,
                height: 64,
                child: DeckCover(
                  tint: deckTint(deck.deck.color),
                  coverAsset: demoCoverFor(deck.deck.title),
                  coverFilePath: ref.watch(deckCoverPathProvider(deck.deck.id)).value,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      deck.deck.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.deckCardCount(cards.length),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                key: const ValueKey<String>('trash_restore_whole_deck'),
                onPressed: () => restoreWholeDeck(context, ref, deck),
                child: const Text(AppStrings.trashRestoreWholeDeck),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (cards.isEmpty)
          const Expanded(
            child: Center(
              key: ValueKey<String>('trash_deck_empty'),
              child: Text(AppStrings.trashDeckEmpty),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              key: const ValueKey<String>('trash_deck_cards'),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: cards.length,
              itemBuilder: (BuildContext context, int index) {
                final Card card = cards[index];
                return Container(
                  key: ValueKey<String>('trash_deck_card_${card.id}'),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          card.fields.plaintext,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      TextButton(
                        key: ValueKey<String>('trash_deck_restore_card_${card.id}'),
                        onPressed: () => _restoreFromDeck(context, ref, card),
                        child: const Text(AppStrings.trashRestore),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  /// 回收站卡片详情里恢复单张：
  /// - 选「新建卡片集」→ 建集后把这张卡放进去；
  /// - 选「原卡片集」→ 整个集一起恢复（这张卡自然也在里面），避免留下无法访问的残留卡片。
  Future<void> _restoreFromDeck(BuildContext context, WidgetRef ref, Card card) async {
    final RestoreDestination? destination = await pickRestoreDestination(
      context,
      sourceDeckTitle: deck.deck.title,
      originalAvailable: true,
      originalHint: AppStrings.trashRestoreWithDeckHint(deck.deck.title),
    );
    if (destination == null || !context.mounted) {
      return;
    }
    try {
      final TrashActions actions = ref.read(trashActionsProvider);
      if (!destination.createNew) {
        await actions.restoreDeck(deck.deck.id);
      } else {
        final Deck created = await actions.createDeckForRestore(destination.newTitle);
        await actions.restoreCard(card.id, targetDeckId: created.id);
      }
      if (!context.mounted) {
        return;
      }
      showRestoredToast(context);
      if (!destination.createNew) {
        // 整个集已恢复，回收站详情页没有内容了，退回回收站首页。
        context.pop();
      }
    } on Object catch (error) {
      if (!context.mounted) {
        return;
      }
      showRestoreFailureToast(context, error);
    }
  }
}
