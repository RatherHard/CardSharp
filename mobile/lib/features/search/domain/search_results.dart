import 'package:freezed_annotation/freezed_annotation.dart';

import 'search_hit.dart';

part 'search_results.freezed.dart';

/// 书架页一次搜索的结果，按层级分档。
///
/// 层级（`docs/02` FR-2.1 的文件夹还没做，当前只有两层）：
/// - [decks]：**同级**——卡片集自己命中；
/// - [cards]：**下级**——卡片命中（卡片属于卡片集）；
/// - 上级（文件夹）：暂未实现，等文件夹功能上线后再补一档。
@freezed
abstract class ShelfSearchResults with _$ShelfSearchResults {
  const factory ShelfSearchResults({
    required SearchOutcome<DeckSearchHit> decks,
    required SearchOutcome<CardSearchHit> cards,
  }) = _ShelfSearchResults;

  const ShelfSearchResults._();

  bool get isEmpty => decks.hits.isEmpty && cards.hits.isEmpty;

  /// 卡片的命中总数（「更多」按卡片算，卡片集一般不多）。
  int get cardTotal => cards.totalMatches;
}

/// 卡片集详情页一次搜索的结果，按层级分档。
///
/// - [cards]：**同级**——本集卡片命中；
/// - [deck]：**上级**——本卡片集自己在标题/简介里命中时给出一条，方便从集里跳出去看自己。
@freezed
abstract class DeckSearchResults with _$DeckSearchResults {
  const factory DeckSearchResults({
    required SearchOutcome<CardSearchHit> cards,
    DeckSearchHit? deck,
  }) = _DeckSearchResults;

  const DeckSearchResults._();

  bool get isEmpty => cards.hits.isEmpty && deck == null;
}
