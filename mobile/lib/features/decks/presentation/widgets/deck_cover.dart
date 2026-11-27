import 'dart:io';

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

/// 卡片集封面：一张平放的圆角卡，颜色来自 `Deck.color`；
/// 传了封面图片（`coverAsset` / `coverFilePath`）时按 `contain` 完整显示，不裁切。
///
/// 2026-11-28 去 AI 味（DESIGN.md「卡片放平，一层就够」）：原来的
/// 「四张白卡旋转叠成一摞 + 阴影 + 旋转包围盒计算」拿掉，只保留一张卡。
class DeckCover extends StatelessWidget {
  const DeckCover({this.tint, this.coverAsset, this.coverFilePath, super.key});

  /// 封面色（来自 `Deck.color`）。为 null 时用主题的 surface 色，即原样白卡。
  final Color? tint;

  /// 封面图片的 assets 路径；null 表示只有色块。
  ///
  /// 只在演示场景用（见 `demo_deck_covers.dart`）：后端契约没有封面图字段。
  final String? coverAsset;

  /// 用户自选封面图片在本机的绝对路径；优先级高于 [coverAsset]。
  ///
  /// 由 `deckCoverPathProvider` 提供，存的是应用私有目录里的副本
  /// （系统选择器给的临时授权重启后会失效，所以要复制，见 `FileDeckCoverService`）。
  final String? coverFilePath;

  /// 封面卡圆角（DESIGN.md 的「容器」档）。
  ///
  /// 小尺寸封面（搜索结果 48、回收站 56/64）按短边的 18% 收窄并夹在 8–16 之间，
  /// 否则 16 的圆角放在 48px 缩略图上会显得过圆。
  static const double _maxRadius = 16;
  static const double _minRadius = 8;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color frontColor = tint == null
        ? scheme.surface
        : Color.alphaBlend(tint!.withValues(alpha: 0.18), scheme.surface);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!constraints.maxWidth.isFinite || !constraints.maxHeight.isFinite) {
          return const SizedBox.shrink();
        }
        final double side = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final double radius = (side * 0.18).clamp(_minRadius, _maxRadius);
        return DecoratedBox(
          decoration: BoxDecoration(
            color: frontColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: scheme.onSurface.withValues(alpha: 0.22)),
          ),
          // 内圆角 = 外圆角 − 边框宽度（DESIGN.md「圆角嵌套」）。
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius - 1),
            child: _frontImage() ?? const SizedBox.expand(),
          ),
        );
      },
    );
  }

  /// 用 `BoxFit.contain`：用户选的图任意长宽比都完整显示，不裁切（2026-11-26 按要求改）。
  ///
  /// 图片读不出来（文件被删、格式损坏）时不抛给框架，直接退回纯色卡：
  /// 封面只是装饰，不该因为它把整个书架/详情页刷成错误块。
  Widget? _frontImage() {
    final String? filePath = coverFilePath;
    if (filePath != null && filePath.isNotEmpty) {
      return SizedBox.expand(
        child: Image.file(File(filePath), fit: BoxFit.contain, errorBuilder: _onImageError),
      );
    }
    final String? assetPath = coverAsset;
    if (assetPath != null && assetPath.isNotEmpty) {
      return SizedBox.expand(
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
