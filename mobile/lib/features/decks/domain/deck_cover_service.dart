/// 卡片集自定义封面（本地图片）的读写端口。
///
/// 为什么需要这一层：后端 `decks` 契约里没有封面图字段（只有 `color`），
/// 而产品要求「能选本地图片当封面」，所以这一版先把封面存在**本机**：
/// 图片复制进应用私有目录，路径记在本地偏好里，按卡片集 id 关联。
///
/// 接后端后的演进：后端提供封面（URL / 对象存储 key）时，新增
/// `HttpDeckCoverService` 或在 `PATCH /decks/{id}` 里带上 `cover` 字段，
/// 页面与封面组件不需要改——它们只认「拿到一个路径或 null」。
abstract interface class DeckCoverService {
  /// 读某个卡片集的自定义封面路径；没有或文件已丢失时返回 null。
  Future<String?> readCoverPath(String deckId);

  /// 让用户挑一张本地图片并保存为该卡片集的封面。
  ///
  /// 返回保存后的本地路径；用户取消或读取失败时返回 null（此时不改动原封面）。
  Future<String?> pickAndSaveCover(String deckId);

  /// 移除自定义封面（删除本地副本并清除记录）。没有封面时是空操作。
  Future<void> removeCover(String deckId);
}
