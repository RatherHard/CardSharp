import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' hide Card;

import '../../../core/l10n/app_strings.dart';
import '../../../shared/card_widgets/card_detail_body.dart';
import '../application/card_providers.dart';
import '../domain/card.dart';
import 'widgets/demo_card_images.dart';

/// 卡片页（直接点卡片进来）：大图 → 名字 → 「定义」+ 暗文 → Tips（默认折叠）。
///
/// 复习流程里的「查看本卡片」不再跳到这里，而是在复习页内翻出卡片正文
/// （同一个 [CardDetailBody]，见 `review_page.dart`），所以本页只有一种布局。
///
/// 不显示问题——问答正/背面只在复习页（`/deck/:id/review`）。
///
/// 数据来自 [cardByIdProvider]：路由只带 id，页面自己取数据，
/// 这样卡片被删/失效时能显示「卡片不存在」，而不是崩溃。
class CardPage extends ConsumerWidget {
  const CardPage({super.key, required this.deckId, required this.cardId});

  final String deckId;
  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CardRef arg = (deckId: deckId, cardId: cardId);
    final AsyncValue<Card?> cardAsync = ref.watch(cardByIdProvider(arg));
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.cardPageTitle)),
      body: switch (cardAsync) {
        AsyncData<Card?>(:final Card? value) =>
          value == null
              ? const _CardMessage(text: AppStrings.cardNotFound)
              : _CardBrowseView(card: value),
        AsyncError<Card?>() => _CardMessage(
          text: AppStrings.cardLoadFailed,
          onRetry: () => ref.invalidate(cardByIdProvider(arg)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// 浏览版：大图 → 名字 → 「定义」+ 暗文 → Tips。
class _CardBrowseView extends StatelessWidget {
  const _CardBrowseView({required this.card});

  final Card card;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CardFields fields = card.fields;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: <Widget>[
        KeyedSubtree(
          key: const ValueKey<String>('card_detail_image'),
          // 按原图宽高比留框、图用 contain：铺满正文宽度且整张图都在（不裁切）
          child: CardImageBox(
            cardName: fields.plaintext,
            aspectRatio: demoCardImageAspectFor(fields.plaintext) ?? _aspectFromImages(fields),
            borderRadius: 20,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          fields.plaintext,
          key: const ValueKey<String>('card_detail_name'),
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.cardDefinitionLabel,
          style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        Text(
          fields.ciphertext,
          key: const ValueKey<String>('card_detail_definition'),
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        if ((fields.hint != null && fields.hint!.isNotEmpty) ||
            (fields.extra != null && fields.extra!.isNotEmpty)) ...<Widget>[
          const SizedBox(height: 20),
          const Divider(height: 1),
          TipsSection(hint: fields.hint, extra: fields.extra),
        ],
      ],
    );
  }
}

/// 从契约里的 `fields.images` 取第一张的宽高比（宽 / 高）；没有就返回 null。
///
/// 后端接入后图片走 `fields.images.first.key` 的签名 URL，这里正好复用它的
/// `width` / `height` 留展示框，保证图片完整显示（docs/03 §4.4）。
double? _aspectFromImages(CardFields fields) {
  for (final CardImage image in fields.images) {
    final int? width = image.width;
    final int? height = image.height;
    if (width != null && height != null && width > 0 && height > 0) {
      return width / height;
    }
  }
  return null;
}

/// 两种简单状态：卡片不存在、加载失败（可重试）。
class _CardMessage extends StatelessWidget {
  const _CardMessage({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(text, style: theme.textTheme.titleSmall),
          if (onRetry != null) ...<Widget>[
            const SizedBox(height: 12),
            FilledButton.tonal(
              key: const ValueKey<String>('card_retry'),
              onPressed: onRetry,
              child: const Text(AppStrings.cardRetry),
            ),
          ],
        ],
      ),
    );
  }
}
