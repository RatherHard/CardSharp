import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/repository_providers.dart';
import '../../../core/network/page.dart';
import '../../cards/domain/card.dart';
import '../../cards/domain/card_repository.dart';
import '../../decks/application/decks_controller.dart';
import '../../decks/application/deck_list_state.dart';
import '../../decks/domain/deck.dart';
import '../domain/search_hit.dart';
import '../domain/search_mode.dart';
import '../domain/search_service.dart';

/// 搜索的输入状态：模式 + 关键词 + 结果上限。
class SearchQuery {
  const SearchQuery({
    this.mode = SearchMode.decks,
    this.keyword = '',
    this.hitLimit = _defaultHitLimit,
  });

  /// 默认返回条数，对齐 `docs/03`「结果限 50 条」。
  static const int _defaultHitLimit = 50;

  /// 点一次「更多搜索结果」增加多少条。
  static const int step = 50;

  final SearchMode mode;
  final String keyword;
  final int hitLimit;

  bool get isActive => keyword.trim().isNotEmpty;

  SearchQuery copyWith({SearchMode? mode, String? keyword, int? hitLimit}) => SearchQuery(
    mode: mode ?? this.mode,
    keyword: keyword ?? this.keyword,
    hitLimit: hitLimit ?? this.hitLimit,
  );
}

/// 搜索输入状态。改关键词时把上限重置回默认值。
final searchQueryProvider = NotifierProvider<SearchQueryController, SearchQuery>(
  SearchQueryController.new,
);

class SearchQueryController extends Notifier<SearchQuery> {
  @override
  SearchQuery build() => const SearchQuery();

  void setMode(SearchMode mode) => state = state.copyWith(mode: mode);

  void setKeyword(String keyword) => state = SearchQuery(mode: state.mode, keyword: keyword);

  void clear() => state = SearchQuery(mode: state.mode);

  void showMore() => state = state.copyWith(hitLimit: state.hitLimit + SearchQuery.step);
}

/// 卡片集搜索结果（书架页「卡片集」模式）。
final deckSearchResultProvider = FutureProvider<SearchOutcome<DeckSearchHit>>((ref) async {
  final SearchQuery query = ref.watch(searchQueryProvider);
  if (!query.isActive || query.mode != SearchMode.decks) {
    return const SearchOutcome<DeckSearchHit>(hits: <DeckSearchHit>[], totalMatches: 0);
  }
  final DeckListState decks = await ref.watch(decksControllerProvider.future);
  return SearchService(hitLimit: query.hitLimit).searchDecks(<DeckSource>[
    for (final Deck deck in decks.decks)
      DeckSource(
        id: deck.id,
        title: deck.title,
        description: deck.description,
        cardCount: deck.cardCount,
        color: deck.color,
      ),
  ], query.keyword);
});

/// 全局卡片搜索结果（书架页「全部卡片」模式）。
final allCardsSearchResultProvider = FutureProvider<SearchOutcome<CardSearchHit>>((ref) async {
  final SearchQuery query = ref.watch(searchQueryProvider);
  if (!query.isActive || query.mode != SearchMode.allCards) {
    return const SearchOutcome<CardSearchHit>(hits: <CardSearchHit>[], totalMatches: 0);
  }
  final DeckListState decks = await ref.watch(decksControllerProvider.future);
  final List<CardSource> sources = await loadCardSources(
    ref,
    decks: decks.decks,
    scanLimit: scanLimit,
  );
  return SearchService(
    hitLimit: query.hitLimit,
    scanLimit: scanLimit,
  ).searchCards(sources, query.keyword);
});

/// 本集搜索的参数：卡片集 + 关键词 + 条数上限。
///
/// 详情页自带关键词（不像书架页用全局状态），避免两个页面的搜索互相干扰。
typedef DeckCardSearchArgs = ({String deckId, String keyword, int hitLimit});

/// 本集卡片搜索结果（卡片集详情页）。
final deckCardsSearchResultProvider =
    FutureProvider.family<SearchOutcome<CardSearchHit>, DeckCardSearchArgs>((ref, args) async {
      if (args.keyword.trim().isEmpty) {
        return const SearchOutcome<CardSearchHit>(hits: <CardSearchHit>[], totalMatches: 0);
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
        return const SearchOutcome<CardSearchHit>(hits: <CardSearchHit>[], totalMatches: 0);
      }
      final List<CardSource> sources = await loadCardSources(
        ref,
        decks: <Deck>[target],
        scanLimit: scanLimit,
      );
      return SearchService(
        hitLimit: args.hitLimit,
        scanLimit: scanLimit,
      ).searchCards(sources, args.keyword);
    });

/// 一次搜索最多扫描多少张卡片；超过就提示用户缩小范围。
const int scanLimit = 500;

/// 每页拉取数量。
const int _pageSize = 50;

/// 把若干卡片集下的卡片读成搜索候选。
///
/// 「读数据」与「匹配」分开：匹配在 [SearchService]，接后端时只换这里的取数方式。
Future<List<CardSource>> loadCardSources(
  Ref ref, {
  required List<Deck> decks,
  required int scanLimit,
}) async {
  final CardRepository repository = ref.watch(cardRepositoryProvider);
  final List<CardSource> sources = <CardSource>[];
  int scanned = 0;

  for (final Deck deck in decks) {
    if (scanned >= scanLimit) {
      break;
    }
    final List<CardSourceCard> cards = <CardSourceCard>[];
    String? cursor;
    while (scanned < scanLimit) {
      final PagedResult<Card> page = await repository.fetchCards(
        deck.id,
        cursor: cursor,
        limit: _pageSize,
      );
      for (final Card card in page.items) {
        if (scanned >= scanLimit) {
          break;
        }
        cards.add(
          CardSourceCard(
            id: card.id,
            name: card.fields.plaintext,
            plaintext: card.fields.plaintext,
            ciphertext: card.fields.ciphertext,
          ),
        );
        scanned++;
      }
      cursor = page.nextCursor;
      if (cursor == null) {
        break;
      }
    }
    if (cards.isNotEmpty) {
      sources.add(CardSource(deckId: deck.id, deckTitle: deck.title, cards: cards));
    }
  }
  return sources;
}
