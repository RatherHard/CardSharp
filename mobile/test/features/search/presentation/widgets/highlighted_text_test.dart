import 'package:cardsharp/features/search/domain/search_hit.dart';
import 'package:cardsharp/features/search/presentation/widgets/highlighted_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

/// 把 Text.rich 的 span 拍平成 (文本, 是否高亮) 列表，便于断言。
List<(String, bool)> _spans(WidgetTester tester) {
  final RichText rich = tester.widget<RichText>(find.byType(RichText).last);
  final List<(String, bool)> out = <(String, bool)>[];
  rich.text.visitChildren((InlineSpan span) {
    if (span is TextSpan && span.text != null) {
      out.add((span.text!, span.style?.fontWeight == FontWeight.w600));
    }
    return true;
  });
  return out;
}

void main() {
  testWidgets('命中片段被高亮，其余保持原样', (WidgetTester tester) async {
    await _pump(
      tester,
      const HighlightedText(text: '奶蛙家族图鉴', ranges: <MatchRange>[MatchRange(start: 0, end: 2)]),
    );

    expect(_spans(tester), <(String, bool)>[('奶蛙', true), ('家族图鉴', false)]);
  });

  testWidgets('多段命中分别高亮', (WidgetTester tester) async {
    await _pump(
      tester,
      const HighlightedText(
        text: '奶蛙和奶蛋',
        ranges: <MatchRange>[MatchRange(start: 0, end: 2), MatchRange(start: 3, end: 5)],
      ),
    );

    expect(_spans(tester), <(String, bool)>[('奶蛙', true), ('和', false), ('奶蛋', true)]);
  });

  testWidgets('没有命中时整段不高亮', (WidgetTester tester) async {
    await _pump(tester, const HighlightedText(text: '普通文本', ranges: <MatchRange>[]));

    expect(_spans(tester), <(String, bool)>[('普通文本', false)]);
  });

  testWidgets('越界区间被忽略，不崩溃', (WidgetTester tester) async {
    await _pump(
      tester,
      const HighlightedText(text: '短文本', ranges: <MatchRange>[MatchRange(start: 0, end: 999)]),
    );

    expect(_spans(tester), <(String, bool)>[('短文本', false)]);
  });

  testWidgets('重叠区间合并为一段', (WidgetTester tester) async {
    await _pump(
      tester,
      const HighlightedText(
        text: 'abcdef',
        ranges: <MatchRange>[MatchRange(start: 0, end: 3), MatchRange(start: 2, end: 5)],
      ),
    );

    expect(_spans(tester), <(String, bool)>[('abcde', true), ('f', false)]);
  });
}
