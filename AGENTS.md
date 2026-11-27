# AGENTS.md

> AI 编码代理在本仓库工作的唯一权威指南。人类贡献者见 [CONTRIBUTING.md](CONTRIBUTING.md)。
>
> 文件名固定 `AGENTS.md`（Codex / Cursor / Aider 均识别），不用 `AGENT.md`、`CLAUDE.md`、`.cursorrules`。

## 开始任何任务前

**CardSharp（卡锐思）**：可拓展的 AI 卡片助手，把资料变成可运行的卡片集合，用长期学习计划驱动持续记忆。MVP 范围 = 资料导入 → 制卡 → 复习 → 计划 → 答疑。

| 文档 | 作用 |
| --- | --- |
| [docs/02-MVP需求文档.md](docs/02-MVP需求文档.md) | 要做什么（范围、验收标准） |
| [docs/03-MVP设计文档.md](docs/03-MVP设计文档.md) | 怎么做（架构、数据模型、接口） |
| [docs/05-工程规范.md](docs/05-工程规范.md) | 移动端代码规范与门禁（本文件的下游细化） |
| [docs/04-移动端开发须知.md](docs/04-移动端开发须知.md) | 移动端现状、坑、交差流程 |

**冲突优先级**：需求文档 > 设计文档 > 本文件 > 代码现状。文档之间冲突时**停下来问人类**，不要自己选。

## 分层铁律

- **移动端**：`presentation → application → domain ← data`；端口声明在 `core/di`，装配只在 `main.dart`。细则见 [docs/05 §1/§2](docs/05-工程规范.md)。
- **后端**：`routers/` 只做入参校验/鉴权/序列化；`services/` 编排用例与事务；`domain/` 纯业务逻辑（仅标准库，不碰 SQLAlchemy/FastAPI/网络）；`infra/` 实现仓储等外部依赖。**违反分层 = 直接打回**，发现旧代码违规先修再改或在 PR 说明。

## 技术栈（锁定版本，不擅自升级大版本）

- 后端：Python 3.12、FastAPI 0.115+、SQLAlchemy async 2.0+、LangGraph 0.2+、ARQ 0.26+、PostgreSQL 16 + pgvector、Redis 7（实际锁定见 `uv.lock`）。
- 移动端：Flutter 3.50.1、Dart 3.14.0、Riverpod 3、go_router 18、Drift（见 `pubspec.yaml` / [docs/05 §12](docs/05-工程规范.md)）。
- **排程全在服务端**（`agents/graphs/scheduler.py` + `domain/scheduling_*.py`），客户端不引入任何排程库，只消费已排期队列。
- 升级大版本单独开 PR 并说明迁移影响。

## 提交前必跑（门禁）

在 `mobile/` 下四条，顺序与参数见 [docs/05 §9](docs/05-工程规范.md)：

```bash
dart format --line-length 100 lib test
flutter analyze --fatal-infos
flutter test --coverage          # CI 校验行覆盖率 ≥ 60%
flutter build apk --debug        # 涉及界面/插件时
```

- 改注解模型后跑 `dart run build_runner build`，**生成代码必须提交**；CI 会比对 `git status --porcelain lib`。
- 后端：`ruff`（行宽 100）+ `mypy --strict` + `pytest`；业务错误抛 `app.domain.errors`，`services/` 以下禁止 `raise HTTPException`。
- 仓库根有 `Makefile` 便捷命令（`make setup/dev/check`）；Windows 没有 `make` 时直接执行对应命令（如 `cd mobile; flutter test`）。

## 编码规范要点（细则见 docs/05 §3/§5/§6/§7）

- 用户可见文案全部放 `mobile/lib/core/l10n/app_strings.dart`；`data/application/domain` 不写中文字面量。
- 常量 `k` 前缀小驼峰；Widget Key 用 `'区域_组件[_动作]'`；新增交互必须有 Key。
- 新增 `fromJson`/`toJson` 模型必须 `@freezed` + `@JsonSerializable(fieldRename: FieldRename.snake)`（Dart 标识符保持小驼峰，不要改成下划线）。
- 状态类用 `freezed`；控制器只经 UseCase 取数，不直接 watch 仓储。
- 注释只写「为什么」；禁止调试残留（`print`/`debugPrint`/`console.log`）、注释掉的大段代码、`.env`/密钥。

