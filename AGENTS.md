# AGENTS.md

> 本文件是 **AI 编码代理**在本仓库工作的唯一权威指南。
> 人类贡献者请先读 [CONTRIBUTING.md](CONTRIBUTING.md)，本文件包含其全部约束并补充代理专属规则。
>
> 文件名约定：使用复数 **`AGENTS.md`**（业界通行约定，如 OpenAI Codex、Cursor、Aider 均识别此名）。
> 不使用 `AGENT.md`、`CLAUDE.md`、`.cursorrules`。

---

## 1. 项目速览

**CardSharp（卡锐思）** 是一个可拓展的 AI 卡片助手：用 Agent 把用户资料变成可运行的卡片集合，用长期学习计划驱动持续记忆。

MVP 范围：记忆卡片全链路（资料导入 → 制卡 → 复习 → 计划 → 答疑）。

**开始任何任务前，必须先读：**

| 文档 | 作用 |
| --- | --- |
| [docs/02-MVP需求文档.md](docs/02-MVP需求文档.md) | 要做什么（范围、验收标准） |
| [docs/03-MVP设计文档.md](docs/03-MVP设计文档.md) | 怎么做（架构、数据模型、接口） |
| [docs/00-项目提案.md](docs/00-项目提案.md) | 为什么做（背景，仅需了解） |

**冲突处理优先级**：需求文档 > 设计文档 > 本文件 > 代码现状。
若文档之间冲突，**停下来向人类确认**，不要自行选择。

---

## 2. 仓库结构

```
CardSharp/
├── docs/                  # 需求与设计文档（唯一事实源）
├── backend/               # FastAPI + LangGraph 后端
│   ├── app/
│   │   ├── routers/       # HTTP 层：入参校验、鉴权、序列化
│   │   ├── services/      # 用例编排、事务边界
│   │   ├── domain/        # 纯业务逻辑（无 IO、无框架依赖）
│   │   ├── agents/        # LangGraph 图与 Prompt
│   │   ├── infra/         # 仓储、LLM、存储、队列实现
│   │   └── workers/       # ARQ 异步任务
│   ├── migrations/        # Alembic 迁移
│   └── tests/
├── mobile/                # Flutter 移动端
│   └── lib/
│       ├── core/          # 路由、主题、网络、存储
│       ├── features/      # 按功能垂直切分
│       └── shared/        # 跨 feature 复用组件
├── deploy/                # Docker Compose、初始化脚本
└── .github/workflows/     # CI
```

### 2.1 分层铁律

| 层 | 允许依赖 | 禁止 |
| --- | --- | --- |
| `routers/` | `services/`, `domain/errors` | 写业务逻辑、直接访问数据库 |
| `services/` | `domain/`, `infra/` | 直接拼 SQL、依赖 FastAPI 类型 |
| `domain/` | 仅标准库 | 依赖 SQLAlchemy / FastAPI / 网络 |
| `infra/` | `domain/` 接口 | 业务判断 |

**违反分层 = 直接打回。** 如果发现现有代码违反，先修再改，或在 PR 中说明。

---

## 3. 技术栈（锁定版本）

| 层 | 技术 | 版本 |
| --- | --- | --- |
| 后端 | Python | 3.12 |
| | FastAPI | 0.115+ |
| | SQLAlchemy (async) | 2.0+ |
| | LangGraph | 0.2+（实际锁定见 `uv.lock`） |
| | ARQ | 0.26+ |
| 数据库 | PostgreSQL + pgvector | 16 / 0.7+ |
| 缓存/队列 | Redis | 7 |
| 排程 | **排程 Agent + 确定性护栏 + FSRS 兜底** | — |
| 移动端 | Flutter | 3.50.1 |
| | Dart | 3.14.0 |
| | Riverpod | 3.x |
| | go_router | 18.x |
| | Drift | 2.35+ |

> **不要擅自升级大版本。** 需要升级时，单独开 PR 并说明迁移影响。
>
> **排程归属**：排程全部在服务端（`agents/graphs/scheduler.py` + `domain/scheduling_*.py`）。**客户端不引入任何排程库**，只消费已排期队列。

---

## 4. 常用命令

所有命令在**仓库根目录**执行。

