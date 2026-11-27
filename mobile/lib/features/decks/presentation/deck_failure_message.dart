import '../../../core/l10n/app_strings.dart';
import '../domain/deck_repository.dart';

/// 把 `DeckFailure` 翻成用户可见文案（唯一一份口径）。
///
/// `titleRequired` / `duplicateTitle` 在书架新建、导入、详情改名都用同一句；
/// `notFound` 需要卡片集 id 才能说清是哪一个。
/// `authorityInTrash` 的文案取决于入口（导入 vs 改名），这里返回 null，
/// 由调用方接自己的兜底文案。
String? deckFailureMessage(DeckFailure failure, {String? deckId}) => switch (failure) {
  DeckFailure.titleRequired => AppStrings.deckTitleRequired,
  DeckFailure.duplicateTitle => AppStrings.deckDuplicateTitle,
  DeckFailure.notFound => deckId == null ? null : AppStrings.deckNotFound(deckId),
  DeckFailure.authorityInTrash => null,
};
