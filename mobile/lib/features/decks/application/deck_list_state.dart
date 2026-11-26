import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/deck.dart';

part 'deck_list_state.freezed.dart';

/// 书架列表状态：已加载的卡片集 + 下一页游标。
///
/// 用状态类而不是裸 `List<Deck>`：`hasMore` 与 `loadingMore` 也属于列表状态，
/// 放在页面里各存一份会重复，且容易与数据不同步。
@freezed
abstract class DeckListState with _$DeckListState {
  const factory DeckListState({
    required List<Deck> decks,
    String? nextCursor,
    @Default(false) bool loadingMore,
  }) = _DeckListState;

  const DeckListState._();

  /// 还有下一页（游标非 null 即表示数据源没到底）。
  bool get hasMore => nextCursor != null;
}
