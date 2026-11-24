import 'package:material_ui/material_ui.dart';

/// 占位页。
///
/// 约定（人类确认）：还没做的功能点进去就是**纯白页**，不放假内容；
/// 从 Tab 进入时没有标题栏，从二级入口 push 进入时带标题与返回键。
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({this.title, super.key});

  final String? title;

  @override
  Widget build(BuildContext context) {
    final Widget blank = ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: const SizedBox.expand(),
    );
    if (title == null) {
      return blank;
    }
    return Scaffold(
      appBar: AppBar(title: Text(title!)),
      body: blank,
    );
  }
}
