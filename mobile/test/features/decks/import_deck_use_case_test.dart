import 'package:cardsharp/features/cards/data/fake_card_repository.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/features/decks/application/use_cases/import_deck_use_case.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:cardsharp/features/decks/domain/deck_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImportDeckUseCase', () {
    test('导入后能用返回的 deck.id 读回全部卡片', () async {
      final FakeDeckRepository decks = FakeDeckRepository();
      final FakeCardRepository cards = FakeCardRepository();
      final ImportDeckUseCase useCase = ImportDeckUseCase(decks, cards);

      final Deck deck = await useCase(
        const DeckImport(
          title: '导入的卡片集',
          description: '简介',
          color: '#10B981',
          cards: <ImportedDeckCard>[
            ImportedDeckCard(plaintext: '问一', ciphertext: '答一', hint: '提示一'),
            ImportedDeckCard(plaintext: '问二', ciphertext: '答二'),
          ],
        ),
      );

      final List<Card> stored = await cards.fetchCards(deck.id);
      expect(stored, hasLength(2));
      expect(stored.first.fields.plaintext, '问一');
      expect(stored.first.fields.hint, '提示一');
      expect(stored.last.fields.plaintext, '问二');
    });

    test('导入后卡片集的卡片数、简介、颜色都写入了', () async {
      final FakeDeckRepository decks = FakeDeckRepository();
      final FakeCardRepository cards = FakeCardRepository();
      final ImportDeckUseCase useCase = ImportDeckUseCase(decks, cards);

      final Deck deck = await useCase(
        const DeckImport(
          title: '统计检查',
          description: '一句简介',
          color: '#5B5BD6',
          cards: <ImportedDeckCard>[ImportedDeckCard(plaintext: 'a', ciphertext: 'b')],
        ),
      );

      final Deck? reloaded = (await decks.fetchDecks())
          .where((Deck d) => d.id == deck.id)
          .firstOrNull;
      expect(reloaded, isNotNull);
      expect(reloaded!.cardCount, 1);
      expect(reloaded.description, '一句简介');
      expect(reloaded.color, '#5B5BD6');
    });
  });
}
