import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/app_strings.dart';

/// 卡片集封面占位：四张白卡以右下角为轴均匀错开叠成一摞。
///
/// 角度与叠放方式来自设计稿 `docs/卡片页面.png`（三张手绘方框），
/// 这里改成四张、角度均分并在最上面一张加一点向下位移，
/// 让「一摞卡」在任何尺寸下都能完整露出，不被裁切。
class DeckCover extends StatelessWidget {
  const DeckCover({super.key});

  /// 从后到前：越靠后的卡角度越负，最上面一张保持 0°。
  static const List<double> _anglesDeg = <double>[-15, -10, -5, 0];

  /// 封面四周留白，避免旋转后顶到边界被裁。
  static const double _margin = 8;

  /// 相邻两张卡沿垂直方向的错开量（相对边长）。
  static const double _stepFactor = 0.05;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final outline = scheme.onSurface.withValues(alpha: 0.22);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        if (!width.isFinite || !height.isFinite) {
          return const SizedBox.shrink();
        }

        final double maxAngle = _anglesDeg.first.abs() * math.pi / 180;
        // 旋转后的包围盒相对边长的放大系数。
        final double rotationFactor = math.cos(maxAngle) + math.sin(maxAngle);
        final double verticalSpan = rotationFactor + (_anglesDeg.length - 1) * _stepFactor;
        final double side = math.min(
          (width - _margin * 2) / rotationFactor,
          (height - _margin * 2) / verticalSpan,
        );
        final double step = side * _stepFactor;
        final double upward = math.cos(maxAngle) * side + (_anglesDeg.length - 1) * step;
        final double downward = math.sin(maxAngle) * side;
        final double pivotX = width / 2 + rotationFactor * side / 2;
        final double pivotY = height / 2 + (upward - downward) / 2;
        final double radius = side * 0.09;

        return Stack(
          children: <Widget>[
            for (int i = 0; i < _anglesDeg.length; i++)
              Positioned(
                left: pivotX - side,
                top: pivotY - side - (_anglesDeg.length - 1 - i) * step,
                width: side,
                height: side,
                child: Transform.rotate(
                  angle: _anglesDeg[i] * math.pi / 180,
                  alignment: Alignment.bottomRight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(radius),
                      border: Border.all(color: outline),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: scheme.shadow.withValues(alpha: 0.13),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: Center(
                child: Text(
                  AppStrings.deckCoverPlaceholder,
                  style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 书架里的一张卡片集：封面 + 名称 + 卡片数。
class DeckTile extends ConsumerWidget {
  const DeckTile({
    required this.deckId,
    required this.title,
    required this.cardCount,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final String deckId;
  final String title;
  final int cardCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      key: ValueKey<String>('deck_tile_$deckId'),
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Expanded(child: DeckCover()),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
          Text(
            AppStrings.deckCardCount(cardCount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
