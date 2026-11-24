/// 全局文案（本期只有中文，单语言）。
///
/// 为什么集中在这里：
/// 1. 文案散在各组件里时，改一个术语（例如「卡片集」统一叫法）需要翻十几个文件；
/// 2. 将来真要做多语言，只需把这里的常量换成 `context.l10n.xxx`（`docs/03` 规划的
///    `lib/l10n/` 就是给那一层的位置），页面结构不用动。
///
/// 为什么不上 `intl` + ARB：
/// 本期只有中文单语言，官方 l10n 需要 `gen-l10n` 生成与生成物提交，收益要等多语言
/// 才兑现；先用常量把文案「收口」，是成本最低的一步。
///
/// 约定：
/// - 界面文案是常量；带变量的文案用静态方法；
/// - 假数据（`kSeedDecks` 的「卡片集1..6」）属于数据，不放在这里；
/// - 异常消息（会展示给用户的那几句）也放这里，避免数据层与展示层各写一套。
abstract final class AppStrings {
  // ---------------------------------------------------------------- 通用动作
  static const String appTitle = '卡锐思';
  static const String actionCancel = '取消';
  static const String actionCreate = '创建';
  static const String actionDelete = '删除';
  static const String actionRetry = '重试';
  static const String actionClear = '清空';

  // ---------------------------------------------------------------- 导航
  static const String tabDecks = '卡片';
  static const String tabAssistant = '助手';
  static const String tabCommunity = '社区';
  static const String settings = '设置';

  // ---------------------------------------------------------------- 登录
  static const String loginSubtitle = '登录后开始整理你的卡片集';
  static const String loginUsernameLabel = '账号';
  static const String loginPasswordLabel = '密码';
  static const String loginSubmit = '登录';

  /// 登录失败提示：账号或密码不对。
  static const String loginInvalidCredentials = '用户名或密码不正确';

  /// 登录页底部的「测试账号」提示。
  static String loginTestAccountHint(String username, String password) =>
      '测试账号：$username / $password';

  // ---------------------------------------------------------------- 侧栏
  static const String drawerGuestName = '请登录';
  static const String drawerSignOut = '退出登录';

  // ---------------------------------------------------------------- 书架
  static const String shelfMenuTooltip = '侧栏';
  static const String shelfSearchHint = '搜索卡片集';
  static const String shelfCreateTooltip = '新建卡片集';
  static const String shelfEmptyTitle = '还没有卡片集';
  static const String shelfEmptySubtitle = '点右上角「+」新建一个';
  static const String shelfNoMatchTitle = '没有找到匹配的卡片集';
  static const String shelfNoMatchSubtitle = '换个关键词试试';
  static const String shelfLoadErrorTitle = '卡片集加载失败';
  static const String shelfCreateFailed = '新建卡片集失败，请重试';
  static const String shelfDeleteFailed = '删除卡片集失败，请重试';

  // ---------------------------------------------------------------- 卡片集
  static const String deckCoverPlaceholder = '封面图片';
  static const String createDeckTitle = '新建卡片集';
  static const String createDeckFieldLabel = '卡片集名称';
  static const String createDeckFieldHint = '例如：高等数学·极限';
  static const String deleteDeckTitle = '删除卡片集';

  /// 卡片数后缀，例如「12 张卡片」。
  static String deckCardCount(int count) => '$count 张卡片';

  /// 删除确认文案。删除不可恢复，必须把后果写在文案里。
  static String deleteDeckConfirm(String title) => '确定删除「$title」吗？删除后不可恢复。';

  // ---------------------------------------------------------------- 数据层异常
  static const String deckTitleRequired = '卡片集名称不能为空';

  /// 删除时找不到对应卡片集。
  static String deckNotFound(String id) => '卡片集不存在：$id';
}
