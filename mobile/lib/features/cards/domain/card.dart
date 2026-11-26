import 'package:freezed_annotation/freezed_annotation.dart';

part 'card.freezed.dart';
part 'card.g.dart';

/// 卡片配图。
///
/// `key` 是对象存储的 key（不是完整 URL），尺寸与 alt 由后端在生成时写入。
/// 本期（纯前端）没有图片，字段先按契约保留，避免接后端时改模型。
@freezed
abstract class CardImage with _$CardImage {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CardImage({required String key, int? width, int? height, String? alt}) = _CardImage;

  factory CardImage.fromJson(Map<String, dynamic> json) => _$CardImageFromJson(json);
}

/// 卡片内容（对应后端 `cards.fields` 这个 JSON 列）。
///
/// 字段命名严格对齐 `docs/03` §4.4：
/// - `plaintext` 明文（正面，本仓库当前用作卡片名，列表页显示它）
/// - `ciphertext` 暗文（背面，卡片页显示为词条释义）
/// - `images` / `hint` / `extra`
///
/// `question` 是**本地演示字段**（`docs/03` §4.4 暂无此列）：产品上「列表显示名字、
/// 复习显示问句」需要两者并存，故先在 `fields` 里多存一个可选键。
/// 后端接入时二选一：由后端新增 question 列，或把问句写回 `plaintext`
/// 并另建 name 字段；届时只改这里与 `parseDeckImport`，界面不用动。
///
/// 约束（`docs/03:551`）：plaintext ≤ 200 字、ciphertext ≤ 500 字，均不可为空。
@freezed
abstract class CardFields with _$CardFields {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CardFields({
    required String plaintext,
    required String ciphertext,
    @Default(<CardImage>[]) List<CardImage> images,
    String? hint,
    String? extra,
    String? question,
  }) = _CardFields;

  factory CardFields.fromJson(Map<String, dynamic> json) => _$CardFieldsFromJson(json);
}

/// 一张卡片。
///
/// 只放后端 `cards` 表里客户端真正需要的列；`content_hash` 是去重用的服务端字段，
/// 客户端不参与计算，故不建模。
///
/// 序列化键名统一转成下划线（`deck_id` / `card_type` / `sort_order`），
/// 与后端 JSON 契约一致。用注解而不是 `build.yaml`：改动就地可见，
/// 不影响仓库其它生成任务。
@freezed
abstract class Card with _$Card {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Card({
    required String id,
    required String deckId,
    @Default('memory') String cardType,
    required CardFields fields,
    @Default(0) int sortOrder,
  }) = _Card;

  factory Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);
}
