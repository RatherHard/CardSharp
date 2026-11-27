import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/search_limits.dart';

part 'search_query.freezed.dart';

/// 搜索输入状态：关键词 + 当前要展示的条数上限。
///
/// 搜索不再分模式（`card_type` 那样的「卡片集 / 全部卡片」切换已去掉）：
/// 每次搜索都是全量搜索，结果按层级分档展示（同级 → 下级 → 上级），
/// 所以这里只需要关键词和上限。
@freezed
abstract class SearchQuery with _$SearchQuery {
  const factory SearchQuery({@Default('') String keyword, @Default(kSearchHitLimit) int hitLimit}) =
      _SearchQuery;

  const SearchQuery._();

  /// 只有空白的关键词不算在搜索。
  bool get isActive => keyword.trim().isNotEmpty;
}
