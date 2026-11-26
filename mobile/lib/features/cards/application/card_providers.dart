import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/card.dart';
import 'cards_controller.dart';

/// 卡片页要的两个 id。参数用 id 而不是实体（docs/05 §6），
/// 这样页面刷新后仍能靠路由参数重建，不依赖内存里的对象。
typedef CardRef = ({String deckId, String cardId});

/// 单张卡片：从该卡片集的完整列表里按 id 找。
///
/// 找不到返回 null，由页面显示「卡片不存在」；不抛异常，
/// 因为「id 失效」是正常的用户路径（例如卡片刚被删除）。
///
/// 这里不写显式类型：Riverpod 3 未导出 `FutureProviderFamily`（docs/05 §6）。
final cardByIdProvider = FutureProvider.family<Card?, CardRef>((Ref ref, CardRef ref2) async {
  final List<Card> cards = await ref.watch(cardsForDeckProvider(ref2.deckId).future);
  for (final Card card in cards) {
    if (card.id == ref2.cardId) {
      return card;
    }
  }
  return null;
});
