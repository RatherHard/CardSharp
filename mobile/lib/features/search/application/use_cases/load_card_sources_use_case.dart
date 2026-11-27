import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/repository_providers.dart';
import '../../../../core/network/page.dart';
import '../../../cards/domain/card.dart';
import '../../../cards/domain/card_repository.dart';
import '../../../decks/domain/deck.dart';
import '../../domain/search_limits.dart';
import '../../domain/search_source.dart';

/// 把若干卡片集下的卡片读成搜索候选。
///
/// 「读数据」与「匹配」分开：匹配在 `SearchService`，接后端时只换这里的取数方式。
/// 控制器只通过它访问仓储（`docs/05` §6）。
class LoadCardSourcesUseCase {
  const LoadCardSourcesUseCase(this._cards);

  final CardRepository _cards;

  Future<List<CardSource>> call({
    required List<Deck> decks,
    int scanLimit = kSearchScanLimit,
  }) async {
    final List<CardSource> sources = <CardSource>[];
    int scanned = 0;

    for (final Deck deck in decks) {
      if (scanned >= scanLimit) {
        break;
      }
      final List<CardSourceCard> cards = <CardSourceCard>[];
      String? cursor;
      while (scanned < scanLimit) {
        final PagedResult<Card> page = await _cards.fetchCards(
          deck.id,
          cursor: cursor,
          limit: kSearchPageSize,
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
}

final loadCardSourcesUseCaseProvider = Provider<LoadCardSourcesUseCase>(
  (Ref ref) => LoadCardSourcesUseCase(ref.watch(cardRepositoryProvider)),
);
