import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../decks/application/deck_list_state.dart';
import '../../decks/application/decks_controller.dart';
import '../../decks/domain/deck.dart';
import '../domain/search_hit.dart';
import '../domain/search_limits.dart';
import '../domain/search_results.dart';
import '../domain/search_service.dart';
import '../domain/search_source.dart';
import 'search_query.dart';
import 'use_cases/load_card_sources_use_case.dart';

/// 搜索输入状态。改关键词时把上限重置回默认值。
final searchQueryProvider = NotifierProvider<SearchQueryController, SearchQuery>(
  SearchQueryController.new,
);

class SearchQueryController extends Notifier<SearchQuery> {
  @override
  SearchQuery build() => const SearchQuery();

  void setKeyword(String keyword) => state = SearchQuery(keyword: keyword);

  void clear() => state = const SearchQuery();

  void showMore() => state = state.copyWith(hitLimit: state.hitLimit + kSearchHitLimitStep);
}

/// 书架页搜索：一次搜全部，结果按「卡片集 → 卡片」分档。
///
/// 同级（卡片集）与下级（卡片）各自带自己的命中总数，UI 分两段渲染；
/// 哪一段都没有命中时 [ShelfSearchResults.isEmpty] 为 true，显示空态。
final shelfSearchResultsProvider = FutureProvider<ShelfSearchResults>((ref) async {
  final SearchQuery query = ref.watch(searchQueryProvider);
  if (!query.isActive) {
    return const ShelfSearchResults(
      decks: SearchOutcome<DeckSearchHit>(hits: <DeckSearchHit>[], totalMatches: 0),
      cards: SearchOutcome<CardSearchHit>(hits: <CardSearchHit>[], totalMatches: 0),
    );
  }
  final DeckListState decks = await ref.watch(decksControllerProvider.future);
  final SearchService service = SearchService(hitLimit: query.hitLimit);
  return ShelfSearchResults(
    decks: service.searchDecks(<DeckSource>[
      for (final Deck deck in decks.decks)
        DeckSource(
          id: deck.id,
          title: deck.title,
          description: deck.description,
          cardCount: deck.cardCount,
          color: deck.color,
        ),
    ], query.keyword),
    cards: await _searchCards(
      ref,
      decks: decks.decks,
      keyword: query.keyword,
      hitLimit: query.hitLimit,
    ),
  );
});

/// 详情页搜索的参数：卡片集 + 关键词 + 条数上限。
///
/// 详情页自带关键词（不像书架页用全局状态），避免两个页面的搜索互相干扰。
typedef DeckSearchArgs = ({String deckId, String keyword, int hitLimit});

/// 卡片集详情页搜索：同级（本集卡片）+ 上级（本卡片集自己）。
final deckSearchResultsProvider = FutureProvider.family<DeckSearchResults, DeckSearchArgs>((
  ref,
  args,
) async {
  if (args.keyword.trim().isEmpty) {
    return const DeckSearchResults(
      cards: SearchOutcome<CardSearchHit>(hits: <CardSearchHit>[], totalMatches: 0),
    );
  }
  final DeckListState decks = await ref.watch(decksControllerProvider.future);
  Deck? target;
  for (final Deck deck in decks.decks) {
    if (deck.id == args.deckId) {
      target = deck;
      break;
    }
  }
  if (target == null) {
    return const DeckSearchResults(
      cards: SearchOutcome<CardSearchHit>(hits: <CardSearchHit>[], totalMatches: 0),
    );
  }
  final SearchService service = SearchService(hitLimit: args.hitLimit);
  final SearchOutcome<DeckSearchHit> self = service.searchDecks(<DeckSource>[
    DeckSource(
      id: target.id,
      title: target.title,
      description: target.description,
      cardCount: target.cardCount,
      color: target.color,
    ),
  ], args.keyword);
  return DeckSearchResults(
    cards: await _searchCards(
      ref,
      decks: <Deck>[target],
      keyword: args.keyword,
      hitLimit: args.hitLimit,
    ),
    deck: self.hits.isEmpty ? null : self.hits.first,
  );
});

Future<SearchOutcome<CardSearchHit>> _searchCards(
  Ref ref, {
  required List<Deck> decks,
  required String keyword,
  required int hitLimit,
}) async {
  final List<CardSource> sources = await ref
      .watch(loadCardSourcesUseCaseProvider)
      .call(decks: decks);
  return SearchService(hitLimit: hitLimit).searchCards(sources, keyword);
}
