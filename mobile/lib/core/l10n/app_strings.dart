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

  // ---------------------------------------------------------------- 卡片集详情
  static const String deckDetailCardsTitle = '卡片列表';
  static const String deckDetailRun = '运行';
  static const String deckDetailNoCards = '还没有卡片';
  static const String deckDetailNoCardsHint = '这里会显示卡片集里的卡片';
  static const String deckDetailColumnIndex = '序号';
  static const String deckDetailColumnPlaintext = '卡片明文';
  static const String deckDetailColumnCiphertext = '暗文';

  /// 列表里不展示暗文内容，只给一个占位，避免剧透答案。
  static const String deckCiphertextHidden = '？？';
  static const String deckDetailNotFound = '卡片集不存在';
  static const String deckDetailLoadFailed = '卡片加载失败';
  static const String cardPageTitle = '卡片页面';

  // ---------------------------------------------------------------- 编辑与多选
  static const String actionEdit = '编辑';
  static const String actionSave = '保存';
  static const String hintLongPressToEdit = '长按可修改';

  static const String deckEditNameTitle = '修改卡片集名称';
  static const String deckEditNameLabel = '名称';
  static const String deckEditDescriptionTitle = '修改简介';
  static const String deckEditDescriptionLabel = '简介';

  /// 简介为空时的占位提示：让用户知道这里可以长按添加。
  static const String deckAddDescriptionHint = '添加简介';
  static const String deckEditColorTitle = '修改封面颜色';
  static const String deckEditColorDefault = '默认';
  static const String deckEditFailed = '修改失败，请重试';

  static const String cardEditTitle = '编辑卡片';
  static const String cardEditPlaintextLabel = '明文';
  static const String cardEditCiphertextLabel = '暗文';
  static const String cardEditHintLabel = '提示';
  static const String cardEditExtraLabel = '备注';
  static const String cardEditOrderLabel = '序号';
  static const String cardEditRequired = '明文和暗文都不能为空';
  static const String cardEditTooLong = '明文不超过 200 字，暗文不超过 500 字';
  static const String cardUpdateFailed = '保存失败，请重试';
  static const String cardDeleteTitle = '删除卡片';
  static const String cardDeleteConfirmText = '删除后不可恢复，确定删除这张卡片吗？';
  static const String cardDeleteFailed = '删除失败，请重试';

  static const String multiSelectEnter = '多选';
  static const String multiSelectCancel = '取消';
  static const String multiSelectSelectAll = '全选';
  static const String multiSelectEmpty = '请先选择卡片';
  static const String multiSelectDeleteTitle = '批量删除';

  /// 多选模式下底部条左侧的已选计数。
  static String multiSelectSelected(int count) => '已选 $count 项';

  static String multiSelectDeleteCount(int count) => '删除（$count）';

  static String multiSelectDeleteConfirm(int count) => '确定删除选中的 $count 张卡片吗？删除后不可恢复。';

  // ---------------------------------------------------------------- 导入
  static const String shelfAddMenuTitle = '添加卡片集';
  static const String shelfAddMenuImport = '导入卡片集';

  /// 内置示例卡片集：应用自带一份 JSON，演示时不必先往手机里传文件。
  static const String shelfAddMenuImportSample = '导入示例卡片集';
  static const String shelfAddMenuCreate = '新建卡片集';
  static const String importFailed = '导入失败，请检查文件';
  static const String importErrorInvalidJson = '文件不是有效的 JSON';
  static const String importErrorNotAnObject = '文件内容不是一份卡片集';
  static const String importErrorMissingTitle = '缺少卡片集名称（title）';
  static const String importErrorMissingCards = '文件里没有任何卡片';
  static const String importErrorInvalidCard = '有卡片缺少明文或暗文，或超出字数限制';

  static String importSucceeded(String title) => '已导入「$title」';

  // ---------------------------------------------------------------- 数据层异常
  static const String deckTitleRequired = '卡片集名称不能为空';

  /// 删除时找不到对应卡片集。
  static String deckNotFound(String id) => '卡片集不存在：$id';
}
