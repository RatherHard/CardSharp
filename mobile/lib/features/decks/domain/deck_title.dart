// 卡片集名称的唯一性口径：书架内可见的卡片集之间集名唯一。
//
// 判定规则是「去首尾空格、不区分大小写」；回收站里的卡片集不占名，
// 所以比较只覆盖 deleted_at isNull 的行。新建、改名、从回收站恢复三处
// 都调用这里，避免同一套口径在 Local 与 Fake 两个实现里各写一份。

/// 集名比较用的归一化形式：去掉首尾空格并转小写。
String normalizeDeckTitle(String title) => title.trim().toLowerCase();

/// [candidate] 与 [existing] 是否算同一个集名（trim + 忽略大小写）。
bool isSameDeckTitle(String candidate, String existing) =>
    normalizeDeckTitle(candidate) == normalizeDeckTitle(existing);
