import 'package:freezed_annotation/freezed_annotation.dart';

part 'deck.freezed.dart';
part 'deck.g.dart';

/// 卡片集在客户端的投影，字段对齐 `docs/03` §4.2 的 `decks` 表。
///
/// 序列化键名统一转成下划线，与后端 JSON 契约一致。
@freezed
abstract class Deck with _$Deck {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Deck({
    required String id,
    required String title,
    @Default('') String description,

    /// 封面色，形如 `#RRGGBB`；空串表示用主题默认色。
    /// 对应后端 `decks.color`（`docs/03` §4.2）——后端只有颜色，没有封面图片。
    @Default('') String color,

    /// 卡片类型，默认 `memory`（`docs/02` FR-2.2）。后续会有选择题等类型。
    @Default('memory') String cardType,

    /// 所属文件夹 id；null 表示未归类（`docs/02` FR-2.1）。
    String? folderId,

    /// 卡片集配置，对应后端 `decks.config`（jsonb）。
    /// 内部结构由后端定义（`docs/03` §4.3），客户端原样透传、不解析。
    @Default(<String, dynamic>{}) Map<String, dynamic> config,

    /// 后端 `decks.stats`（jsonb）。文档只说明是「冗余统计，异步更新」，
    /// 未定义内部字段名，因此原样保留，等后端给出字段后再拆成结构化对象。
    @Default(<String, dynamic>{}) Map<String, dynamic> stats,

    /// 卡片数，仅用于界面展示。
    ///
    /// **不参与序列化**：它必须由后端 `stats` 提供，客户端不能自己算，
    /// 更不能把它发回服务端覆盖统计值。接后端后由 `stats` 映射填充。
    @JsonKey(includeFromJson: false, includeToJson: false) @Default(0) int cardCount,
  }) = _Deck;

  factory Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);
}
