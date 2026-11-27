import 'search_hit.dart';

/// 本地搜索服务：**纯函数**，不依赖 Riverpod、不依赖 Flutter。
///
/// 现在的数据都在内存里，所以直接遍历过滤；接后端后把内部实现换成调用
/// `GET /search?q=&deck_id=`（`docs/03` §6），页面与状态层不用改。
class SearchService {
  const SearchService({this.hitLimit = 50, this.scanLimit = 500});

  /// 单次返回的最大命中条数。对齐 `docs/03` 的「结果限 50 条」。
  final int hitLimit;

  /// 最多扫描多少张卡片。全局搜索要遍历所有卡片，加个上限避免卡顿。
  final int scanLimit;

  /// 按名称 + 简介搜卡片集。
  SearchOutcome<DeckSearchHit> searchDecks(List<DeckSource> decks, String keyword) {
    final String query = keyword.trim();
    if (query.isEmpty) {
      return const SearchOutcome<DeckSearchHit>(hits: <DeckSearchHit>[], totalMatches: 0);
    }

    final List<DeckSearchHit> hits = <DeckSearchHit>[];
    int total = 0;
    for (final DeckSource deck in decks) {
      final List<MatchRange> titleRanges = findAll(deck.title, query);
      final List<MatchRange> descriptionRanges = findAll(deck.description, query);
      if (titleRanges.isEmpty && descriptionRanges.isEmpty) {
        continue;
      }
      total++;
      if (hits.length >= hitLimit) {
        continue;
      }
      hits.add(
        DeckSearchHit(
          deckId: deck.id,
          title: deck.title,
          description: deck.description,
          titleRanges: titleRanges,
          descriptionRanges: descriptionRanges,
          cardCount: deck.cardCount,
          color: deck.color,
        ),
      );
    }

    return SearchOutcome<DeckSearchHit>(hits: hits, totalMatches: total);
  }

  /// 按明文 + 暗文搜卡片。明文命中优先展示，否则展示暗文命中。
  SearchOutcome<CardSearchHit> searchCards(List<CardSource> sources, String keyword) {
    final String query = keyword.trim();
    if (query.isEmpty) {
      return const SearchOutcome<CardSearchHit>(hits: <CardSearchHit>[], totalMatches: 0);
    }

    final List<CardSearchHit> hits = <CardSearchHit>[];
    int total = 0;
    int scanned = 0;
    bool scanLimitReached = false;

    outer:
    for (final CardSource source in sources) {
      for (final CardSourceCard card in source.cards) {
        if (scanned >= scanLimit) {
          scanLimitReached = true;
          break outer;
        }
        scanned++;

        final List<MatchRange> plainRanges = findAll(card.plaintext, query);
        final List<MatchRange> cipherRanges = findAll(card.ciphertext, query);
        if (plainRanges.isEmpty && cipherRanges.isEmpty) {
          continue;
        }
        total++;
        if (hits.length >= hitLimit) {
          continue;
        }
        final bool inPlaintext = plainRanges.isNotEmpty;
        hits.add(
          CardSearchHit(
            deckId: source.deckId,
            deckTitle: source.deckTitle,
            cardId: card.id,
            cardName: card.name,
            field: inPlaintext ? CardMatchField.plaintext : CardMatchField.ciphertext,
            text: inPlaintext ? card.plaintext : card.ciphertext,
            ranges: inPlaintext ? plainRanges : cipherRanges,
          ),
        );
      }
    }

    return SearchOutcome<CardSearchHit>(
      hits: hits,
      totalMatches: total,
      scanLimitReached: scanLimitReached,
      scannedCount: scanned,
    );
  }

  /// 找出 [text] 中所有 [query] 的出现位置。
  ///
  /// 忽略大小写；中文按字符直接匹配（模糊/拼音需要后端 `pg_trgm`，前端做不了）。
  static List<MatchRange> findAll(String text, String query) {
    if (text.isEmpty || query.isEmpty) {
      return const <MatchRange>[];
    }
    final String haystack = text.toLowerCase();
    final String needle = query.toLowerCase();
    final List<MatchRange> ranges = <MatchRange>[];
    int index = haystack.indexOf(needle);
    while (index >= 0) {
      ranges.add(MatchRange(start: index, end: index + needle.length));
      index = haystack.indexOf(needle, index + needle.length);
    }
    return ranges;
  }
}
