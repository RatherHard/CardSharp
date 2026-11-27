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
  static const String drawerTrash = '回收站';

  // ---------------------------------------------------------------- 书架
  static const String shelfMenuTooltip = '侧栏';
  static const String shelfCreateTooltip = '新建卡片集';
  static const String shelfEmptyTitle = '还没有卡片集';
  static const String shelfEmptySubtitle = '点右上角「+」新建一个';
  static const String shelfLoadErrorTitle = '卡片集加载失败';
  static const String shelfCreateFailed = '新建卡片集失败，请重试';
  static const String shelfDeleteFailed = '删除卡片集失败，请重试';

  // ---------------------------------------------------------------- 卡片集
  static const String createDeckFieldLabel = '卡片集名称';
  static const String createDeckFieldHint = '例如：高等数学·极限';
  static const String deleteDeckTitle = '删除卡片集';

  /// 卡片数后缀，例如「12 张卡片」。
  static String deckCardCount(int count) => '$count 张卡片';

  /// 删除确认文案。删除是「移入回收站」，必须把可恢复这条写清楚。
  static String deleteDeckConfirm(String title) => '确定把「$title」移到回收站吗？之后可以在回收站里恢复。';

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
  static const String cardDefinitionLabel = '定义';
  static const String cardHintLabel = '提示';
  static const String cardExtraLabel = '备注';

  /// 卡片页的辅助信息区（提示 + 备注），默认折叠，点标题展开。
  static const String cardTipsTitle = 'Tips';
  static const String cardNotFound = '这张卡片不存在';
  static const String cardLoadFailed = '卡片加载失败';
  static const String cardRetry = '重试';

  /// 卡片页顶部星标：接后端后是「收藏/标记」，现在只做本地切换。

  /// Agent 区占位（AI 分析 / 解题），接后端后接 SSE 流式回答（docs/03 §7.5 InlineChatSection）。
  static const String cardAgentTitle = 'Agent 分析 / 解题';
  static const String cardAgentHint = '接入后端后，这里显示 AI 讲解与追问';

  /// 卡片页底部输入区占位（选项 / 回答 / 提问）。
  static const String cardInputHint = '选项 / 回答输入 / 提问';

  /// 卡片页底部「翻页」：翻到卡片集里的下一张。

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

  /// 长度上限提示。上限只定义在 `cards/domain/card.dart`，由调用方传进来，
  /// 避免文案里再写一份数字（`core` 不能反向依赖 `features`，见 docs/05 §1）。
  static String cardEditTooLong(int plaintextMax, int ciphertextMax) =>
      '明文不超过 $plaintextMax 字，暗文不超过 $ciphertextMax 字';
  static const String cardUpdateFailed = '保存失败，请重试';
  static const String cardDeleteTitle = '删除卡片';
  static const String cardDeleteConfirmText = '移到回收站？之后可以在回收站里恢复。';
  static const String cardDeleteFailed = '删除失败，请重试';

  static const String multiSelectEnter = '多选';
  static const String multiSelectCancel = '取消';
  static const String multiSelectSelectAll = '全选';
  static const String multiSelectEmpty = '请先选择卡片';
  static const String multiSelectDeleteTitle = '批量删除';

  /// 多选模式下底部条左侧的已选计数。
  static String multiSelectSelected(int count) => '已选 $count 项';

  static String multiSelectDeleteCount(int count) => '删除（$count）';

  static String multiSelectDeleteConfirm(int count) => '确定把选中的 $count 张卡片移到回收站吗？之后可以恢复。';

  // ---------------------------------------------------------------- 回收站
  static const String trashTitle = '回收站';
  static const String trashEmpty = '回收站是空的';
  static const String trashEmptyHint = '删除卡片集或卡片后会出现在这里';
  static const String trashLoadFailed = '回收站加载失败';
  static const String trashSectionDecks = '卡片集';
  static const String trashSectionCards = '卡片';
  static const String trashRestore = '恢复';

  /// 卡片来源标注，例如「来自「卡片集1」」。
  static String trashCardSource(String deckTitle) => '来自「$deckTitle」';

  /// 回收站按天分组的日期头：当年只写「10月1日」，跨年补年份。
  static String trashDayHeader(DateTime day, DateTime now) =>
      day.year == now.year ? '${day.month}月${day.day}日' : '${day.year}年${day.month}月${day.day}日';

  static const String trashRestoreDeckTitle = '恢复卡片集';
  static const String trashRestoreWholeDeck = '恢复整个卡片集';

  /// 恢复整个卡片集前的确认；说明卡片会一起回来。
  static String trashRestoreDeckConfirm(String title) => '把「$title」恢复到书架？跟着它一起删除的卡片也会一起恢复。';

  static const String trashRestoreCardTitle = '恢复到哪里';
  static const String trashRestoreToOriginal = '恢复到原卡片集';
  static const String trashRestoreToNew = '新建卡片集恢复';
  static const String trashRestoreNewTitleLabel = '新卡片集名称';

  /// 原卡片集还在回收站时，单张恢复会把它一起恢复，需要提示。
  static String trashRestoreCascadeHint(String deckTitle) => '原卡片集「$deckTitle」也会一起恢复';

  /// 在回收站卡片详情里恢复单张时，「原卡片集」这一项的副作用说明。
  static String trashRestoreWithDeckHint(String deckTitle) => '会把「$deckTitle」整个卡片集一起恢复';

  static const String trashRestoreDone = '已恢复';
  static const String trashRestoreFailed = '恢复失败，请重试';
  static const String trashDeckEmpty = '这个卡片集没有可恢复的卡片';
  static const String trashDeckNotFound = '回收站里没有这个卡片集';

  // ---- 永久删除（回收站里的多选）--------------------------------------
  static const String trashSelect = '选择';
  static const String trashPurge = '永久删除';
  static const String trashPurgeTitle = '永久删除';

  /// 永久删除前的确认，必须把「无法恢复」说清楚。
  static String trashPurgeConfirm(int count) => '删除后无法恢复，确定永久删除选中的 $count 项吗？';

  static const String trashPurgeDone = '已永久删除';
  static const String trashPurgeFailed = '永久删除失败，请重试';

  // ---------------------------------------------------------------- 导入
  static const String shelfAddMenuImport = '导入卡片集';

  /// 内置示例卡片集：应用自带一份 JSON，演示时不必先往手机里传文件。
  static const String shelfAddMenuImportSample = '导入示例卡片集';

  /// 有多个示例时先选一个（`SampleDeck`）。
  static const String shelfSamplePickerTitle = '选择示例卡片集';
  static const String shelfSampleNaiwaHint = '8 张卡片，带角色配图';
  static const String shelfSampleMiniWorldHint = '10 张卡片，带角色问句';
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

  // ---------------------------------------------------------------- 搜索
  //
  // 搜索是「全量搜索 + 按层级分档」：同级的先出、再出下级、最后出上级。
  // 分档标题就是层级名，所以这里不再有「卡片集 / 全部卡片」模式文案。
  static const String searchHint = '搜索卡片集和卡片';
  static const String searchSectionDecks = '卡片集';
  static const String searchSectionCards = '卡片';
  static const String searchSectionParent = '上级';
  static const String searchEmptyTitle = '没有找到匹配的内容';
  static const String searchEmptySubtitle = '换个关键词试试';
  static const String searchMoreResults = '更多搜索结果';
  static const String searchDeckSearchHint = '搜索本集卡片和卡片集';

  /// 命中字段标注。
  static const String searchFieldPlaintext = '明文命中';
  static const String searchFieldCiphertext = '暗文命中';

  /// 卡片结果下方的来源卡片集。
  static String searchFromDeck(String title) => '来自：$title';

  /// 达到扫描上限时的提示。
  static String searchScanLimit(int count) => '仅搜索了前 $count 张卡片，请缩小范围或指定卡片集';

  /// 删除或更新时找不到对应卡片集。
  static String deckNotFound(String id) => '卡片集不存在：$id';

  /// 书架里已有同名卡片集（新建 / 改名 / 从回收站恢复都会遇到）。
  static const String deckDuplicateTitle = '书架里已有同名卡片集，换一个名字吧';

  /// 拉取时命中「同编号的卡片集在回收站里」：跳过，不复活也不建副本。
  static const String importDeckInTrash = '这个卡片集在回收站里，先恢复或永久删除再导入';

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

  /// 第二个内置示例（迷你世界角色）的标题，同样与 `assets/examples/mini-world-deck.json` 一致。
  static const String sampleDeckMiniWorldTitle = '迷你世界角色图鉴';
}
