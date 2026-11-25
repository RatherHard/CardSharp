import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题偏好：跟随系统 / 浅色 / 深色。
///
/// 存 `shared_preferences` 而不是 secure storage：这是用户偏好，不是敏感信息。
/// 用 [AsyncNotifier] 是因为读偏好本身是异步 IO；页面读 `.value`，
/// 未加载完时退回跟随系统（与默认行为一致，不会闪一帧错误主题）。
class ThemeModeController extends AsyncNotifier<ThemeMode> {
  static const String _prefsKey = 'ui.themeMode';

  @override
  Future<ThemeMode> build() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return _decode(prefs.getString(_prefsKey));
  }

  Future<void> select(ThemeMode mode) async {
    state = AsyncData<ThemeMode>(mode);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _encode(mode));
  }

  static ThemeMode _decode(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static String _encode(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}

final themeModeControllerProvider = AsyncNotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
