import 'package:file_selector/file_selector.dart';

import '../domain/import_file_picker.dart';

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
