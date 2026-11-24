# 贡献指南

> 面向人类贡献者的协作规范。AI 编码代理请阅读 [AGENTS.md](AGENTS.md)。

## 目录

- [1. 环境准备](#1-环境准备)
- [2. 项目结构](#2-项目结构)
- [3. 分支模型](#3-分支模型)
- [4. 提交信息规范](#4-提交信息规范)
- [5. 代码评审](#5-代码评审)
- [6. 质量门禁](#6-质量门禁)
- [7. 发布流程](#7-发布流程)
- [8. 问题反馈](#8-问题反馈)

---

## 1. 环境准备

### 1.1 必需工具

| 工具 | 版本 | 用途 | 安装 |
| --- | --- | --- | --- |
| Git | 2.40+ | 版本控制 | [git-scm.com](https://git-scm.com/) |
| Python | 3.12 | 后端 | 由 `uv` 自动管理 |
| uv | 0.8+ | Python 包管理 | `winget install astral-sh.uv` |
| Flutter | 3.50.1 | 移动端 | [flutter.dev](https://flutter.dev/) |
| Docker Desktop | 24+ | 本地依赖 | [docker.com](https://www.docker.com/products/docker-desktop/) |

可选：`make`（Windows 可用 `choco install make`，或直接执行 `Makefile` 中的命令）。

### 1.2 首次初始化

```bash
git clone github:RatherHard/CardSharp.git
cd CardSharp

# 1. 安装前后端依赖
make setup

# 2. 配置环境变量
cp backend/.env.example backend/.env
#    编辑 backend/.env，填入 LLM_API_KEY（向项目负责人索取）

# 3. 启动本地依赖（Postgres / Redis / MinIO）
make infra-up

# 4. 应用数据库迁移
make migrate

# 5. 验证
make check
```

### 1.3 启动开发

```bash
# 终端 1：后端（http://localhost:8000/docs）
make dev

# 终端 2：异步 Worker（制卡、向量化、推送）
make worker

# 终端 3：移动端
make app-run
```

### 1.4 常见问题

<details>
<summary><b>flutter test 报错「Building native assets failed」</b></summary>

网络无法访问 `release-assets.githubusercontent.com`。项目已在 `mobile/pubspec.yaml` 配置
`hooks.user_defines.sqlite3.source: system`，使用系统 SQLite。若仍失败，确认：

- Windows：`C:\Windows\System32\winsqlite3.dll` 存在
- Linux：`libsqlite3.so` 已安装（`apt install libsqlite3-dev`）
- macOS：系统自带 `libsqlite3.dylib`

</details>

<details>
<summary><b>Docker 拉取镜像超时</b></summary>

配置国内镜像加速器（Docker Desktop → Settings → Docker Engine）：

```json
{
  "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"]
}
```

TEI 嵌入服务（`ghcr.io`）可用 `--profile rag` 按需启动，不启动不影响主流程。

</details>

<details>
<summary><b>pre-commit 未生效</b></summary>

```bash
cd backend && uv run pre-commit install
```

</details>

---

## 2. 项目结构

```
CardSharp/
├── docs/          # 需求与设计文档（事实源）
├── backend/       # FastAPI + LangGraph
├── mobile/        # Flutter
├── deploy/        # Docker Compose
└── .github/       # CI 与模板
```

**动手前请先读** [docs/02-MVP需求文档.md](docs/02-MVP需求文档.md) 与 [docs/03-MVP设计文档.md](docs/03-MVP设计文档.md)。

---

## 3. 分支模型

采用简化的 **GitHub Flow**：

```
main
 ├── feat/card-crud       功能
 ├── fix/fsrs-interval    修复
 ├── docs/api-spec         文档
 └── chore/upgrade-deps    杂项
```

### 规则

| 规则 | 说明 |
| --- | --- |
| `main` 受保护 | 禁止直接 push，必须经 PR |
| 分支从 `main` 切出 | `git switch -c feat/xxx` |
| 分支名 | `<type>/<kebab-case>`，type 同提交类型 |
| 生命周期 | 合入后自动删除 |
| 同步 | 每天 `git pull --rebase origin main` |

### 合并策略

- 默认 **Squash and merge**（保持 `main` 线性历史）。
- PR 标题即最终提交信息，必须符合第 4 节规范。
- 需要保留多个提交时，在 PR 中说明并改用 **Rebase and merge**。

---

## 4. 提交信息规范

采用 [Conventional Commits](https://www.conventionalcommits.org/)。

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 4.1 type

| type | 触发版本 | 说明 |
| --- | --- | --- |
| `feat` | minor | 新功能 |
| `fix` | patch | 修复 |
| `docs` | — | 文档 |
| `refactor` | — | 重构（不改行为） |
| `test` | — | 测试 |
| `chore` | — | 构建、依赖、CI |
| `perf` | patch | 性能 |
| `style` | — | 格式 |

### 4.2 示例

```
feat(generation): 支持 PDF 批量导入并生成卡片草稿

- 新增 POST /sources 支持 multipart 上传
- 解析阶段使用 pypdf 抽取文本层
- 生成任务异步执行，SSE 推送进度

Closes #23
```

```
fix(fsrs): 修正 elapsed=0 时稳定度未增长的问题

同日复习应视为「短期记忆」，不增加 stability。
补充属性测试覆盖该分支。

Fixes #41
```

### 4.3 规则

- subject 用**中文**，不超过 50 字，**不加句号**。
- body 说明「为什么」，不重复「改了什么」（diff 已说明）。
- 破坏性变更：footer 写 `BREAKING CHANGE: <迁移说明>`。
- 关联 issue：`Closes #N` / `Fixes #N` / `Refs #N`。

---

## 5. 代码评审

### 5.1 提 PR 前自检

- [ ] `make check` 全绿
- [ ] 新增/修改的代码有测试
- [ ] 无调试残留、无注释掉的大段代码
- [ ] 无硬编码密钥
- [ ] 文档已同步（涉及架构/API 时）
- [ ] PR 描述完整（见 5.2）

### 5.2 PR 描述模板

```markdown
## 改了什么

<!-- 一句话概括 -->

## 为什么

<!-- 关联需求/issue，说明动机 -->

## 怎么验证

<!-- 复现步骤、测试命令、截图 -->

## 影响面

- [ ] 数据库 Schema 变更（含迁移）
- [ ] API 契约变更
- [ ] 需要同步更新文档
- [ ] 破坏性变更
```

### 5.3 评审规范

**评审者**：

| 关注点 | 说明 |
| --- | --- |
| 正确性 | 边界条件、错误处理、并发 |
| 分层 | 是否违反 `routers → services → domain` |
| 测试 | 是否覆盖关键分支 |
| 可读性 | 命名、注释、复杂度 |
| 安全 | 越权、注入、密钥 |

**评审意见分级**（请在评论前缀标注）：

- `[blocking]` — 必须修改才能合入
- `[suggestion]` — 建议修改，可讨论
- `[nit]` — 细节，不阻塞
- `[question]` — 需要作者解释

**作者**：

- 24 小时内响应评审意见。
- 不同意时给出理由，**不要沉默地不修**。
- 修改后回复「已修改」并 resolve 对应会话。

### 5.4 合入条件

1. CI 全绿
2. 至少 1 个 approve
3. 所有 `[blocking]` 已解决
4. 无冲突

---

## 6. 质量门禁

### 6.1 本地

```bash
make check      # lint + typecheck + test（前后端）
make fmt        # 自动格式化
```

### 6.2 CI

每次 push 与 PR 触发 `.github/workflows/ci.yml`：

| Job | 内容 |
| --- | --- |
| `backend` | ruff check / ruff format --check / mypy / pytest + 覆盖率 |
| `mobile` | 生成代码检查 / flutter analyze / flutter test |

**CI 失败不得合入。** 不要通过 `--no-verify` 或跳过测试来绕过。

### 6.3 覆盖率要求

| 模块 | 最低 |
| --- | --- |
| `backend/app/domain/` | 90% |
| `backend/app/services/` | 70% |
| `mobile/lib/` | 60% |

---

## 7. 发布流程

### 7.1 版本号

遵循 [语义化版本](https://semver.org/lang/zh-CN/)：`MAJOR.MINOR.PATCH`。

- MVP 阶段：`0.x.y`
- 正式版：`1.0.0`

### 7.2 发布步骤

```bash
# 1. 从 main 切出发布分支
git switch -c release/v0.1.0

# 2. 更新版本号
#    backend/pyproject.toml → version
#    mobile/pubspec.yaml    → version

# 3. 更新 CHANGELOG.md（由提交信息生成）
# 4. 提交并打标签
git commit -am "chore(release): v0.1.0"
git tag -a v0.1.0 -m "v0.1.0"

# 5. 推送并创建 GitHub Release
git push origin release/v0.1.0 --tags
```

### 7.3 回滚

生产问题优先 **revert 提交**，不要 `git reset`：

```bash
git revert <commit-sha>
```

---

## 8. 问题反馈

### 8.1 提交 Issue

使用 [Issue 模板](.github/ISSUE_TEMPLATE/)，包含：

- **Bug**：复现步骤、期望行为、实际行为、环境信息、日志
- **Feature**：用户故事（作为…我希望…以便…）、验收标准、优先级

### 8.2 安全漏洞

**不要公开提 Issue。** 直接联系项目负责人。

### 8.3 讨论

- 设计讨论：在对应 Issue 下评论
- 快速问题：项目群

---

## 附录：常用命令速查

| 命令 | 说明 |
| --- | --- |
| `make setup` | 初始化依赖 |
| `make infra-up` | 启动本地依赖 |
| `make dev` | 后端开发服务器 |
| `make worker` | 异步 Worker |
| `make migrate` | 应用迁移 |
| `make migration m="描述"` | 生成迁移 |
| `make test` | 后端测试 |
| `make app-test` | 移动端测试 |
| `make app-gen` | 生成代码 |
| `make check` | 完整检查 |
| `make fmt` | 格式化 |
