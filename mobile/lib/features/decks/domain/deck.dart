import 'package:freezed_annotation/freezed_annotation.dart';

part 'deck.freezed.dart';
part 'deck.g.dart';

/// 卡片集在客户端的投影。
///
/// 只放本期列表真正需要的字段：`docs/02` FR-2.2 里的封面、文件夹、
/// 类型配置、今日待复习统计等，等 E2 详情页与后端契约确定后再补，
/// 避免现在把未定的字段先写死。
@freezed
abstract class Deck with _$Deck {
  const factory Deck({
    required String id,
    required String title,
    @Default('') String description,
    @Default(0) int cardCount,
  }) = _Deck;

  factory Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);
}
