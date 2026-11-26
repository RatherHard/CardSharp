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
///   唯一例外是内置示例卡片集的标题：它同时是展示层「演示封面」的匹配键，
///   放这里便于和 `assets/examples/deck-sample.json` 一起校验（见 `sampleDeckTitle`）；
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
  static const String deckDetailNotFound = '卡片集不存在';
  static const String deckDetailLoadFailed = '卡片加载失败';
  static const String cardPageTitle = '卡片';

  // ---------------------------------------------------------------- 卡片页（浏览模式）
  static const String cardImageEmpty = '还没有配图';
  static const String cardImageEmptyHint = '接入后端后可上传和查看配图';
  static const String cardDefinitionLabel = '定义';
  static const String cardHintLabel = '提示';
  static const String cardExtraLabel = '备注';

  /// 卡片页的辅助信息区（提示 + 备注），默认折叠，点标题展开。
  static const String cardTipsTitle = 'Tips';
  static const String cardNotFound = '这张卡片不存在';
  static const String cardLoadFailed = '卡片加载失败';
  static const String cardRetry = '重试';

  /// 卡片页顶部星标：接后端后是「收藏/标记」，现在只做本地切换。
  static const String cardFavoriteTooltip = '标记卡片';
  static const String cardFavoriteHint = '标记功能接入后端后可用';

  /// Agent 区占位（AI 分析 / 解题），接后端后接 SSE 流式回答（docs/03 §7.5 InlineChatSection）。
  static const String cardAgentTitle = 'Agent 分析 / 解题';
  static const String cardAgentHint = '接入后端后，这里显示 AI 讲解与追问';

  /// 卡片页底部输入区占位（选项 / 回答 / 提问）。
  static const String cardInputHint = '选项 / 回答输入 / 提问';

  /// 卡片页底部「翻页」：翻到卡片集里的下一张。
  static const String cardFlipLabel = '翻页';
  static const String cardFlipLastHint = '已是最后一张';

  // ---------------------------------------------------------------- 复习（运行）
  static const String reviewTitle = '复习';
  static const String reviewQuestionLabel = '问题';
  static const String reviewAnswerLabel = '答案';
  static const String reviewShowAnswer = '查看';
  static const String reviewOpenCard = '查看本卡片';

  /// 卡片正文翻出来后，底部的「收起」：翻回答案面。
  static const String reviewHideCard = '收起';
  static const String reviewNext = '下一个';
  static const String reviewFinish = '完成';
  static const String reviewDoneTitle = '这一轮看完了';
  static const String reviewRestart = '再看一遍';
  static const String reviewEmpty = '这个卡片集还没有卡片';

  /// 复习页顶部进度文案，如「第 3 / 8 张」。
  static String reviewProgressText(int current, int total) => '第 $current / $total 张';

  /// 复习完成页的统计文案。
  static String reviewDoneSummary(int total) => '共看完 $total 张卡片';

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
  static const String importErrorInvalidDeck = '卡片集字段格式不对（description / color / config）';
  static const String importErrorInvalidCard = '有卡片的 fields 格式不对：缺明文/暗文、超长或图片字段不合法';
  static const String importErrorUnsupportedCardType = '暂时只支持记忆卡（card_type 必须是 memory）';

  static String importSucceeded(String title) => '已导入「$title」';

  // ---------------------------------------------------------------- 数据层异常的展示文案
  //
  // 数据层（domain / data）只抛枚举（`AuthFailure` / `DeckFailure` / `CardFailure`），
  // 中文统一在这里翻译，避免同一句话在数据层与展示层各写一套。
  static const String deckTitleRequired = '卡片集名称不能为空';

  /// 删除或更新时找不到对应卡片集。
  static String deckNotFound(String id) => '卡片集不存在：$id';

  /// 后端异常但没有给出可展示说明时的兜底。
  static const String unknownError = '未知错误';

  // ---------------------------------------------------------------- 设置页
  static const String settingsAccountTitle = '账号';
  static const String settingsLocalAccountTag = '本地测试账号';
  static const String settingsAppearanceTitle = '外观';
  static const String settingsThemeSystem = '跟随系统';
  static const String settingsThemeLight = '浅色';
  static const String settingsThemeDark = '深色';
  static const String settingsAppearanceHint = '选择后立即生效，重启应用后保持。';
  static const String settingsAboutTitle = '关于';

  /// 版本号：与 `mobile/pubspec.yaml` 的 `version` 保持一致，改版本时两处一起改。
  static const String appVersion = '1.0.0+1';
  static const String settingsVersionLabel = '版本';

  // ---------------------------------------------------------------- 卡片集封面
  static const String deckCoverSheetTitle = '封面';

  /// 卡片集详情页右上角「导入封面」按钮：只导入封面，不涉及卡片配图。
  static const String deckCoverImportAction = '导入封面';
  static const String deckCoverPickImage = '选择本地图片';
  static const String deckCoverChangeColor = '更换封面色';
  static const String deckCoverRemoveImage = '移除封面图';
  static const String deckCoverUpdateFailed = '封面更新失败，请重试';

  // ---------------------------------------------------------------- 系统文件选择器
  /// 系统文件选择器里「图片」这一组的中文标签（Android SAF 会原样显示）。
  static const String imageFileTypeGroupLabel = '图片';

  // ---------------------------------------------------------------- 内置示例卡片集
  /// 内置示例卡片集的标题。
  ///
  /// 必须与 `assets/examples/deck-sample.json` 的 `title` 保持一致：
  /// - 导入该示例后，书架按这个标题给它配演示封面（见 `demo_deck_covers.dart`）；
  /// - 有单测 `sample_deck_test.dart` 守着这两处不许漂移。
  static const String sampleDeckTitle = '奶蛙家族图鉴';
}
