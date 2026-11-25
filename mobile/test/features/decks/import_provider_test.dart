import 'package:cardsharp/features/cards/application/cards_controller.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/features/decks/application/decks_controller.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:cardsharp/features/decks/domain/deck_import.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 用真实的 ProviderContainer 复现 App 里的调用链：
/// 导入走 decksController → 详情页用 cardsForDeckProvider 读卡片。
/// 这个测试能抓到「两个 Provider 拿到不同仓储实例」这类问题。
void main() {
  test('导入后通过 Provider 读卡片能读到', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final Deck deck = await container
        .read(decksControllerProvider.notifier)
        .importDeck(
          const DeckImport(
            title: '容器测试',
            description: '简介',
            color: '#10B981',
            cards: <ImportedDeckCard>[
              ImportedDeckCard(plaintext: '问一', ciphertext: '答一'),
              ImportedDeckCard(plaintext: '问二', ciphertext: '答二'),
              ImportedDeckCard(plaintext: '问三', ciphertext: '答三'),
            ],
          ),
        );

    final List<Card> cards = await container.read(cardsForDeckProvider(deck.id).future);

    expect(cards, hasLength(3));
    expect(cards.first.fields.plaintext, '问一');
  });
}
