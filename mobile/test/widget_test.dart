import 'package:cardsharp/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('应用可启动并渲染首页', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CardSharpApp()));
    await tester.pumpAndSettle();

    expect(find.text('卡锐思'), findsOneWidget);
    expect(find.text('可拓展的 AI 卡片助手'), findsOneWidget);
  });
}
