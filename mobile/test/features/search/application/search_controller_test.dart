import 'package:cardsharp/core/di/repository_providers.dart';
import 'package:cardsharp/features/cards/data/fake_card_repository.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:cardsharp/features/search/application/search_controller.dart';
import 'package:cardsharp/features/search/application/search_query.dart';
import 'package:cardsharp/features/search/domain/search_limits.dart';
import 'package:cardsharp/features/search/domain/search_results.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 搜索的状态与结果：状态机的有效/无效输入，以及「从假仓储读数据再匹配」的整条链路。
void main() {
  ProviderContainer buildContainer() {
    final FakeCardRepository cards = FakeCardRepository(<String, List<Card>>{
      'd1': const <Card>[
        Card(
          id: 'c1',
          deckId: 'd1',
          sortOrder: 0,
          fields: CardFields(plaintext: '奶蛙', ciphertext: '绿眼睛和浅色的肚皮'),
        ),
        Card(
          id: 'c2',
          deckId: 'd1',
          sortOrder: 1,
          fields: CardFields(plaintext: '奶蛋', ciphertext: '圆润的黄色蛋形角色'),
        ),
      ],
    });
    final ProviderContainer container = ProviderContainer(
      overrides: [
        cardRepositoryProvider.overrideWithValue(cards),
        deckRepositoryProvider.overrideWithValue(
          FakeDeckRepository(const <Deck>[
            Deck(id: 'd1', title: '奶蛙家族图鉴', description: '按外形认角色'),
          ], cards.countFor),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('SearchQuery 状态机', () {
    test('默认空关键词、默认上限、不算活跃', () {
      final ProviderContainer container = buildContainer();
      final SearchQuery query = container.read(searchQueryProvider);

      expect(query.keyword, '');
      expect(query.hitLimit, kSearchHitLimit);
      expect(query.isActive, isFalse);
    });

    test('改关键词把上限重置回默认值', () {
      final ProviderContainer container = buildContainer();
      final SearchQueryController controller = container.read(searchQueryProvider.notifier);

      controller.setKeyword('奶');
      controller.showMore();
      expect(container.read(searchQueryProvider).hitLimit, kSearchHitLimit + kSearchHitLimitStep);

      controller.setKeyword('奶蛙');
      expect(container.read(searchQueryProvider).hitLimit, kSearchHitLimit);
    });

    test('清空关键词后不活跃', () {
      final ProviderContainer container = buildContainer();
      final SearchQueryController controller = container.read(searchQueryProvider.notifier);

      controller.setKeyword('奶');
      expect(container.read(searchQueryProvider).isActive, isTrue);

      controller.clear();
      expect(container.read(searchQueryProvider).keyword, '');
      expect(container.read(searchQueryProvider).isActive, isFalse);
    });

    test('只有空白关键词不算活跃', () {
      final ProviderContainer container = buildContainer();
      container.read(searchQueryProvider.notifier).setKeyword('   ');

      expect(container.read(searchQueryProvider).isActive, isFalse);
    });
  });

  group('书架页搜索结果（同级在前、下级在后）', () {
    test('未输入关键词时不返回结果（反例）', () async {
      final ProviderContainer container = buildContainer();

      final ShelfSearchResults results = await container.read(shelfSearchResultsProvider.future);

      expect(results.isEmpty, isTrue);
      expect(results.decks.hits, isEmpty);
      expect(results.cards.hits, isEmpty);
    });

    test('一次搜索同时给出卡片集（同级）与卡片（下级）两档结果', () async {
      final ProviderContainer container = buildContainer();
      container.read(searchQueryProvider.notifier).setKeyword('奶蛙');

      final ShelfSearchResults results = await container.read(shelfSearchResultsProvider.future);

      // 同级：卡片集标题命中。
      expect(results.decks.hits, hasLength(1));
      expect(results.decks.hits.first.deckId, 'd1');
      expect(results.decks.hits.first.titleRanges, isNotEmpty);
      // 下级：卡片明文命中。
      expect(results.cards.hits, hasLength(1));
      expect(results.cards.hits.first.cardName, '奶蛙');
    });

    test('只有卡片命中时，卡片集那一档为空（空档不渲染）', () async {
      final ProviderContainer container = buildContainer();
      container.read(searchQueryProvider.notifier).setKeyword('绿眼睛');

      final ShelfSearchResults results = await container.read(shelfSearchResultsProvider.future);

      expect(results.decks.hits, isEmpty);
      expect(results.cards.hits, hasLength(1));
      expect(results.cards.hits.first.cardName, '奶蛙');
      expect(results.cards.scannedCount, 2);
      expect(results.isEmpty, isFalse);
    });
  });

  group('详情页搜索结果（同级在前、上级在后）', () {
    const DeckSearchArgs args = (deckId: 'd1', keyword: '奶蛙', hitLimit: kSearchHitLimit);

    test('关键词同时命中本集卡片与卡片集自己：卡片在前、上级给出一条', () async {
      final ProviderContainer container = buildContainer();

      final DeckSearchResults results = await container.read(
        deckSearchResultsProvider(args).future,
      );

      expect(results.cards.hits, hasLength(1));
      expect(results.cards.hits.first.cardName, '奶蛙');
      expect(results.deck?.deckId, 'd1');
      expect(results.deck?.titleRanges, isNotEmpty);
    });

    test('只命中卡片时不返回上级那一档', () async {
      final ProviderContainer container = buildContainer();

      final DeckSearchResults results = await container.read(
        deckSearchResultsProvider((deckId: 'd1', keyword: '绿眼睛', hitLimit: kSearchHitLimit)).future,
      );

      expect(results.cards.hits, hasLength(1));
      expect(results.deck, isNull);
      expect(results.isEmpty, isFalse);
    });

    test('卡片集不存在时返回空结果（反例）', () async {
      final ProviderContainer container = buildContainer();

      final DeckSearchResults results = await container.read(
        deckSearchResultsProvider((deckId: 'missing', keyword: '奶蛙', hitLimit: kSearchHitLimit))
            .future,
      );

      expect(results.isEmpty, isTrue);
    });
  });
}
