import 'package:material_ui/material_ui.dart' hide Card;

import '../../core/l10n/app_strings.dart';
import '../../features/cards/domain/card.dart';
import '../../features/cards/presentation/widgets/demo_card_images.dart';

// 卡片内容的可复用展示块，给「卡片页」和「复习页翻转出的卡片正文」共用。
// 放在 shared/ 是因为它被两个 feature 的 presentation 同时使用，
// 且只做展示、不碰 Riverpod/仓储（docs/05 §1）。

/// 卡片页大图的最大高度。
///
/// 竖版图按原比例铺满正文宽度后会很高（奶蛙 614×859 在 328 宽下约 459 高），
/// 会把名字和定义顶到屏幕外；封顶后图片仍然完整（`BoxFit.contain` + `AspectRatio`）。
const double kCardImageMaxHeight = 380;

/// 卡片配图：本地演示资源优先，没有对应资源时显示占位。
///
/// 图片必须**完整呈现**，任何形式都不裁切：
/// - 传了 [width] / [height]（复习页正文里的小方图）：框固定，图用 `BoxFit.contain` 整张缩进框内；
/// - 不传宽高、传了 [aspectRatio]（卡片页大图）：按原图宽高比留框（`AspectRatio`），
///   高度封顶 [kCardImageMaxHeight]，图用 `contain`，整张图都在、也不裁边；
///   比例来自 [demoCardImageAspectFor]，接后端后改用 `fields.images` 里的 `width / height`；
/// - 什么都不传：退化成 200 高的框，同样 `contain`。
///
/// 后端接入后：把 [demoCardImageFor] 换成 `fields.images` 里的签名 URL
/// （`Image.network`），这里的调用方不用改。
class CardImageBox extends StatelessWidget {
  const CardImageBox({
    super.key,
    required this.cardName,
    this.width,
    this.height,
    this.aspectRatio,
    this.borderRadius = 16,
  });

  final String cardName;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final double borderRadius;

  bool get _fixedBox => width != null || height != null;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? asset = demoCardImageFor(cardName);
    if (asset == null) {
      return _placeholder(theme);
    }
    final Widget image = Image.asset(
      asset,
      width: _fixedBox ? width : null,
      height: _fixedBox ? height : null,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) => _placeholder(theme),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: _fixedBox ? image : _aspectFrame(image),
    );
  }

  /// 无固定尺寸时：按 [aspectRatio] 留框，高度上限 [kCardImageMaxHeight]
  /// （竖图按比例铺满宽度后会很高，封顶免得把正文顶出屏幕）；没有比例就固定 200 高。
  Widget _aspectFrame(Widget image) {
    final double? ratio = aspectRatio;
    if (ratio == null || ratio <= 0) {
      return SizedBox(height: 200, width: double.infinity, child: image);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: kCardImageMaxHeight),
      child: Center(
        child: AspectRatio(aspectRatio: ratio, child: image),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    final Widget box = Container(
      width: _fixedBox ? width : null,
      height: _fixedBox ? height : null,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.image_outlined,
            size: (height ?? 96) < 140 ? 28 : 36,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.cardImageEmpty,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
    return _fixedBox ? box : _aspectFrame(box);
  }
}

/// 「提示：xxx」这样的一行。
class LabelledLine extends StatelessWidget {
  const LabelledLine({super.key, required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// Tips 区：提示与备注归到这一块，**默认折叠**，点标题展开。
class TipsSection extends StatefulWidget {
  const TipsSection({super.key, required this.hint, required this.extra});

  final String? hint;
  final String? extra;

  @override
  State<TipsSection> createState() => _TipsSectionState();
}

class _TipsSectionState extends State<TipsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? hint = widget.hint;
    final String? extra = widget.extra;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        InkWell(
          key: const ValueKey<String>('card_tips_header'),
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: <Widget>[
                Text(
                  AppStrings.cardTipsTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            key: const ValueKey<String>('card_tips_body'),
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (hint != null && hint.isNotEmpty)
                  LabelledLine(
                    key: const ValueKey<String>('card_detail_hint'),
                    label: AppStrings.cardHintLabel,
                    text: hint,
                  ),
                if (extra != null && extra.isNotEmpty) ...<Widget>[
                  if (hint != null && hint.isNotEmpty) const SizedBox(height: 8),
                  LabelledLine(
                    key: const ValueKey<String>('card_detail_extra'),
                    label: AppStrings.cardExtraLabel,
                    text: extra,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Agent 区占位：接后端后换成流式回答。
class AgentSection extends StatelessWidget {
  const AgentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      key: const ValueKey<String>('card_agent_section'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(AppStrings.cardAgentTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            AppStrings.cardAgentHint,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

/// 底部输入区占位（选项 / 回答 / 提问）。
class InputPlaceholder extends StatelessWidget {
  const InputPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      key: const ValueKey<String>('card_input_section'),
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        AppStrings.cardInputHint,
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
      ),
    );
  }
}

/// 卡片正文（线框图形状）：名字 → 左小图 + 右暗文 → Tips → Agent → 输入占位。
///
/// 「卡片页」和「复习页翻转出来的卡片正文」都用它，保证两处长得一样。
class CardDetailBody extends StatelessWidget {
  const CardDetailBody({super.key, required this.card});

  final Card card;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CardFields fields = card.fields;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          fields.plaintext,
          key: const ValueKey<String>('card_detail_name'),
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CardImageBox(cardName: fields.plaintext, width: 96, height: 96),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fields.ciphertext,
                key: const ValueKey<String>('card_detail_definition'),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ),
          ],
        ),
        if ((fields.hint != null && fields.hint!.isNotEmpty) ||
            (fields.extra != null && fields.extra!.isNotEmpty)) ...<Widget>[
          const SizedBox(height: 20),
          const Divider(height: 1),
          TipsSection(hint: fields.hint, extra: fields.extra),
        ],
        const SizedBox(height: 20),
        const AgentSection(),
        const SizedBox(height: 16),
        const InputPlaceholder(),
      ],
    );
  }
}
