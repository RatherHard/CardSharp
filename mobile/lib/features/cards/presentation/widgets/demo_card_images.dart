/// 内置示例卡片集的成员配图（本地资源）。
///
/// 现在后端还没有图片上传/下载接口（`docs/03` §4.4 只有 `fields.images`
/// 的 `{key,width,height,alt}` 契约），所以演示数据用「按卡片名映射到打包资源」的方式
/// 先把界面跑起来。接后端后改成读 `fields.images.first.key` 的签名 URL，
/// 这个映射表整份删掉即可，调用方只看 `CardImageBox`（shared/card_widgets）。
library;

/// 一张演示配图：资源路径 + 原始宽高比（宽 / 高）。
///
/// 宽高比是给界面算展示区域用的：按比例留出的框里用 `BoxFit.contain` 放图，
/// 图既不会变形也不会被裁掉一块。资源来自工作区 `奶娃家族_八人单图/`，
/// 编号顺序与示例卡片集一致。
const Map<String, ({String asset, double aspectRatio})> kDemoCardImages =
    <String, ({String asset, double aspectRatio})>{
      '奶蛙': (asset: 'assets/examples/cards/naiwa.jpeg', aspectRatio: 614 / 859),
      '奶蛋': (asset: 'assets/examples/cards/naidan.png', aspectRatio: 372 / 363),
      '小奶蛙': (asset: 'assets/examples/cards/xiao_naiwa.jpg', aspectRatio: 1080 / 607),
      '奶鼠': (asset: 'assets/examples/cards/naishu.jpeg', aspectRatio: 1),
      '奶鸡': (asset: 'assets/examples/cards/naiji.jpeg', aspectRatio: 1),
      '奶屎': (asset: 'assets/examples/cards/naishi.jpeg', aspectRatio: 1),
      '豆奶': (asset: 'assets/examples/cards/dounai.jpeg', aspectRatio: 290 / 372),
      '奶茶': (asset: 'assets/examples/cards/naicha.jpeg', aspectRatio: 1),
    };

/// 按卡片名取演示配图路径；没有对应资源时返回 null（界面显示占位）。
String? demoCardImageFor(String name) => kDemoCardImages[name]?.asset;

/// 按卡片名取演示配图的宽高比；没有对应资源时返回 null。
double? demoCardImageAspectFor(String name) => kDemoCardImages[name]?.aspectRatio;
