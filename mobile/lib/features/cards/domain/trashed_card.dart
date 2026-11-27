import 'card.dart';

/// 回收站里的一条卡片记录（只用于「用户单独删掉的卡片」）。
///
/// 跟着卡片集一起进回收站的卡片不在这里：它们在回收站的卡片集详情里，
/// 通过 [Card.deckId] 就能对上（`cards.deleted_with_deck` 存的就是那个集）。
class TrashedCard {
  const TrashedCard({required this.card, required this.deletedAt, required this.sourceDeckTitle});

  final Card card;

  /// 用户点删除的时刻（本地时间）。回收站按它倒序分组。
  final DateTime deletedAt;

  /// 来源卡片集的标题，回收站里标在卡片名下面。
  ///
  /// 单独删除卡片时来源卡片集一定还在（不在就没法删它下面的卡片）；
  /// 若这张卡片后来跟着卡片集一起进回收站，它就不会再出现在这个列表里。
  final String sourceDeckTitle;
}
