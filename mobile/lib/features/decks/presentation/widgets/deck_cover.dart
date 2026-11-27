import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../application/deck_cover_providers.dart';
import 'demo_deck_covers.dart';

/// 把 `#RRGGBB` / `#AARRGGBB` 解析成颜色；空串或格式不合法返回 null。
///
/// 放在封面组件旁边，书架、详情页、搜索结果都从这里取，避免各写一份解析。
Color? deckTint(String? hex) {
  if (hex == null) {
    return null;
  }
  final String value = hex.trim().replaceFirst('#', '');
  if (value.length != 6 && value.length != 8) {
    return null;
  }
  final int? parsed = int.tryParse(value, radix: 16);
  if (parsed == null) {
    return null;
  }
  return Color(value.length == 6 ? 0xFF000000 | parsed : parsed);
}

/// 卡片集封面：默认是四张白卡以右下角为轴均匀错开叠成一摞；
/// 传了 `coverAsset` 时，最上面那张卡换成图片（其余三张仍是白卡）。
///
/// 角度与叠放方式来自设计稿 `docs/卡片页面.png`（三张手绘方框），
/// 这里改成四张、角度均分并在最上面一张加一点向下位移，
/// 让「一摞卡」在任何尺寸下都能完整露出，不被裁切。
class DeckCover extends StatelessWidget {
  const DeckCover({this.tint, this.coverAsset, this.coverFilePath, super.key});

  /// 封面色（来自 `Deck.color`）。为 null 时用主题的 surface 色，即原样白卡。
  /// 这里只做低透明度着色，避免整块纯色盖掉「一摞纸」的层次。
  final Color? tint;

  /// 封面图片的 assets 路径；null 表示用白色卡堆占位。
  ///
  /// 只在演示场景用（见 `demo_deck_covers.dart`）：后端契约没有封面图字段。
  final String? coverAsset;

  /// 用户自选封面图片在本机的绝对路径；优先级高于 [coverAsset]。
  ///
  /// 由 `deckCoverPathProvider` 提供，存的是应用私有目录里的副本
  /// （系统选择器给的临时授权重启后会失效，所以要复制，见 `FileDeckCoverService`）。
  final String? coverFilePath;

  /// 从后到前：越靠后的卡角度越负，最上面一张保持 0°。
  ///
  /// 角度与错开量都调小了：盒子尺寸不变的前提下，旋转包围盒越小，
  /// 每张卡就能占满更多空间，小尺寸（搜索结果的 48px）才看得清。
  static const List<double> _anglesDeg = <double>[-9, -6, -3, 0];

  /// 封面四周留白，避免旋转后顶到边界被裁。
  static const double _margin = 2;

  /// 相邻两张卡沿垂直方向的错开量（相对边长）。
  static const double _stepFactor = 0.035;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final outline = scheme.onSurface.withValues(alpha: 0.22);

    // 正面：淡着色（保留图片/白卡层次）；背面几张：同色系但更深一点，
    // 这样「一摞卡」露出的部分与封面颜色相近而不同，不会糊成一片。
    final Color frontColor = tint == null
        ? scheme.surface
        : Color.alphaBlend(tint!.withValues(alpha: 0.14), scheme.surface);
    final Color backColor = tint == null
        ? scheme.surfaceContainerHighest
        : Color.alphaBlend(tint!.withValues(alpha: 0.34), scheme.surface);

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
                      color: i == _anglesDeg.length - 1 ? frontColor : backColor,
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
                    // 只有最上面一张（角度 0°）承载封面图；背面三张保持白卡，
                    // 这样既能看到「一摞卡」的层次，图片也不会被旋转裁掉。
                    child: i == _anglesDeg.length - 1 ? _frontImage(radius) : null,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// 最上面那张卡的内容：优先用户自选图片，其次内置演示图，都没有就是白卡。
  ///
  /// 用 `BoxFit.contain`：用户选的图任意长宽比都完整显示，不裁切（2026-11-26 按要求改）。
  ///
  /// 图片读不出来（文件被删、格式损坏）时不抛给框架，直接退回白卡：
  /// 封面只是装饰，不该因为它把整个书架/详情页刷成错误块。
  Widget? _frontImage(double radius) {
    final String? filePath = coverFilePath;
    if (filePath != null && filePath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.file(File(filePath), fit: BoxFit.contain, errorBuilder: _onImageError),
      );
    }
    final String? assetPath = coverAsset;
    if (assetPath != null && assetPath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(assetPath, fit: BoxFit.contain, errorBuilder: _onImageError),
      );
    }
    return null;
  }

  Widget _onImageError(BuildContext context, Object error, StackTrace? stackTrace) {
    return const SizedBox.expand();
  }
}

/// 书架里的一张卡片集：封面 + 名称 + 卡片数。
class DeckTile extends ConsumerWidget {
  const DeckTile({
    required this.deckId,
    required this.title,
    required this.cardCount,
    required this.color,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final String deckId;
  final String title;
  final int cardCount;

  /// 卡片集颜色（`Deck.color`），用于封面与背后几张卡片的着色。
  final String color;
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
          Expanded(
            child: DeckCover(
              tint: deckTint(color),
              coverAsset: demoCoverFor(title),
              coverFilePath: ref.watch(deckCoverPathProvider(deckId)).value,
            ),
          ),
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