```bash
make setup        # 首次：安装前后端依赖
make infra-up     # 启动 Postgres / Redis / MinIO
make migrate      # 应用数据库迁移
make dev          # 启动后端（热重载，:8000）
make worker       # 启动异步 Worker
make app-run      # 运行 Flutter App
make check        # 提交前完整检查（lint + typecheck + test）
```

Windows 无 `make` 时，直接执行 `Makefile` 中对应命令，例如：

```powershell
cd backend; uv run pytest
cd mobile;  flutter test
```

---

## 5. 编码规范

### 5.1 Python

- **格式化与 Lint**：`ruff`（配置见 `backend/pyproject.toml`），行宽 100。
- **类型**：`mypy --strict`。所有公开函数必须有完整类型标注。
- **异步**：数据库与网络一律 `async`。禁止在 `async` 函数中调用阻塞 IO。
- **错误**：业务错误抛 `app.domain.errors` 中的异常，**禁止** `raise HTTPException` 出现在 `services/` 以下。
- **日志**：`structlog.get_logger(__name__)`，使用 `event_name` + 结构化字段，禁止 f-string 拼接。
- **配置**：全部经 `app.config.Settings`，禁止 `os.getenv` 散落各处。
- **时间**：一律 UTC 且带时区（`datetime.now(UTC)`），禁止 naive datetime。

### 5.2 Dart / Flutter

- **格式化**：`dart format --line-length 100`。
- **静态检查**：`flutter analyze` 必须零告警（`--fatal-infos`）。
- **UI 库**：3.50 起 Material 从 SDK 拆为独立包，统一 `import 'package:material_ui/material_ui.dart';`；
  `package:flutter/material.dart` 已弃用，出现即让 `--fatal-infos` 失败。
- **状态**：Riverpod `Notifier` / `AsyncNotifier`，状态用 `freezed` 定义。
- **禁止**：Widget 内直接调 API；必须 `Widget → Notifier → UseCase → Repository`。
- **命名**：文件 `snake_case.dart`，类 `PascalCase`，私有成员 `_camelCase`。
- **常量**：`static const` 优先，避免魔法数字。

### 5.3 生成代码

`freezed` / `json_serializable` / `drift_dev` / `retrofit_generator` 产出的
`*.freezed.dart`、`*.g.dart`、`*.drift.dart`、`*.gr.dart` **需要提交到仓库**。

- 修改带注解的源文件后，必须执行 `make app-gen` 并一并提交生成结果。
- CI 会校验生成代码是否最新（`git status --porcelain lib`），不一致直接失败。
- **禁止**手动编辑生成文件，改动会在下次生成时丢失。

### 5.4 注释

只写「为什么」，不写「是什么」。以下情况**必须**注释：

- 非显然的业务规则（如排程中 `elapsed=0` 视为「同日复习」的特殊处理）
- 绕过某个限制的 workaround（注明原因与移除条件）
- 与直觉相反的性能优化

禁止：`// 增加 i`、`// 返回结果` 这类复述代码的注释。

---

## 6. 测试要求

| 改动类型 | 要求 |
| --- | --- |
| `domain/` | 必须新增/更新单元测试，覆盖率 ≥ 90% |
| `services/` | 必须有集成测试（真实 Postgres） |
| API 路由 | 必须有契约测试 |
| Flutter Widget | 关键交互必须有 Widget 测试 |
| 纯文档 | 无需测试 |

**测试必须能独立运行**，不依赖执行顺序、不依赖外部网络。

**禁止**：
- 提交被 `skip` / `xfail` 的测试（除非 PR 中说明原因）
- 为了让测试通过而放宽断言
- 用 mock 替代本应测的真实逻辑（如把排程护栏也 mock 掉）

---

## 7. 提交规范

