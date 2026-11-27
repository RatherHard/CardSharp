import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/domain/auth_state.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/theme_controller.dart';

/// 设置页：账号、外观、关于。
///
/// 本期只有本地测试账号，所以账号区只展示「谁登录了」与退出入口；
/// 资料修改、多设备管理、通知设置都等后端 `/auth/*` 与推送契约就绪后再做。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AuthState? auth = ref.watch(authControllerProvider).value;
    final bool loggedIn = auth is AuthAuthenticated;
    final String username = loggedIn ? auth.user.username : AppStrings.drawerGuestName;
    final ThemeMode mode = ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          const _SectionTitle(AppStrings.settingsAccountTitle),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        key: const ValueKey<String>('settings_avatar'),
                        radius: 24,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.person_outline,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              username,
                              key: const ValueKey<String>('settings_username'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              key: const ValueKey<String>('settings_account_tag'),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                AppStrings.settingsLocalAccountTag,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      key: const ValueKey<String>('settings_sign_out_button'),
                      onPressed: loggedIn
                          ? () => ref.read(authControllerProvider.notifier).signOut()
                          : null,
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text(AppStrings.drawerSignOut),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _SectionTitle(AppStrings.settingsAppearanceTitle),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SegmentedButton<ThemeMode>(
                    key: const ValueKey<String>('settings_theme_segmented'),
                    segments: const <ButtonSegment<ThemeMode>>[
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: Text(AppStrings.settingsThemeSystem),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text(AppStrings.settingsThemeLight),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text(AppStrings.settingsThemeDark),
                      ),
                    ],
                    selected: <ThemeMode>{mode},
                    showSelectedIcon: false,
                    onSelectionChanged: (Set<ThemeMode> selection) =>
                        ref.read(themeModeControllerProvider.notifier).select(selection.first),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.settingsAppearanceHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _SectionTitle(AppStrings.settingsAboutTitle),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              key: const ValueKey<String>('settings_version_tile'),
              title: const Text(AppStrings.settingsVersionLabel),
              trailing: Text(AppStrings.appVersion, style: theme.textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}
