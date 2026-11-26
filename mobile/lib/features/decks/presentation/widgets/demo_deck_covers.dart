/// 客户端内置的演示封面。
///
/// 为什么要单独放一份映射，而不是加进 `Deck` 模型：
/// * 后端契约里卡片集只有 `color`，没有封面图（`docs/03` §4.2）；
/// * 现在只是给「内置示例卡片集」配一张本地图片看效果，属于展示层的临时需要；
/// * 等后端提供封面图（URL 或对象存储 key）时，`Deck` 加正式字段、这里整份删掉即可。
///
/// 键是卡片集标题（内置示例的标题是固定的），值是打包在 assets 里的图片路径。
/// 目前只给「奶蛙家族图鉴」配图，其余卡片集仍显示白色卡堆。
const Map<String, String> kDemoDeckCoverAssets = <String, String>{
  '奶蛙家族图鉴': 'assets/examples/naiwa-cover.png',
};

/// 取某个卡片集的演示封面；没有配图时返回 null（调用方回落到白色卡堆）。
String? demoCoverFor(String deckTitle) => kDemoDeckCoverAssets[deckTitle.trim()];
