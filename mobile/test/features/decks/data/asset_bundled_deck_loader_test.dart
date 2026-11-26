import 'package:cardsharp/core/l10n/app_strings.dart';
import 'package:cardsharp/features/decks/data/asset_bundled_deck_loader.dart';
import 'package:cardsharp/features/decks/domain/deck_import.dart';
import 'package:cardsharp/features/decks/presentation/widgets/demo_deck_covers.dart';
import 'package:flutter_test/flutter_test.dart';

/// 守住「内置示例标题」这一个事实在三处的写法，防止各处各写一份后漂移：
/// 1. `assets/examples/deck-sample.json` 里的 title（真正导入的内容）；
/// 2. `AppStrings.sampleDeckTitle`（界面常量）；
/// 3. `kDemoDeckCoverAssets` 的键（演示封面的匹配键）。
void main() {
  // rootBundle 读资源需要 binding；普通 test 里没有假时钟，可以安全 await。
  TestWidgetsFlutterBinding.ensureInitialized();

  test('内置示例标题与 AppStrings.sampleDeckTitle 一致，且配有演示封面', () async {
    final String source = await const AssetBundledDeckLoader().loadExampleDeckJson();

    final DeckImport deck = parseDeckImport(source);

    expect(deck.title, AppStrings.sampleDeckTitle);
    expect(deck.cards, isNotEmpty);
    expect(demoCoverFor(deck.title), isNotNull);
  });
}
