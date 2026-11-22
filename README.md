# CardSharp 卡锐思

> 可拓展的 AI 卡片助手：用 Agent 把资料变成可运行的卡片集合，用长期学习计划驱动持续记忆。

[![CI](https://github.com/RatherHard/CardSharp/actions/workflows/ci.yml/badge.svg)](https://github.com/RatherHard/CardSharp/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](#license)
[![Python](https://img.shields.io/badge/python-3.12-blue.svg)](https://www.python.org/)
[![Flutter](https://img.shields.io/badge/flutter-3.47.1-blue.svg)](https://flutter.dev/)

---

## 这是什么

CardSharp 不是又一个 Anki 克隆。

它把「卡片」抽象成一种**可运行的内容单元**，把「卡片集合」抽象成**带类型的能力包**——每种类型定义自己的显示格式、运行形式、生成工作流与知识库建立方式。MVP 先落地「记忆卡片」这一最通用的场景，但所有接口都按多类型设计，后续可平移到日程卡片、灵感卡片。

### 与 Anki 类产品的分野

| 维度 | Anki 类 | CardSharp |
| --- | --- | --- |
| 制卡 | 手工录入 | 导入资料，Agent 生成草稿，用户确认 |
| 计划 | 用户自己决定学什么 | Agent 结合记忆曲线与时间预算给出计划 |
| 答疑 | 跳出应用去搜索 | 基于**你自己的卡片集**回答，带引用 |
| 扩展 | 插件（模板级） | 卡片类型（能力包级） |

### 三条设计原则

1. **Agent 产出草稿，用户做最终决策。** 任何 LLM 产物落库前必须显式确认。
2. **LLM 不做确定性计算。** 记忆排程、去重、权限、计费全部是代码逻辑。
3. **类型可插拔。** 新增卡片类型不改核心 CRUD。

---

## 功能（MVP）

- 📥 **资料导入** — PDF / 网页 / 图片 / 纯文本
- ✨ **Agent 制卡** — 抽取知识点 → 生成卡片 → 质检去重 → 预览确认
- 🗂 **卡片管理** — 单层文件夹、标签、全局/集合内搜索
- 🧠 **记忆训练** — FSRS-5 排程、四档评分、**完全离线可用**
- 📅 **长期学习计划** — Agent 规划 7 天任务、每日推送、进度追踪
- 💬 **知识库答疑** — 混合检索 + 引用式流式回答

> 不做：卡片社区、AI 配图、桌面端、多人协作。详见 [MVP 范围外](docs/02-MVP需求文档.md#8-mvp-范围外明确不做)。

---

## 技术栈

| 层 | 选型 |
| --- | --- |
| 移动端 | Flutter 3.47 · Dart 3.13 · Riverpod 3 · go_router 18 · Drift |
| 后端 | Python 3.12 · FastAPI · SQLAlchemy 2 (async) · LangGraph · ARQ |
| 数据 | PostgreSQL 16 + pgvector · Redis 7 · S3 兼容存储 |
| AI | OpenAI 兼容协议（DeepSeek / Qwen）· bge-m3 自托管嵌入 |
| 工程 | uv · ruff · mypy · pytest · GitHub Actions |

选型理由见 [设计文档 · 技术栈选型](docs/03-MVP设计文档.md#2-技术栈选型)。

---

## 快速开始

### 前置要求

- [uv](https://docs.astral.sh/uv/) 0.8+
- [Flutter](https://flutter.dev/) 3.47.1
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) 24+
- `make`（可选，Windows 可用 `choco install make`）

### 五步启动

```bash
git clone github:RatherHard/CardSharp.git
cd CardSharp

make setup                              # 安装前后端依赖
cp backend/.env.example backend/.env    # 配置环境变量（填入 LLM_API_KEY）
make infra-up                           # 启动 Postgres / Redis / MinIO
make migrate                            # 应用数据库迁移
make check                              # 验证环境
```

### 运行

```bash
make dev        # 后端 → http://localhost:8000/docs
make worker     # 异步 Worker（制卡 / 向量化 / 推送）
make app-run    # Flutter App
```

### 常用命令

```bash
make help       # 查看全部命令
make test       # 后端测试
make app-test   # 移动端测试
make fmt        # 格式化
make check      # 提交前完整检查
```

---

## 仓库结构

```
CardSharp/
├── docs/              # 需求与设计文档（事实源）
├── backend/           # FastAPI + LangGraph
│   └── app/
│       ├── routers/   # HTTP 层
│       ├── services/  # 用例编排
│       ├── domain/    # 纯业务逻辑（FSRS 等）
│       ├── agents/    # LangGraph 图与 Prompt
│       ├── infra/     # 仓储 / LLM / 存储 / 队列
│       └── workers/   # ARQ 异步任务
├── mobile/            # Flutter
│   └── lib/
│       ├── core/      # 路由 / 主题 / 网络 / 存储
│       ├── features/  # 按功能垂直切分
│       └── shared/    # 跨 feature 复用
├── deploy/            # Docker Compose
└── .github/           # CI 与模板
```

---

## 文档

| 文档 | 内容 |
| --- | --- |
| [项目提案](docs/00-项目提案.md) | 问题定义与功能设想 |
| [MVP 设计草案](docs/01-MVP设计草案.md) | 早期草稿（已被取代，保留追溯） |
| [MVP 需求文档](docs/02-MVP需求文档.md) | 范围、用户故事、验收标准、指标、里程碑 |
| [MVP 设计文档](docs/03-MVP设计文档.md) | 架构、数据模型、模块与接口设计 |
| [AGENTS.md](AGENTS.md) | AI 编码代理工作指南 |
| [CONTRIBUTING.md](CONTRIBUTING.md) | 人类贡献者协作规范 |

---

## 路线图

| 版本 | 内容 |
| --- | --- |
| **v0.1 (MVP)** | 记忆卡片全链路、Agent 制卡、FSRS 复习、计划、RAG 答疑 |
| v1.1 | 扫描件 OCR、AI 配图、性能优化 |
| v1.5 | Web 制卡台、桌面端、厂商推送通道 |
| v2.0 | 卡片社区、日程卡片、灵感卡片、多人共享 |

---

## 已知限制

| 限制 | 说明 |
| --- | --- |
| `sqlite3` 原生库 | 无法访问 GitHub Release CDN，已改用系统 SQLite（`source: system`） |
| `riverpod_lint` | 与 Riverpod 3.5 版本冲突，暂未启用 |
| 仅移动端 | 桌面/Web 端排入 v1.5 |

---

## 贡献

欢迎贡献！请先阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

```bash
git switch -c feat/your-feature
# ... 开发 ...
make check
git commit -m "feat(scope): 描述"
git push origin feat/your-feature
```

---

## License

Proprietary. 未经授权禁止复制、分发或商用。
