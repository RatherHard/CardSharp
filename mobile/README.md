# mobile

CardSharp 移动端（Flutter 3.47 / Dart 3.13）。

项目总览、环境搭建与协作规范见仓库根目录的 [README.md](../README.md) 与 [CONTRIBUTING.md](../CONTRIBUTING.md)。

## 目录约定

```
lib/
├── core/          # 路由、主题、网络、存储（跨 feature 的基础设施）
├── features/      # 按功能垂直切分，每个 feature 内含 data/domain/presentation
└── shared/        # 跨 feature 复用的组件与注册表
```

## 常用命令

```bash
flutter pub get                      # 安装依赖
dart run build_runner build --delete-conflicting-outputs   # 生成代码
flutter analyze --fatal-infos        # 静态检查
flutter test                         # 测试
flutter run                          # 运行
```

## 注意

`pubspec.yaml` 中的 `hooks.user_defines.sqlite3.source: system` 是刻意配置：
默认会从 GitHub Releases 下载预编译 SQLite，在部分网络环境下不可达。
详见 [AGENTS.md](../AGENTS.md#10-已知环境限制)。
