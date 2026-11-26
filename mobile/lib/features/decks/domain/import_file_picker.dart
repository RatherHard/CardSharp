/// 读取用户选择的 JSON 文本的端口。
///
/// 抽成接口是为了：1) 测试时注入假实现；2) 将来换别的读取方式（Http、剪贴板）
/// 只改 `data/` 下的实现，`application/` 与页面不动。
abstract interface class ImportFilePicker {
  /// 返回文件内容；用户取消选择或读取失败时返回 null。
  Future<String?> pickJsonText();
}