**写新函数、新常量、新规则前，先在仓库里搜现成的**（`grep`/`glob`）：同一规则出现第二处就抽公共处，别各写一份。

## 提交与分支

- Conventional Commits，**中文正文**：`<type>(<scope>): <subject>`，subject ≤ 50 字、不加句号，一次提交只做一件事。
- **禁止** `git add -A` 混提；逐条 `git add`。破坏性变更在 footer 写 `BREAKING CHANGE: <说明>`。
- 分支 `<type>/<kebab-case>`，从 `main` 切出；**`main` 受保护，只能走 PR**，PR 需过 CI + 至少 1 人 review + 「改了什么 / 为什么 / 怎么验证」。
- 禁止强推 `main`、跳过 hook（`--no-verify`）、提交密钥。
- **提交被钩子拒了，就照报错把文件拆开**，不要绕过：`.githooks/pre-commit` 拦 >20 KB 的单个文件（生成代码、锁文件、资源除外）。

## 必须停下来问人类的情况

- 需求文档与设计文档冲突，或文档没写清
- 新增第三方依赖（尤其大依赖）
- 修改数据库 Schema（影响迁移）
- 改变公开 API 契约 / JSON 字段形状
- 发现安全漏洞
- 任务范围超出 MVP（见需求文档第 8 节）

## Agent 工作流

1. 读文档确认验收标准 → 2. 搜现有代码与约定 → 3. 复杂改动先写方案 → 4. 小步实现、每步可运行 → 5. 补测试 → 6. 逐行自审 `git diff`、删调试代码 → 7. 按规范提交。新功能落地清单见 [docs/05 §14](docs/05-工程规范.md)。

**工具偏好**：找文件用 `glob`，搜内容用 `grep`，读文件用 `read`（不用 shell 等价命令）。

**界面可见改动的交差**（细则与命令见 [docs/04 §10](docs/04-移动端开发须知.md)）：

- 必须 `flutter build apk --debug` + `adb install -r` 后在真机/模拟器点一遍，逐步截图；只跑 `flutter test` 不算验证。
- 交差固定写四件套：**做了什么 / 测试命令与通过数 / 截图路径 / 没验证到的**。
- 构建报 `PathExistsException` 先 `flutter clean`；模拟器看到旧界面说明没重装。

## 已知环境限制

完整清单见 [docs/04 §5 与 §12](docs/04-移动端开发须知.md)，最容易踩的三条：

- GitHub HTTPS 被重置 → git 走 SSH（`~/.ssh/config` 已指向 `ssh.github.com:443`）。
- Flutter/pub 走国内镜像；`sqlite3` 原生库从 GitHub Release 下载，需 `mobile/pubspec.yaml` 里的 `url_pattern` 镜像（换到能直连的网络后可删）。
- AGP 9.3.1 / Kotlin 2.4.20 / Gradle 9.5.0 / `compileSdk 37` 已固定，**不要降回**。

**遇到新限制时追加到 `docs/04 §5`，不要静默绕过。**

## 文档维护

- 代码改动影响架构、数据模型、API 契约 → 同步更新 `docs/03`；移动端现状变化 → 更新 `docs/04`。
- 需求变更只能由人类提出，代理不得自行扩大范围。文档用中文，代码标识符用英文。

## 提交前自检

- [ ] 门禁四条全绿，生成代码已提交
- [ ] 新增行为有能真正失败的测试
- [ ] 无调试残留、无硬编码密钥、分层未破坏
- [ ] 涉及架构/API 的文档已同步
- [ ] 提交信息符合规范，改动按功能拆开

| 规则 | 由什么拦住 |
| --- | --- |
| 界面可见改动必须附真机截图 | 交差格式强制写截图路径（机器判不了布局与可见性，交给人看） |
| 单文件不超过 20 KB | `.githooks/pre-commit` 拦截（`git config core.hooksPath .githooks` 后生效） |
| 生成代码必须最新且已提交 | CI 比对 `git status --porcelain lib` |
| 格式/静态检查/测试 | CI：`dart format --set-exit-if-changed` + `flutter analyze --fatal-infos` + `flutter test --coverage`（≥60%） |
