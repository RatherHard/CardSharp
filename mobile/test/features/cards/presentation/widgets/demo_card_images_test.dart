import 'package:flutter_test/flutter_test.dart';

import 'package:cardsharp/features/cards/presentation/widgets/demo_card_images.dart';

// 演示配图表是「本地资源 → 卡片名」的唯一映射，接后端后整表删除。
// 这里守住它自身的一致性和命名，防止改名/漏配导致图片静默消失。

void main() {
  test('演示配图表覆盖示例卡片集的 8 个角色', () {
    expect(kDemoCardImages.length, 8);
    expect(
      kDemoCardImages.keys,
      containsAll(<String>['奶蛙', '奶蛋', '小奶蛙', '奶鼠', '奶鸡', '奶屎', '豆奶', '奶茶']),
    );
  });

  test('每条都指向 examples/cards 下的图片资源，且宽高比有效', () {
    for (final MapEntry<String, ({String asset, double aspectRatio})> entry
        in kDemoCardImages.entries) {
      final String name = entry.key;
      final String asset = entry.value.asset;
      final double aspectRatio = entry.value.aspectRatio;

      expect(asset, startsWith('assets/examples/cards/'), reason: name);
      expect(
        RegExp(r'\.(jpe?g|png|webp)$', caseSensitive: false).hasMatch(asset),
        isTrue,
        reason: name,
      );
      expect(aspectRatio, greaterThan(0), reason: name);
      expect(aspectRatio, lessThan(3), reason: name);
    }
  });

  test('取图与取比例的入口对同一名字返回同一张资源', () {
    for (final String name in kDemoCardImages.keys) {
      expect(demoCardImageFor(name), isNotNull, reason: name);
      expect(demoCardImageAspectFor(name), isNotNull, reason: name);
    }
    expect(demoCardImageFor('不存在的角色'), isNull);
    expect(demoCardImageAspectFor('不存在的角色'), isNull);
  });
}
