/// 一页数据，对应后端列表接口的返回格式（`docs/03` §6）：
///
/// ```json
/// { "items": [...], "next_cursor": "..." }
/// ```
///
/// `nextCursor` 是后端给的**不透明**游标（表示「上次读到哪」），
/// 客户端只负责原样回传，**不得解析其内容**——解析了就等于假设了后端的实现细节。
class PagedResult<T> {
  const PagedResult({required this.items, this.nextCursor});

  final List<T> items;

  /// 下一页的游标；`null` 表示已经到最后一页。
  final String? nextCursor;

  bool get hasMore => nextCursor != null;

  static PagedResult<T> single<T>(List<T> items) => PagedResult<T>(items: items);
}
