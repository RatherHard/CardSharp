import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' hide Card;

import '../../../core/l10n/app_strings.dart';
import '../../../shared/card_widgets/card_detail_body.dart';
import '../../cards/application/cards_controller.dart';
import '../../cards/domain/card.dart';

/// 复习卡片的三个面：问题 → 答案 → 卡片正文。
enum _ReviewFace { question, answer, card }

/// 复习页（「运行」按钮进入）。
///
/// 流程：顶部卡片进度条 → 中心显示问题 → 点「查看」翻面看答案 →
/// 底部出现「查看本卡片」和「下一个」；点「查看本卡片」**在页内翻到卡片正文**
/// （线框图那版：名字 + 左小图 + 右暗文 + Tips + Agent + 输入占位），
/// 「收起」翻回答案。最后一张看完给总结页。
///
/// 问题取 `fields.question`（本地演示字段），没有时回退到明文（卡片名）；
/// 答案取 `fields.ciphertext`。后端补 question 字段后只需改这里一处取值。
class ReviewPage extends ConsumerStatefulWidget {
  const ReviewPage({super.key, required this.deckId});

  final String deckId;

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage> {
  int _index = 0;
  _ReviewFace _face = _ReviewFace.question;
  bool _finished = false;

  void _restart() {
    setState(() {
      _index = 0;
      _face = _ReviewFace.question;
      _finished = false;
    });
  }

  void _next(int total) {
    if (_index + 1 >= total) {
      setState(() {
        _finished = true;
        _face = _ReviewFace.question;
      });
      return;
    }
    setState(() {
      _index += 1;
      _face = _ReviewFace.question;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Card>> cardsAsync = ref.watch(cardsForDeckProvider(widget.deckId));
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.reviewTitle)),
      body: switch (cardsAsync) {
        AsyncData<List<Card>>(:final List<Card> value) =>
          value.isEmpty
              ? const Center(child: Text(AppStrings.reviewEmpty))
              : _finished
              ? _DoneView(total: value.length, onRestart: _restart)
              : _ReviewBody(
                  card: value[_index],
                  index: _index,
                  total: value.length,
                  face: _face,
                  onShowAnswer: () => setState(() => _face = _ReviewFace.answer),
                  onOpenCard: () => setState(() => _face = _ReviewFace.card),
                  onHideCard: () => setState(() => _face = _ReviewFace.answer),
                  onNext: () => _next(value.length),
                ),
        AsyncError<List<Card>>() => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(AppStrings.cardLoadFailed),
              const SizedBox(height: 12),
              FilledButton.tonal(
                key: const ValueKey<String>('review_retry'),
                onPressed: () => ref.invalidate(cardsForDeckProvider(widget.deckId)),
                child: const Text(AppStrings.cardRetry),
              ),
            ],
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// 复习正文：进度条 + 会翻面的卡片（问题/答案/卡片正文）+ 底部按钮。
class _ReviewBody extends StatelessWidget {
  const _ReviewBody({
    required this.card,
    required this.index,
    required this.total,
    required this.face,
    required this.onShowAnswer,
    required this.onOpenCard,
    required this.onHideCard,
    required this.onNext,
  });

  final Card card;
  final int index;
  final int total;
  final _ReviewFace face;
  final VoidCallback onShowAnswer;
  final VoidCallback onOpenCard;
  final VoidCallback onHideCard;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isLast = index + 1 >= total;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  key: const ValueKey<String>('review_progress'),
                  value: (index + 1) / total,
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  AppStrings.reviewProgressText(index + 1, total),
                  key: const ValueKey<String>('review_progress_text'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: face == _ReviewFace.card
              ? SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: CardDetailBody(card: card),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: _FlipCard(card: card, face: face),
                  ),
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _buildActions(isLast),
          ),
        ),
      ],
    );
  }

  /// 三个面各自的底部按钮。
  Widget _buildActions(bool isLast) {
    final Widget nextButton = Expanded(
      child: SizedBox(
        height: 48,
        child: FilledButton(
          key: const ValueKey<String>('review_next'),
          onPressed: onNext,
          child: Text(isLast ? AppStrings.reviewFinish : AppStrings.reviewNext),
        ),
      ),
    );
    switch (face) {
      case _ReviewFace.question:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            key: const ValueKey<String>('review_show_answer'),
            onPressed: onShowAnswer,
            child: const Text(AppStrings.reviewShowAnswer),
          ),
        );
      case _ReviewFace.answer:
        return Row(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  key: const ValueKey<String>('review_open_card'),
                  onPressed: onOpenCard,
                  child: const Text(AppStrings.reviewOpenCard),
                ),
              ),
            ),
            const SizedBox(width: 12),
            nextButton,
          ],
        );
      case _ReviewFace.card:
        return Row(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  key: const ValueKey<String>('review_hide_card'),
                  onPressed: onHideCard,
                  child: const Text(AppStrings.reviewHideCard),
                ),
              ),
            ),
            const SizedBox(width: 12),
            nextButton,
          ],
        );
    }
  }
}

/// 会翻面的卡片：问题面、答案面沿 Y 轴翻转（卡片正文面见 [_ReviewBody]）。
class _FlipCard extends StatelessWidget {
  const _FlipCard({required this.card, required this.face});

  final Card card;
  final _ReviewFace face;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool answered = face == _ReviewFace.answer;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: _flipTransition,
      child: answered
          ? _CardFace(
              key: const ValueKey<String>('review_face_back'),
              label: AppStrings.reviewAnswerLabel,
              text: card.fields.ciphertext,
              textKey: 'review_answer',
              textStyle: theme.textTheme.titleMedium?.copyWith(height: 1.6),
            )
          : _CardFace(
              key: const ValueKey<String>('review_face_front'),
              label: AppStrings.reviewQuestionLabel,
              text: reviewQuestionOf(card),
              textKey: 'review_question',
              textStyle: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
    );
  }

  /// Y 轴翻转：进场时从 90° 转到 0°，视觉上像把卡片翻过来。
  static Widget _flipTransition(Widget child, Animation<double> animation) {
    final Animation<double> rotate = Tween<double>(begin: 0, end: 1).animate(animation);
    return AnimatedBuilder(
      animation: rotate,
      builder: (BuildContext context, Widget? built) {
        final double angle = (1 - rotate.value) * math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: built,
        );
      },
      child: child,
    );
  }
}

/// 复习时「问题」取哪个字段：优先 `fields.question`，没有就用明文（卡片名）。
///
/// `question` 是本地演示字段（见 `CardFields` 注释）；后端补字段后只改这里。
String reviewQuestionOf(Card card) {
  final String? question = card.fields.question;
  if (question != null && question.isNotEmpty) {
    return question;
  }
  return card.fields.plaintext;
}

/// 卡片的一面（标签 + 内容），正反面共用。
class _CardFace extends StatelessWidget {
  const _CardFace({
    super.key,
    required this.label,
    required this.text,
    required this.textKey,
    this.textStyle,
  });

  final String label;
  final String text;
  final String textKey;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Text(text, key: ValueKey<String>(textKey), textAlign: TextAlign.center, style: textStyle),
      ],
    );
  }
}

/// 复习完成页。
class _DoneView extends StatelessWidget {
  const _DoneView({required this.total, required this.onRestart});

  final int total;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.check_circle_outline, size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(AppStrings.reviewDoneTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            AppStrings.reviewDoneSummary(total),
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          FilledButton.tonal(
            key: const ValueKey<String>('review_restart'),
            onPressed: onRestart,
            child: const Text(AppStrings.reviewRestart),
          ),
        ],
      ),
    );
  }
}
