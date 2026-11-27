import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_hit.freezed.dart';

/// 一段命中区间，用于高亮渲染。
///
/// `start` 含、`end` 不含（与 Dart 的 `String.substring` 一致）。
@freezed
abstract class MatchRange with _$MatchRange {
  const factory MatchRange({required int start, required int end}) = _MatchRange;
}

/// 卡片命中在哪个字段。展示时用来标注「命中的是暗文还是明文」。
enum CardMatchField { plaintext, ciphertext }

/// 卡片搜索结果的一项。
@freezed
abstract class CardSearchHit with _$CardSearchHit {
  const factory CardSearchHit({
    required String deckId,
    required String deckTitle,
    required String cardId,

    /// 卡片在列表里显示的名字（明文，或卡片页用的名字字段）。
    required String cardName,

    /// 命中所在的字段。
    required CardMatchField field,

    /// 用于展示的文本（命中所在的完整文本，可能被截断显示）。
    required String text,

    /// [text] 内的命中区间。
    required List<MatchRange> ranges,
  }) = _CardSearchHit;
}

/// 卡片集搜索结果的一项。
@freezed
abstract class DeckSearchHit with _$DeckSearchHit {
  const factory DeckSearchHit({
    required String deckId,
    required String title,
    required String description,

    /// 名称内的命中区间。
    required List<MatchRange> titleRanges,

    /// 简介内的命中区间。
    required List<MatchRange> descriptionRanges,

    /// 卡片数，用于和书架卡片保持一致。
    required int cardCount,

    /// 卡片集颜色，用于结果里的封面着色。
    @Default('') String color,
  }) = _DeckSearchHit;
}

/// 一次搜索的结果。
///
/// [totalMatches] 是命中总数（不受 [hits] 长度限制影响），用来判断要不要显示
/// 「更多搜索结果」；[hitLimit] 是本次实际取用的上限。
@freezed
abstract class SearchOutcome<T> with _$SearchOutcome<T> {
  const factory SearchOutcome({
    required List<T> hits,
    required int totalMatches,
    @Default(false) bool scanLimitReached,
    @Default(0) int scannedCount,
  }) = _SearchOutcome<T>;

  const SearchOutcome._();

  /// 还有更多命中没展示（可以放宽 limit 再搜一次）。
  bool get hasMore => hits.length < totalMatches;
}

// 搜索的候选来源（`DeckSource`/`CardSource`/`CardSourceCard`）在 `search_source.dart`：
// 这个文件只放「搜索结果」的形状，来源形状的变化比结果更频繁。
