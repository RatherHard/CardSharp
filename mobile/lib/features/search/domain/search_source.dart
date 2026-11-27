import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_source.freezed.dart';

/// 卡片集搜索的候选来源。
@freezed
abstract class DeckSource with _$DeckSource {
  const factory DeckSource({
    required String id,
    required String title,
    required String description,
    required int cardCount,
    @Default('') String color,
  }) = _DeckSource;
}

/// 卡片搜索的候选来源：一个卡片集及其卡片。
@freezed
abstract class CardSource with _$CardSource {
  const factory CardSource({
    required String deckId,
    required String deckTitle,
    required List<CardSourceCard> cards,
  }) = _CardSource;
}

/// 候选来源里的一张卡片（只带搜索需要的字段，避免把整个 Card 传进来）。
@freezed
abstract class CardSourceCard with _$CardSourceCard {
  const factory CardSourceCard({
    required String id,
    required String name,
    required String plaintext,
    required String ciphertext,
  }) = _CardSourceCard;
}
