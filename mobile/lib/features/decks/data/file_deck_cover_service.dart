import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/l10n/app_strings.dart';

import '../domain/deck_cover_service.dart';

/// 本地文件实现：图片复制进应用私有目录，路径按卡片集 id 记在偏好里。
///
/// 几个刻意的选择：
/// * **复制而不是记住原路径**：系统文件选择器（Android SAF）给的是临时授权，
///   重启后可能失效；复制进 `getApplicationSupportDirectory()` 才稳定。
/// * **文件名带卡片集 id + 时间戳**：Flutter 的 `ImageCache` 以图片路径为键，
///   覆盖同名文件不会刷新画面；路径每次换图都变，旧文件由本类删掉。
/// * **文件丢了就当没有封面**：用户清缓存后偏好里可能残留死路径，读取时校验并自愈。
class FileDeckCoverService implements DeckCoverService {
  FileDeckCoverService({
    Future<Directory> Function()? directoryProvider,
    Future<String?> Function()? pickImagePath,
  }) : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory,
       _pickImagePath = pickImagePath ?? _pickWithSystemPicker;

  /// 偏好键前缀：`deck_cover.<deckId>` → 本地图片绝对路径。
  static const String _prefsPrefix = 'deck_cover.';

  static const XTypeGroup _imageGroup = XTypeGroup(
    label: AppStrings.imageFileTypeGroupLabel,
    extensions: <String>['png', 'jpg', 'jpeg', 'webp'],
  );

  /// 允许接受的图片扩展名；其余一律按 png 存（解码交给 Flutter）。
  static const Set<String> _allowedExtensions = <String>{'.png', '.jpg', '.jpeg', '.webp'};

  final Future<Directory> Function() _directoryProvider;
  final Future<String?> Function() _pickImagePath;

  static Future<String?> _pickWithSystemPicker() async {
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[_imageGroup]);
    return file?.path;
  }

  String _key(String deckId) => '$_prefsPrefix$deckId';

  Future<Directory> _coversDirectory() async {
    final Directory base = await _directoryProvider();
    final Directory directory = Directory('${base.path}${Platform.pathSeparator}deck_covers');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  @override
  Future<String?> readCoverPath(String deckId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? path = prefs.getString(_key(deckId));
    if (path == null) {
      return null;
    }
    if (!await File(path).exists()) {
      // 文件被系统清掉了：把死路径删掉，避免一直读到不存在的图。
      await prefs.remove(_key(deckId));
      return null;
    }
    return path;
  }

  @override
  Future<String?> pickAndSaveCover(String deckId) async {
    final String? picked = await _pickImagePath();
    if (picked == null) {
      return null;
    }
    final File source = File(picked);
    if (!await source.exists()) {
      return null;
    }

    final Directory directory = await _coversDirectory();
    final String extension = _extensionOf(picked);
    // 路径必须每次都变：`Image.file` 的缓存键是路径，覆盖同名文件后界面仍显示旧图。
    final String stamp = DateTime.now().microsecondsSinceEpoch.toString();
    final String separator = Platform.pathSeparator;
    final File target = File('${directory.path}$separator$deckId-$stamp$extension');
    await source.copy(target.path);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // 换封面：旧文件删掉，避免越攒越多。
    final String? previous = prefs.getString(_key(deckId));
    if (previous != null && previous != target.path) {
      final File old = File(previous);
      if (await old.exists()) {
        await old.delete();
      }
    }
    await prefs.setString(_key(deckId), target.path);
    return target.path;
  }

  @override
  Future<void> removeCover(String deckId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? path = prefs.getString(_key(deckId));
    if (path != null) {
      final File file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await prefs.remove(_key(deckId));
  }

  /// 取小写扩展名；不认识的一律按 `.png` 存。
  static String _extensionOf(String path) {
    final int dot = path.lastIndexOf('.');
    final String extension = dot < 0 ? '' : path.substring(dot).toLowerCase();
    return _allowedExtensions.contains(extension) ? extension : '.png';
  }
}