采用 [Conventional Commits](https://www.conventionalcommits.org/)，**中文正文**。

```
<type>(<scope>): <subject>

<body>

<footer>
```

### type

| type | 用途 |
| --- | --- |
| `feat` | 新功能 |
| `fix` | 修复 bug |
| `docs` | 文档 |
| `refactor` | 重构（不改行为） |
| `test` | 测试 |
| `chore` | 构建、依赖、CI |
| `perf` | 性能优化 |
| `style` | 格式（不改逻辑） |

### scope

`backend` / `mobile` / `docs` / `deploy` / `ci` / `scheduler` / `generation` / `rag` / `agent` …

### 示例

```
feat(scheduler): 实现排程 Agent 与确定性护栏

- 新增 domain/scheduling_tools.py：纯函数工具，供 Agent function calling
- 新增 domain/scheduling_guard.py：单调性/边界/预算校验
- 新增 agents/graphs/scheduler.py：三种学习模式的决策图
- 护栏失败时降级 FSRS 并记录 scheduler.fallback

Closes #12
```

### 规则

- subject 不超过 50 字，**不加句号**。
- 一次提交只做一件事。**禁止** `git add -A` 后提交混杂改动。
- 破坏性变更必须在 footer 写 `BREAKING CHANGE: <说明>`。

---

## 8. 分支与 PR

```
main            ← 受保护，只能通过 PR 合入
└── feat/xxx    ← 功能分支
└── fix/xxx     ← 修复分支
```

- 分支名：`<type>/<简短描述>`，如 `feat/card-crud`、`fix/fsrs-interval`。
- 从 `main` 切出，**禁止**直接提交到 `main`。
- PR 必须：
  1. 通过 CI（lint + typecheck + test）
  2. 至少 1 人 review
  3. 描述中说明「改了什么 / 为什么 / 怎么验证」
  4. 关联 issue（`Closes #N`）

---

## 9. Agent 工作流

### 9.1 标准流程

```
1. 读文档      → 确认需求与设计，明确验收标准
2. 定位         → 用 grep/glob 找到相关代码，理解现有约定
3. 设计         → 复杂改动先写方案（可在 PR 描述中）
4. 实现         → 小步提交，每步可运行
5. 测试         → 新增/更新测试，make check 全绿
6. 自审         → git diff 逐行检查，删除调试代码
7. 提交         → 符合第 7 节规范
```

### 9.2 必须停下来问人类的情况

- 需求文档与设计文档冲突
- 需要新增第三方依赖（尤其是大依赖）
- 需要修改数据库 Schema（影响迁移）
- 需要改变公开 API 契约
- 发现现有代码有安全漏洞
- 任务范围超出 MVP（见需求文档第 8 节）

### 9.3 禁止事项

| 禁止 | 原因 |
| --- | --- |
| ❌ 提交 `print` / `debugPrint` / `console.log` | 调试残留 |
| ❌ 提交注释掉的大段代码 | 用 git 历史 |
| ❌ 提交 `.env` / 密钥 / 证书 | 安全 |
| ❌ 跳过 pre-commit hook（`--no-verify`） | 绕过质量门禁 |
| ❌ 强推 `main`（`push --force`） | 破坏历史 |
| ❌ 修改 `docs/` 中的需求文档来「让代码合规」 | 需求是事实源 |
| ❌ 为通过测试而降低断言强度 | 掩盖问题 |
| ❌ 一次 PR 混合多个不相关改动 | 无法评审 |
| ❌ 引入未在技术栈中的框架 | 架构一致性 |

### 9.4 代码搜索约定

优先用工具而非 shell：

- 找文件：`glob`（不用 `dir /s`、`find`）
- 找内容：`grep`（不用 `findstr`、`grep`）
- 读文件：`read`（不用 `type`、`cat`）

---

## 10. 已知环境限制

| 限制 | 影响 | 规避方式 |
| --- | --- | --- |
| 无法访问 `release-assets.githubusercontent.com` | `sqlite3` 原生库无法下载 | 已在 `mobile/pubspec.yaml` 配置 `source: system`（Windows 用 `winsqlite3.dll`） |
| Flutter 使用国内镜像（`pub.flutter-io.cn`） | 部分包版本滞后 | 正常现象，不要强行升级 |
| `riverpod_lint` / `custom_lint` 与 Riverpod 3.5 冲突 | 无法安装这两个 lint 插件 | 暂不安装；升级后重试 |
| Docker 拉取 `ghcr.io` 可能超时 | TEI 嵌入服务启动失败 | 用 `profiles: [rag]` 按需启动 |
| Flutter 3.50.1 对 AGP 有最低版本要求 | `com.android.application` 9.1.0 直接构建失败：`AGP version 9.1.0 is lower than Flutter's minimum supported version 9.1.1` | `mobile/android/settings.gradle.kts` 已固定 AGP 9.3.1 / Kotlin 2.4.20；**不要降回** |
| Gradle 9.3.1 已进入停止支持倒计时 | 构建出现升级告警，后续 Flutter 版本将拒绝 | `mobile/android/gradle/wrapper/gradle-wrapper.properties` 已固定 `gradle-9.5.0-all` |
| `flutter_local_notifications` / `androidx.core 1.19.0` 要求 `compileSdk ≥ 37` 且需脱糖 | 用 `flutter.compileSdkVersion`（=36）编译失败 | `mobile/android/app/build.gradle.kts` 固定 `compileSdk = 37` + `isCoreLibraryDesugaringEnabled = true` + `desugar_jdk_libs:2.1.5`；`minSdk`/`targetSdk` 不变 |
| `services.gradle.org` 不可达 | Gradle 发行包下载卡死（只下到 3.3MB 就停） | 发行包预置到 `~/.gradle/wrapper/dists/`（本机环境，不进仓库）；镜像源 `https://mirrors.cloud.tencent.com/gradle/` |
| GitHub HTTPS 被重置（`Recv failure: Connection was reset`） | `git clone/push` 走 HTTPS 失败 | 用 SSH：`~/.ssh/config` 已把 `github.com` 指向 `ssh.github.com:443` |

**遇到新限制时，请追加到本表**，不要静默绕过。

---

## 11. 常见任务配方

### 11.1 新增一个 API 端点

```
1. backend/app/routers/<domain>.py      → 定义路由与 Pydantic 入参/出参
2. backend/app/services/<domain>_service.py → 编排逻辑
3. backend/app/infra/repositories/<x>.py    → 数据访问
4. backend/tests/test_<domain>.py           → 契约测试
```

### 11.2 新增一种卡片类型

```
1. backend/app/domain/card_types/<type>.py  → 定义 CardTypeSpec
2. backend/app/domain/card_types/registry.py → 注册
3. mobile/lib/shared/card_renderers/<type>_renderer.dart → 实现 CardRenderer
4. 在 cardRenderers 注册
```

**不需要**修改 `cards` 表、CRUD 路由、搜索逻辑。若需要，说明抽象错了。

### 11.3 修改排程策略

> **排程由 Agent 决策，但受确定性护栏约束。** 修改时三者必须同步，否则会出现「Agent 想排、护栏不让」的静默降级。

```
1. 改 backend/app/domain/scheduling_tools.py  → 数学工具（纯函数）
2. 改 backend/app/domain/scheduling_guard.py  → 护栏规则（纯函数）
3. 改 backend/app/agents/graphs/scheduler.py  → Agent 提示词与图
4. 改 backend/app/domain/fsrs.py              → 仅当护栏兜底逻辑需要变
5. 更新 docs/03-MVP设计文档.md §5.2 与附录 A
6. 跑 tests/test_scheduling_guard.py 确认单调性/边界未被破坏
7. 跑 tests/test_scheduler_snapshot.py 更新快照并人工 review diff
```

**禁止**：只改 Agent 提示词而不改护栏——护栏是质量底线，不能为了「让 Agent 通过」而放宽。

### 11.4 新增学习模式

```
1. backend/app/domain/scheduling_tools.py   → LearnerProfile 增加枚举值
2. backend/app/domain/scheduling_guard.py   → 确认护栏对新模式仍成立
3. docs/02-MVP需求文档.md §5 FR-4.2        → 补充模式说明
4. 前端设置页                              → 增加选项
```

---

## 12. 文档维护

- 代码改动若影响架构、数据模型、API 契约，**必须同步更新 `docs/03-MVP设计文档.md`**。
- 需求变更**只能由人类提出**，Agent 不得自行扩大范围。
- 文档使用中文，代码标识符使用英文。
- Mermaid 图必须能正确渲染（提交前预览）。

---

## 13. 快速自检清单

提交 PR 前逐项确认：

- [ ] `make check` 全绿
- [ ] 新增代码有测试覆盖
- [ ] 无调试残留（`print` / `TODO` 未处理）
- [ ] 无硬编码密钥
- [ ] 分层未被破坏
- [ ] 文档已同步（如涉及架构/API）
- [ ] 提交信息符合规范
- [ ] PR 描述说明了「改了什么 / 为什么 / 怎么验证」
