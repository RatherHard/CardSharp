import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 读取用户选择的 JSON 文本。
///
/// 抽成接口是为了：1) 测试时注入假实现；2) 将来换别的读取方式只改实现。
abstract interface class ImportFilePicker {
  /// 返回文件内容；用户取消选择或读取失败时返回 null。
  Future<String?> pickJsonText();
}

/// 系统文件选择器实现（Android 走 Storage Access Framework）。
///
/// 用 SAF 的好处：用户选哪个文件才授权哪个文件，**不需要申请存储权限**。
class SystemImportFilePicker implements ImportFilePicker {
  const SystemImportFilePicker();

  static const XTypeGroup _jsonGroup = XTypeGroup(label: 'JSON', extensions: <String>['json']);

  @override
  Future<String?> pickJsonText() async {
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[_jsonGroup]);
    if (file == null) {
      return null;
    }
    return file.readAsString();
  }
}

final Provider<ImportFilePicker> importFilePickerProvider = Provider<ImportFilePicker>(
  (Ref ref) => const SystemImportFilePicker(),
);
