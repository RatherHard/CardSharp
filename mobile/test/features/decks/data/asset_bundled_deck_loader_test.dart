import 'package:cardsharp/core/l10n/app_strings.dart';
import 'package:cardsharp/features/cards/domain/card.dart';
import 'package:cardsharp/features/decks/data/asset_bundled_deck_loader.dart';
import 'package:cardsharp/features/decks/domain/deck_import.dart';
import 'package:cardsharp/features/decks/domain/sample_deck.dart';
import 'package:cardsharp/features/decks/presentation/widgets/demo_deck_covers.dart';
import 'package:cardsharp/shared/card_widgets/demo_card_images.dart';
import 'package:flutter_test/flutter_test.dart';

/// 守住「内置示例」的几处事实写法，防止各处各写一份后漂移：
/// 1. `assets/examples/*.json` 里的 title（真正导入的内容）；
/// 2. `AppStrings.sampleDeckTitle` / `sampleDeckMiniWorldTitle`（界面常量）；
/// 3. `kDemoDeckCoverAssets` 的键（两个示例各有一张演示封面）；
/// 4. `kDemoCardImages` 的键（每张卡都要有自己的演示配图，缺了界面会静默变占位）。
void main() {
  // rootBundle 读资源需要 binding；普通 test 里没有假时钟，可以安全 await。
  TestWidgetsFlutterBinding.ensureInitialized();

  test('奶蛙家族示例：标题与 AppStrings 一致，有演示封面，每张卡都有配图', () async {
    final String source = await const AssetBundledDeckLoader().loadSampleDeck(
      SampleDeck.naiwaFamily,
    );

    final DeckImport deck = parseDeckImport(source);

    expect(deck.title, AppStrings.sampleDeckTitle);
    expect(deck.cards, isNotEmpty);
    expect(demoCoverFor(deck.title), isNotNull);
    for (final CardFields card in deck.cards) {
      expect(demoCardImageFor(card.plaintext), isNotNull, reason: card.plaintext);
    }
  });

  test('迷你世界示例：标题与 AppStrings 一致，10 张卡都带问句与配图', () async {
    final String source = await const AssetBundledDeckLoader().loadSampleDeck(SampleDeck.miniWorld);

    final DeckImport deck = parseDeckImport(source);

    expect(deck.title, AppStrings.sampleDeckMiniWorldTitle);
    expect(deck.cards, hasLength(10));
    expect(deck.color, '#3B82F6');
    // 用户给了迷你世界的封面图，现在也有演示封面；色块仍作为背景兜底。
    expect(demoCoverFor(deck.title), 'assets/examples/mini-world-cover.png');
    for (final CardFields card in deck.cards) {
      expect(card.question, isNotNull);
      expect(card.question, isNotEmpty);
      expect(demoCardImageFor(card.plaintext), isNotNull, reason: card.plaintext);
      expect(demoCardImageAspectFor(card.plaintext), isNotNull, reason: card.plaintext);
      // 问句问的是「谁」，答案就只给名字（背景描述挪到 extra 备注里）。
      expect(card.ciphertext, card.plaintext, reason: card.plaintext);
    }
  });
}
