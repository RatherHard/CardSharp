import 'package:material_ui/material_ui.dart';

import '../../domain/search_hit.dart';

/// 把 [text] 中 [ranges] 命中的片段渲染成高亮样式，其余保持 [style]。
///
/// 只负责渲染：不计算命中位置（那是 `SearchService.findAll` 的职责），
/// 也不关心中文/英文差异。
class HighlightedText extends StatelessWidget {
  const HighlightedText({
    required this.text,
    required this.ranges,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    super.key,
  });

  final String text;
  final List<MatchRange> ranges;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle base = style ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final TextStyle highlight =
        highlightStyle ??
        base.copyWith(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.18),
          fontWeight: FontWeight.w600,
        );

    return Text.rich(
      TextSpan(children: _buildSpans(base, highlight)),
      style: base,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  List<InlineSpan> _buildSpans(TextStyle base, TextStyle highlight) {
    final List<MatchRange> valid = _normalize(ranges);
    if (valid.isEmpty) {
      return <InlineSpan>[TextSpan(text: text, style: base)];
    }

    final List<InlineSpan> spans = <InlineSpan>[];
    int cursor = 0;
    for (final MatchRange range in valid) {
      if (range.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, range.start), style: base));
      }
      spans.add(TextSpan(text: text.substring(range.start, range.end), style: highlight));
      cursor = range.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: base));
    }
    return spans;
  }

  /// 排序、去重叠、裁掉越界区间。越界可能来自上游数据变化，这里兜住不崩。
  List<MatchRange> _normalize(List<MatchRange> input) {
    final List<MatchRange> sorted =
        input
            .where((MatchRange r) => r.start >= 0 && r.end <= text.length && r.start < r.end)
            .toList()
          ..sort((MatchRange a, MatchRange b) => a.start.compareTo(b.start));

    final List<MatchRange> merged = <MatchRange>[];
    for (final MatchRange range in sorted) {
      if (merged.isEmpty) {
        merged.add(range);
        continue;
      }
      final MatchRange last = merged.last;
      if (range.start <= last.end) {
        if (range.end > last.end) {
          merged[merged.length - 1] = MatchRange(start: last.start, end: range.end);
        }
      } else {
        merged.add(range);
      }
    }
    return merged;
  }
}
