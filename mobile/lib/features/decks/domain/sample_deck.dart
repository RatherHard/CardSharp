/// 应用内置的示例卡片集。
///
/// 这里只描述「有哪几个示例」，**具体 asset 路径由 data 层决定**（`AssetBundledDeckLoader`），
/// 展示名由 presentation 层从 `AppStrings` 取，domain 层不碰资源与文案。
enum SampleDeck {
  /// 奶蛙家族：每个成员带一张本地演示配图。
  naiwaFamily,

  /// 迷你世界角色：卡片自身没有配图，卡片集封面用演示图（`mini-world-cover.png`）。
  miniWorld,
}
