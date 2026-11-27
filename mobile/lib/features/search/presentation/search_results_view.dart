import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/app_strings.dart';
import '../../decks/application/deck_cover_providers.dart';
import '../../decks/presentation/widgets/deck_cover.dart';
import '../../decks/presentation/widgets/demo_deck_covers.dart';
import '../domain/search_hit.dart';
import 'widgets/highlighted_text.dart';

/// 卡片集搜索结果列表（书架页「卡片集」模式）。
///
/// 用 ConsumerWidget：缩略图要读「用户自选封面」的本地路径，
/// 保证搜索结果里的封面与书架/详情页完全一致。
class DeckSearchResultList extends ConsumerWidget {
  const DeckSearchResultList({
    required this.outcome,
    required this.onOpenDeck,
    required this.onShowMore,
    super.key,
  });

  final SearchOutcome<DeckSearchHit> outcome;
  final ValueChanged<String> onOpenDeck;
  final VoidCallback onShowMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    if (outcome.hits.isEmpty) {
      return const SearchEmptyState();
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: outcome.hits.length + 1,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        if (index == outcome.hits.length) {
          return SearchFooter(outcome: outcome, onShowMore: onShowMore);
        }
        final DeckSearchHit hit = outcome.hits[index];
        return InkWell(
          key: ValueKey<String>('search_deck_${hit.deckId}'),
          onTap: () => onOpenDeck(hit.deckId),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 48,
                  height: 48,
                  child: DeckCover(
                    tint: deckTint(hit.color),
                    coverAsset: demoCoverFor(hit.title),
                    coverFilePath: ref.watch(deckCoverPathProvider(hit.deckId)).value,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      HighlightedText(
                        text: hit.title,
                        ranges: hit.titleRanges,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                      ),
                      if (hit.description.isNotEmpty)
                        HighlightedText(
                          text: hit.description,
                          ranges: hit.descriptionRanges,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.deckCardCount(hit.cardCount),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 卡片搜索结果列表（书架页「全部卡片」与详情页「本集」共用）。
class CardSearchResultList extends StatelessWidget {
  const CardSearchResultList({
    required this.outcome,
    required this.onOpenCard,
    required this.onShowMore,
    this.showSourceDeck = true,
    super.key,
  });

  final SearchOutcome<CardSearchHit> outcome;
  final void Function(String deckId, String cardId) onOpenCard;
  final VoidCallback onShowMore;

  /// 详情页里所有结果都来自同一个卡片集，不需要重复显示来源。
  final bool showSourceDeck;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (outcome.hits.isEmpty) {
      return const SearchEmptyState();
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: outcome.hits.length + 1,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        if (index == outcome.hits.length) {
          return SearchFooter(outcome: outcome, onShowMore: onShowMore);
        }
        final CardSearchHit hit = outcome.hits[index];
        return InkWell(
          key: ValueKey<String>('search_card_${hit.cardId}'),
          onTap: () => onOpenCard(hit.deckId, hit.cardId),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        hit.cardName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    _FieldBadge(field: hit.field),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                HighlightedText(
                  text: hit.text,
                  ranges: hit.ranges,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                ),
                if (showSourceDeck) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.searchFromDeck(hit.deckTitle),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FieldBadge extends StatelessWidget {
  const _FieldBadge({required this.field});

  final CardMatchField field;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        field == CardMatchField.plaintext
            ? AppStrings.searchFieldPlaintext
            : AppStrings.searchFieldCiphertext,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSecondaryContainer),
      ),
    );
  }
}

/// 结果列表底部：是否还有更多、是否触到扫描上限。
class SearchFooter extends StatelessWidget {
  const SearchFooter({required this.outcome, required this.onShowMore, super.key});

  final SearchOutcome<dynamic> outcome;
  final VoidCallback onShowMore;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: <Widget>[
          if (outcome.hasMore)
            TextButton(
              key: const ValueKey<String>('search_show_more'),
              onPressed: onShowMore,
              child: const Text(AppStrings.searchMoreResults),
            ),
          if (outcome.scanLimitReached)
            Text(
              AppStrings.searchScanLimit(outcome.scannedCount),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      key: const ValueKey<String>('search_empty_state'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.search_off, size: 40, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(AppStrings.searchEmptyTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            AppStrings.searchEmptySubtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
