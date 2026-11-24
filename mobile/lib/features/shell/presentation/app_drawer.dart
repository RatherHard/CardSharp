import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/domain/auth_state.dart';
import '../../../core/l10n/app_strings.dart';

/// 侧栏：头像 + 用户名 + 设置 + 退出登录。
///
/// 宽度固定为屏宽的 1/3（人类确认）；窄屏手机上内容区只有 ~92dp，
/// 因此按可用宽度分档缩小图标与字号，否则用户名和「退出登录」会被挤没。
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AuthState? auth = ref.watch(authControllerProvider).value;
    final bool loggedIn = auth is AuthAuthenticated;
    final String? username = loggedIn ? auth.user.username : null;

    return Drawer(
      key: const ValueKey<String>('app_drawer'),
      width: MediaQuery.sizeOf(context).width / 3,
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool narrow = constraints.maxWidth < 160;
            final double avatarRadius = narrow ? 20 : 28;
            final double iconSize = narrow ? 24 : 32;
            final TextStyle? nameStyle = narrow
                ? theme.textTheme.titleMedium
                : theme.textTheme.titleLarge;
            final TextStyle? itemStyle = narrow
                ? theme.textTheme.bodyMedium
                : theme.textTheme.titleMedium;

            return Padding(
              padding: narrow
                  ? const EdgeInsets.fromLTRB(10, 20, 8, 10)
                  : const EdgeInsets.fromLTRB(16, 28, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        key: const ValueKey<String>('drawer_avatar'),
                        radius: avatarRadius,
                        backgroundColor: scheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.person_outline,
                          size: iconSize,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: narrow ? 8 : 14),
                      Expanded(
                        child: GestureDetector(
                          key: const ValueKey<String>('drawer_user_name'),
                          onTap: loggedIn ? null : () => context.go('/login'),
                          child: Text(
                            username ?? AppStrings.drawerGuestName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: nameStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: narrow ? 14 : 18),
                  _DrawerItem(
                    itemKey: const ValueKey<String>('drawer_settings_button'),
                    icon: Icons.settings_outlined,
                    label: AppStrings.settings,
                    style: itemStyle,
                    iconSize: narrow ? 20 : 24,
                    gap: narrow ? 8 : 10,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/settings');
                    },
                  ),
                  SizedBox(height: narrow ? 4 : 6),
                  if (loggedIn)
                    _DrawerItem(
                      itemKey: const ValueKey<String>('drawer_sign_out_button'),
                      icon: Icons.logout,
                      label: AppStrings.drawerSignOut,
                      style: itemStyle,
                      iconSize: narrow ? 20 : 24,
                      gap: narrow ? 8 : 10,
                      onTap: () {
                        Navigator.of(context).pop();
                        ref.read(authControllerProvider.notifier).signOut();
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.itemKey,
    required this.icon,
    required this.label,
    required this.style,
    required this.iconSize,
    required this.gap,
    required this.onTap,
  });

  final Key itemKey;
  final IconData icon;
  final String label;
  final TextStyle? style;
  final double iconSize;
  final double gap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: itemKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: <Widget>[
            Icon(icon, size: iconSize),
            SizedBox(width: gap),
            Expanded(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
            ),
          ],
        ),
      ),
    );
  }
}
