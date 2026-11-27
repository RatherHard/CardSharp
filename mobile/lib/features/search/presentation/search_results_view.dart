import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/app_strings.dart';
import '../../decks/application/deck_cover_providers.dart';
import '../../decks/presentation/widgets/deck_cover.dart';
import '../../decks/presentation/widgets/demo_deck_covers.dart';
import '../domain/search_hit.dart';
import '../domain/search_results.dart';
import 'widgets/highlighted_text.dart';

/// 书架页搜索结果：按层级分档渲染。
///
/// 顺序就是层级顺序：**同级**（卡片集）→ **下级**（卡片）→ 上级（文件夹，暂未实现）。
/// 某档没有命中就整段不出现；两档都空时显示空态。
class ShelfSearchResultView extends StatelessWidget {
  const ShelfSearchResultView({
    required this.results,
    required this.onOpenDeck,
    required this.onOpenCard,
    required this.onShowMore,
    super.key,
  });

  final ShelfSearchResults results;
  final ValueChanged<String> onOpenDeck;
  final void Function(String deckId, String cardId) onOpenCard;
  final VoidCallback onShowMore;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const SearchEmptyState();
    }
    return ListView(
      key: const ValueKey<String>('search_results'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        if (results.decks.hits.isNotEmpty) ...<Widget>[
          const SearchSectionHeader(
            sectionKey: 'search_section_decks',
            title: AppStrings.searchSectionDecks,
          ),
          for (final DeckSearchHit hit in results.decks.hits)
            _DeckHitRow(hit: hit, onOpenDeck: onOpenDeck),
        ],
        if (results.cards.hits.isNotEmpty) ...<Widget>[
          const SearchSectionHeader(
            sectionKey: 'search_section_cards',
            title: AppStrings.searchSectionCards,
          ),
          for (final CardSearchHit hit in results.cards.hits)
            _CardHitRow(hit: hit, onOpenCard: onOpenCard, showSourceDeck: true),
        ],
        SearchFooter(
          outcome: results.cards,
          hasMore: results.decks.hasMore || results.cards.hasMore,
          onShowMore: onShowMore,
        ),
      ],
    );
  }
}

/// 卡片集详情页搜索结果：同级（本集卡片）在前，上级（本卡片集自己）在后。
class DeckSearchResultView extends StatelessWidget {
  const DeckSearchResultView({
    required this.results,
    required this.onOpenCard,
    required this.onOpenDeck,
    required this.onShowMore,
    super.key,
  });

  final DeckSearchResults results;
  final void Function(String deckId, String cardId) onOpenCard;

  /// 上级那一档点进去：跳出本集看它自己（当前就是本集，通常用于确认标题/简介）。
  final ValueChanged<String> onOpenDeck;
  final VoidCallback onShowMore;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const SearchEmptyState();
    }
    return ListView(
      key: const ValueKey<String>('search_results'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        if (results.cards.hits.isNotEmpty) ...<Widget>[
          const SearchSectionHeader(
            sectionKey: 'search_section_cards',
            title: AppStrings.searchSectionCards,
          ),
          for (final CardSearchHit hit in results.cards.hits)
            _CardHitRow(hit: hit, onOpenCard: onOpenCard, showSourceDeck: false),
        ],
        if (results.deck != null) ...<Widget>[
          const SearchSectionHeader(
            sectionKey: 'search_section_parent',
            title: AppStrings.searchSectionParent,
          ),
          _DeckHitRow(hit: results.deck!, onOpenDeck: onOpenDeck),
        ],
        SearchFooter(
          outcome: results.cards,
          hasMore: results.cards.hasMore,
          onShowMore: onShowMore,
        ),
      ],
    );
  }
}

/// 分档标题（「卡片集」/「卡片」/「上级」）。
class SearchSectionHeader extends StatelessWidget {
  const SearchSectionHeader({required this.sectionKey, required this.title, super.key});

  final String sectionKey;
  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      key: ValueKey<String>(sectionKey),
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}

class _DeckHitRow extends ConsumerWidget {
  const _DeckHitRow({required this.hit, required this.onOpenDeck});

  final DeckSearchHit hit;
  final ValueChanged<String> onOpenDeck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
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
  }
}

class _CardHitRow extends StatelessWidget {
  const _CardHitRow({required this.hit, required this.onOpenCard, required this.showSourceDeck});

  final CardSearchHit hit;
  final void Function(String deckId, String cardId) onOpenCard;

  /// 书架页跨集搜索要标来源；详情页里所有结果都来自同一集，不必重复。
  final bool showSourceDeck;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
class SearchFooter<T> extends StatelessWidget {
  const SearchFooter({required this.outcome, required this.onShowMore, this.hasMore, super.key});

  final SearchOutcome<T> outcome;
  final VoidCallback onShowMore;

  /// 多档结果时由调用方合并判断（例如书架页卡片集/卡片两档任一档还有更多）。
  final bool? hasMore;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool more = hasMore ?? outcome.hasMore;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: <Widget>[
          if (more)
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
