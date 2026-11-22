# CardSharp 卡锐思 · MVP 设计文档

| 项 | 内容 |
| --- | --- |
| 文档版本 | v1.0 |
| 更新日期 | 2026-11-22 |
| 文档状态 | 待评审 |
| 上游文档 | [MVP 需求文档](02-MVP需求文档.md) |
| 已确认决策 | Flutter + FastAPI + Postgres；仅移动端；云端为主 + 本地缓存；社区与 AI 配图不进 MVP |

---

## 1. 概述

本文档描述 CardSharp MVP 的技术实现方案。它回答三个问题：

1. **怎么搭**：技术栈、架构、数据模型、模块边界。
2. **怎么扩展**：如何让「记忆卡片」之外的类型（日程、灵感）未来能低成本接入。
3. **怎么验证**：关键流程、测试策略、可观测性如何保证质量。

### 1.1 设计目标

| 目标 | 说明 |
| --- | --- |
| G1 端到端闭环 | 资料 → 卡片 → 计划 → 复习 → 答疑，五段全通 |
| G2 确定性优先 | 排程等关键逻辑用确定性算法，LLM 只做「生成」与「策略」 |
| G3 类型可插拔 | 新增卡片类型不改核心 CRUD |
| G4 离线可用 | 复习链路完全离线，写操作可重放 |
| G5 成本可控 | 单用户月成本 ≤ ¥3，嵌入自托管 |

### 1.2 关键设计原则

1. **Agent 产出草稿，用户做最终决策。** 任何 LLM 产物落库前必须经过显式确认。
2. **LLM 不做确定性计算。** 记忆排程、去重、权限、计费全部是代码逻辑。
3. **深模块、窄接口。** 每个模块对外只暴露一个稳定的接口，内部实现可替换（如嵌入模型、LLM 供应商）。
4. **所有写操作幂等。** 客户端生成 `idempotency_key`，服务端去重，支撑离线重放。
5. **数据模型按「类型」抽象，不按「记忆卡片」硬编码。** 卡片内容存 `jsonb`，类型定义驱动校验。

---

## 2. 技术栈选型

### 2.1 选型总表

| 层 | 选型 | 版本 | 理由 |
| --- | --- | --- | --- |
| 移动端 | Flutter | 3.24+ / Dart 3.5+ | 单代码库覆盖 iOS + Android；后续可低成本补 Web/Desktop |
| 状态管理 | Riverpod + freezed | 2.5 / 2.5 | 编译期安全、易测试、无 BuildContext 依赖 |
| 路由 | go_router | 14+ | 声明式、支持深链（推送跳转） |
| 本地库 | Drift (SQLite) | 2.20+ | 类型安全 SQL、迁移成熟、支持复杂查询 |
| 网络 | dio + retrofit | 5.x / 4.x | 拦截器、重试、类型安全 |
| 后端 | Python + FastAPI | 3.12 / 0.115+ | 异步原生、OpenAPI 自动生成、AI 生态最全 |
| ORM | SQLAlchemy 2.0 (async) + Alembic | 2.0 | 成熟、异步、迁移工具完善 |
| 数据库 | PostgreSQL + pgvector | 16 / 0.7+ | 关系 + 向量一体，少一个组件 |
| 全文检索 | pg_trgm + tsvector | 内置 | 中文模糊搜索够用，避免引入 ES |
| Agent 编排 | LangGraph | 0.2+ | 有状态图、`interrupt` 原生支持人工确认、Postgres checkpointer |
| LLM 接入 | OpenAI 兼容协议（`openai` SDK） | 1.x | 一套代码切 DeepSeek / Qwen / GPT |
| 异步任务 | Redis + ARQ | 7 / 0.26+ | asyncio 原生，比 Celery 轻 |
| 嵌入 | bge-m3 自托管（TEI） | — | 中文效果好、1024 维、无按 token 费用 |
| 对象存储 | S3 兼容（MinIO / 阿里云 OSS） | — | 标准协议，本地与云一致 |
| 推送 | FCM + APNs | — | 双端标准方案 |
| 可观测 | OpenTelemetry + Langfuse + Sentry | — | 链路 + LLM 追踪 + 错误 |
| 部署 | Docker Compose → 云托管 | — | MVP 阶段单机足够 |

### 2.2 关键 ADR

#### ADR-001：为什么选 Flutter 而不是 React Native

| 维度 | Flutter | React Native |
| --- | --- | --- |
| 卡片翻转/手势动画 | 自绘引擎，60fps 稳定 | 依赖原生桥，复杂动画需额外优化 |
| 多端延展 | 一套代码可出 Web/Desktop | 需额外适配 |
| 团队语言 | Dart（学习成本） | TypeScript（若团队是 TS 背景更优） |

**决策**：选 Flutter。核心理由是**复习场景高度依赖流畅的卡片交互与动画**，且后续要补桌面端。若团队为纯 TS 背景，RN 亦可接受，但需提前评估动画性能。

#### ADR-002：为什么用 LangGraph 而不是自研编排

- 需要**有状态的多轮图执行**（制卡流水线有 5 个阶段，答疑需要工具调用循环）。
- 需要**人工介入**（`interrupt` → 前端确认 → `resume`），自研需处理序列化与恢复。
- 需要**可观测**（Langfuse 原生集成）。

**决策**：用 LangGraph，但**通过一层 `AgentRuntime` 接口隔离**，避免框架锁定。若未来替换，只改适配层。

#### ADR-003：为什么排程不用 LLM

LLM 输出不确定，且无法保证单调性（间隔应随记忆强度递增）。FSRS 是经过大规模验证的确定性算法。

**决策**：排程 = FSRS 纯函数；Agent 只做**策略层**（时间预算、跨集优先级、目标拆解、自然语言解释）。

#### ADR-004：为什么用 pgvector 而不是独立向量库

- MVP 数据量 < 1000 万向量，pgvector HNSW 足够。
- 少一个组件 = 少一套运维、备份、一致性保障。
- 支持**事务内**同时写业务数据与向量，避免双写不一致。

**决策**：pgvector。若未来 QPS 撑不住，再迁 Qdrant（通过 `VectorStore` 接口隔离）。

#### ADR-005：为什么「云端为主 + 本地缓存」而不是本地优先

本地优先（CRDT）能带来最好的离线体验，但 MVP 阶段冲突合并的复杂度会拖慢交付。

**决策**：服务端为唯一事实源；客户端做**读缓存 + 写 Outbox 队列**。离线可读、可写（复习记录），联网重放。冲突时以服务端为准并提示用户。

---

## 3. 系统架构

### 3.1 上下文图（C4 Level 1）

```mermaid
flowchart TB
    User(["学习者"])
    subgraph CardSharp["CardSharp 系统"]
        App["Flutter 移动端"]
        API["FastAPI 后端"]
        Worker["异步 Worker"]
        DB[("PostgreSQL<br/>+ pgvector")]
        Redis[("Redis")]
        OSS[("对象存储")]
    end
    LLM["LLM 供应商<br/>DeepSeek / Qwen"]
    Embed["嵌入服务<br/>bge-m3 (TEI)"]
    Push["FCM / APNs"]

    User -->|使用| App
    App -->|HTTPS / SSE| API
    API --> DB
    API --> Redis
    API --> OSS
    API -->|生成 / 答疑| LLM
    API -->|向量化| Embed
    Worker --> DB
    Worker --> LLM
    Worker --> Embed
    Worker -->|推送| Push
    Push -->|通知| App
```

### 3.2 容器图（C4 Level 2）

```mermaid
flowchart LR
    subgraph Client["Flutter App"]
        UI["UI 层<br/>Screens / Widgets"]
        State["状态层<br/>Riverpod Notifiers"]
        Repo["仓库层<br/>Repository"]
        Local["本地库<br/>Drift + Outbox"]
        Remote["远程层<br/>API Client"]
        UI --> State --> Repo
        Repo --> Local
        Repo --> Remote
    end

    subgraph Backend["FastAPI 后端"]
        Router["API 路由层<br/>routers/"]
        Service["应用服务层<br/>services/"]
        Domain["领域层<br/>domain/"]
        Infra["基础设施层<br/>infra/"]
        Router --> Service --> Domain
        Service --> Infra
    end

    subgraph Async["异步 Worker (ARQ)"]
        GenJob["制卡任务"]
        EmbedJob["向量化任务"]
        NotifyJob["推送任务"]
    end

    Remote -->|REST / SSE| Router
    Infra --> DB[("PostgreSQL")]
    Infra --> Redis[("Redis")]
    Infra --> OSS[("OSS")]
    Async --> DB
    Async --> Redis
```

### 3.3 分层职责

| 层 | 职责 | 禁止 |
| --- | --- | --- |
| `routers/` | HTTP 入参校验、鉴权、响应序列化 | 写业务逻辑 |
| `services/` | 用例编排、事务边界 | 直接写 SQL |
| `domain/` | 纯业务规则（FSRS、去重、状态机） | 依赖框架、IO |
| `infra/` | 仓储实现、LLM 客户端、对象存储、队列 | 业务判断 |

**依赖方向**：`routers → services → domain`，`services → infra`（通过接口）。`domain` 不依赖任何外层。

---

## 4. 数据模型

### 4.1 ER 图

```mermaid
erDiagram
    users ||--o{ devices : has
    users ||--o{ folders : owns
    users ||--o{ decks : owns
    users ||--o{ tags : owns
    users ||--o{ conversations : owns
    users ||--o{ study_plans : owns
    users ||--o{ sources : uploads

    folders ||--o{ decks : contains
    decks ||--o{ cards : contains
    decks ||--o{ deck_sources : links
    decks ||--o{ generation_jobs : produces

    sources ||--o{ deck_sources : linked

    cards ||--o| review_states : has
    cards ||--o{ review_logs : logs
    cards ||--o{ card_tags : tagged
    tags ||--o{ card_tags : tags

    cards ||--o{ chunks : indexed_as
    sources ||--o{ chunks : indexed_as

    conversations ||--o{ messages : contains
    messages ||--o{ citations : references
    cards ||--o{ citations : cited_by

    study_plans ||--o{ plan_days : contains
    plan_days ||--o{ plan_items : contains

    generation_jobs ||--o{ drafts : produces
    decks ||--o{ drafts : staging
```

### 4.2 核心表定义

#### users

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | uuid PK | |
| email | citext UNIQUE | 可空 |
| phone | varchar(20) UNIQUE | 可空 |
| password_hash | text | Argon2id |
| display_name | varchar(50) | |
| timezone | varchar(50) | 默认 `Asia/Shanghai` |
| settings | jsonb | 通知、静默时段等 |
| created_at / updated_at | timestamptz | |
| deleted_at | timestamptz | 软删除 |

> 约束：`email` 与 `phone` 至少一个非空。

#### folders

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | uuid PK | |
| user_id | uuid FK | |
| name | varchar(100) | |
| sort_order | int | |
| created_at / updated_at | timestamptz | |

> 单层：无 `parent_id`。

#### decks

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | uuid PK | |
| user_id | uuid FK | |
| folder_id | uuid FK NULL | 空 = 未分类 |
| card_type | varchar(32) | MVP 固定 `memory` |
| title | varchar(200) | |
| description | text | |
| color | varchar(9) | |
| config | jsonb | 见 §4.3 |
| stats | jsonb | 冗余统计，异步更新 |
| created_at / updated_at / deleted_at | timestamptz | |

索引：`(user_id, folder_id)`、`(user_id, updated_at DESC)`。

#### cards

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | uuid PK | |
| deck_id | uuid FK | |
| card_type | varchar(32) | 冗余，避免 join |
| fields | jsonb | 类型相关字段，见 §4.4 |
| content_hash | char(64) | 去重用 |
| sort_order | int | |
| created_at / updated_at / deleted_at | timestamptz | |

索引：`(deck_id, sort_order)`、`(deck_id, content_hash)`、`fields` 上的 GIN（搜索）。

#### review_states

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| card_id | uuid PK | 与 users 组合主键 |
| user_id | uuid PK | |
| stability | real | FSRS S，单位天 |
| difficulty | real | FSRS D，1–10 |
| due_at | timestamptz | |
| last_review_at | timestamptz | |
| reps | int | 总复习次数 |
| lapses | int | 遗忘次数 |
| state | smallint | 0=New 1=Learning 2=Review 3=Relearning |
| step | smallint | 学习步 |

索引：`(user_id, due_at)` —— 复习队列核心查询。

#### review_logs

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | uuid PK | **客户端生成**，幂等键 |
| card_id | uuid FK | |
| user_id | uuid FK | |
| rating | smallint | 1–4 |
| state_before / state_after | jsonb | 前后状态快照 |
| elapsed_ms | int | |
| reviewed_at | timestamptz | 客户端时间 |
| created_at | timestamptz | 服务端时间 |

唯一约束：`(id)` 主键即幂等键。`(user_id, reviewed_at)` 建索引用于统计。

#### sources

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | uuid PK | |
| user_id | uuid FK | |
| kind | varchar(16) | pdf / url / image / text |
| uri | text | 对象存储 key 或 URL |
| filename | varchar(255) | |
| mime | varchar(100) | |
| size_bytes | bigint | |
| content_hash | char(64) | 去重 |
| extracted_text | text | 抽取结果 |
| page_count | int | |
| status | varchar(16) | pending / parsing / ready / failed |
| error | text | |
| created_at / updated_at | timestamptz | |

#### generation_jobs

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | uuid PK | |
| user_id | uuid FK | |
| deck_id | uuid FK | |
| status | varchar(16) | 见 §6.4 状态机 |
| stage | varchar(32) | |
| progress | smallint | 0–100 |
| config | jsonb | 生成配置 |
| source_ids | uuid[] | |
| error | text | |
| token_usage | jsonb | 成本追踪 |
| started_at / finished_at | timestamptz | |
| created_at | timestamptz | |

#### drafts

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | uuid PK | |
| job_id | uuid FK | |
| user_id | uuid FK | |
| deck_id | uuid FK | |
| fields | jsonb | 同 cards.fields |
| selected | boolean | 默认 true |
| quality | jsonb | `{dup_score, flags}` |
| expires_at | timestamptz | 7 天 |
| created_at | timestamptz | |

#### chunks（知识库）

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | uuid PK | |
| user_id | uuid FK | |
| deck_id | uuid FK | |
| source_type | varchar(16) | card / document |
| source_id | uuid | 卡片或资料 ID |
| content | text | |
| embedding | vector(1024) | |
| tsv | tsvector | 全文检索 |
| metadata | jsonb | |
| created_at | timestamptz | |

索引：HNSW `(embedding vector_cosine_ops)`、GIN `(tsv)`、`(deck_id, source_type)`。

#### conversations / messages / citations

```sql
conversations(id, user_id, title, scope_deck_ids uuid[], created_at, updated_at)
messages(id, conversation_id, role, content, token_usage jsonb, created_at)
citations(id, message_id, chunk_id, card_id, score real, snippet text)
```

#### study_plans / plan_days / plan_items

```sql
study_plans(id, user_id, goal text, deadline date, daily_minutes int,
            desired_retention real, status varchar, created_at)
plan_days(id, plan_id, day date, planned_review int, planned_new int,
          estimated_minutes int, rationale text, completed_at timestamptz)
plan_items(id, plan_day_id, deck_id, card_count int, kind varchar)
```

#### devices

```sql
devices(id, user_id, platform varchar, model varchar, os_version varchar,
        push_token text, last_seen_at timestamptz)
```

### 4.3 deck.config Schema

```jsonc
{
  "card_type": "memory",
  "display": {
    "template": "front_back",      // 渲染模板
    "theme": "default",
    "font_scale": 1.0
  },
  "runner": {
    "scheduler": "fsrs",           // 运行器
    "desired_retention": 0.9,      // 0.8–0.95
    "new_per_day": 20,
    "max_reviews_per_day": 200,
    "learning_steps": [1, 10]      // 分钟
  },
  "generator": {
    "graph": "cardsmith.memory.v1",
    "max_cards": 100,
    "difficulty": "standard",      // basic / standard / advanced
    "language": "auto"
  },
  "knowledge": {
    "enabled": true,
    "chunk_strategy": "card",      // card / document / hybrid
    "embedding_model": "bge-m3"
  }
}
```

校验：Pydantic 模型按 `card_type` 动态选择 Schema，非法配置返回 422。

### 4.4 cards.fields Schema（memory 类型）

```jsonc
{
  "front": "线粒体的主要功能是什么？",
  "back": "通过有氧呼吸产生 ATP，为细胞提供能量。",
  "images": [],                    // [{key, width, height}]
  "hint": "与能量代谢有关",
  "extra": "细胞器章节 · 第 3 节"
}
```

约束：`front` ≤ 200 字，`back` ≤ 500 字，均不可为空。

### 4.5 扩展点：新增卡片类型

新增 `schedule` 类型只需：

1. 后端注册 `CardTypeSpec`（Pydantic Schema + 生成 graph 名 + 运行器名 + 默认 config）。
2. 前端注册 `CardRenderer`（`Widget build(Card card)`）。
3. 无需修改 `cards` 表结构、CRUD 路由、搜索逻辑。

```python
# domain/card_types/registry.py
CARD_TYPES: dict[str, CardTypeSpec] = {}

def register(spec: CardTypeSpec) -> None:
    CARD_TYPES[spec.type_id] = spec
```

---

## 5. 后端模块设计

### 5.1 目录结构

```
backend/
├── app/
│   ├── main.py                  # FastAPI 实例
│   ├── config.py                # pydantic-settings
│   ├── deps.py                  # 依赖注入
│   ├── routers/
│   │   ├── auth.py
│   │   ├── folders.py
│   │   ├── decks.py
│   │   ├── cards.py
│   │   ├── reviews.py
│   │   ├── sources.py
│   │   ├── generation.py
│   │   ├── plans.py
│   │   ├── chat.py
│   │   └── devices.py
│   ├── services/
│   │   ├── auth_service.py
│   │   ├── deck_service.py
│   │   ├── card_service.py
│   │   ├── review_service.py
│   │   ├── generation_service.py
│   │   ├── plan_service.py
│   │   ├── chat_service.py
│   │   └── search_service.py
│   ├── domain/
│   │   ├── fsrs.py              # 纯函数排程
│   │   ├── dedup.py             # 去重
│   │   ├── card_types/
│   │   │   ├── base.py          # CardTypeSpec 协议
│   │   │   ├── registry.py
│   │   │   └── memory.py
│   │   └── errors.py
│   ├── agents/
│   │   ├── runtime.py           # AgentRuntime 接口 + LangGraph 实现
│   │   ├── graphs/
│   │   │   ├── cardsmith.py     # 制卡
│   │   │   ├── planner.py       # 计划
│   │   │   ├── tutor.py         # 答疑
│   │   │   └── conductor.py     # 统筹（P1）
│   │   ├── prompts/
│   │   └── tools/
│   ├── infra/
│   │   ├── db.py                # async engine / session
│   │   ├── models/              # SQLAlchemy ORM
│   │   ├── repositories/
│   │   ├── llm.py               # LLM 客户端封装
│   │   ├── embedding.py         # 嵌入客户端
│   │   ├── storage.py           # 对象存储
│   │   ├── queue.py             # ARQ
│   │   └── push.py              # FCM / APNs
│   └── workers/
│       ├── generation.py
│       ├── embedding.py
│       └── notification.py
├── migrations/                  # Alembic
├── tests/
└── pyproject.toml
```

### 5.2 FSRS 引擎（`domain/fsrs.py`）

**纯函数、无 IO、可完全单测。** 实现参考 FSRS-5 公式。

```python
DECAY = -0.5
FACTOR = 19 / 81

def retrievability(elapsed_days: float, stability: float) -> float:
    """R(t, S) = (1 + FACTOR * t / S) ^ DECAY"""
    return (1 + FACTOR * elapsed_days / stability) ** DECAY

def next_interval(stability: float, desired_retention: float) -> float:
    """I = (S / FACTOR) * (r ^ (1/DECAY) - 1)"""
    return (stability / FACTOR) * (desired_retention ** (1 / DECAY) - 1)

def initial_stability(rating: int, w: list[float]) -> float:
    return w[rating - 1]

def initial_difficulty(rating: int, w: list[float]) -> float:
    d = w[4] - math.exp(w[5] * (rating - 1)) + 1
    return min(max(d, 1.0), 10.0)

def next_difficulty(d: float, rating: int, w: list[float]) -> float:
    d2 = d - w[6] * (rating - 3)
    d3 = w[7] * initial_difficulty(4, w) + (1 - w[7]) * d2
    return min(max(d3, 1.0), 10.0)

def next_stability_on_recall(s, d, r, rating, w) -> float:
    hard_penalty = w[15] if rating == 2 else 1.0
    easy_bonus = w[16] if rating == 4 else 1.0
    return s * (
        1
        + math.exp(w[8])
        * (11 - d)
        * s ** (-w[9])
        * (math.exp(w[10] * (1 - r)) - 1)
        * hard_penalty
        * easy_bonus
    )

def next_stability_on_forget(s, d, r, w) -> float:
    return w[11] * d ** (-w[12]) * ((s + 1) ** w[13] - 1) * math.exp(w[14] * (1 - r))
```

**核心接口**

```python
@dataclass(frozen=True)
class ReviewState:
    stability: float
    difficulty: float
    due_at: datetime
    last_review_at: datetime | None
    reps: int
    lapses: int
    state: CardState
    step: int

def schedule(
    state: ReviewState,
    rating: Literal[1, 2, 3, 4],
    now: datetime,
    config: RunnerConfig,
) -> tuple[ReviewState, ReviewLog]:
    """确定性排程。同输入必同输出，无副作用。"""
```

**测试要求**：属性测试（间隔单调性、边界钳制、幂等性）+ 官方 FSRS 测试向量对齐。

### 5.3 制卡流水线（`services/generation_service.py`）

#### 状态机

```mermaid
stateDiagram-v2
    [*] --> PENDING
    PENDING --> PARSING: worker 取任务
    PARSING --> EXTRACTING: 文本抽取完成
    PARSING --> FAILED: 解析失败
    EXTRACTING --> DRAFTING: 知识点抽取完成
    EXTRACTING --> FAILED: 抽取失败
    DRAFTING --> QC: 卡片生成完成
    DRAFTING --> CANCELLED: 用户取消
    QC --> AWAITING_REVIEW: 去重与质检完成
    AWAITING_REVIEW --> COMMITTING: 用户确认
    AWAITING_REVIEW --> CANCELLED: 用户取消
    COMMITTING --> DONE: 落库完成
    COMMITTING --> FAILED: 落库失败
    FAILED --> PARSING: 重试
```

#### 阶段职责

| 阶段 | 实现 | 输出 |
| --- | --- | --- |
| PARSING | `pypdf` 抽文本；URL 走 `trafilatura`；图片走视觉模型 | `sources.extracted_text` |
| EXTRACTING | LLM 结构化输出：知识点列表（JSON Schema） | `list[KnowledgePoint]` |
| DRAFTING | LLM 逐知识点生成卡片（批量 5 张/次，控制上下文） | `list[Draft]` |
| QC | ① `content_hash` 精确去重 ② 嵌入余弦相似度 > 0.9 标记疑似重复 ③ 规则校验（长度、自包含、禁否定式） | `quality` 字段 |
| COMMITTING | 事务内批量插入 `cards` + 初始化 `review_states` + 投递向量化任务 | 卡片 |

#### 关键实现要点

- **流式进度**：Worker 每完成一个阶段 `UPDATE generation_jobs SET stage, progress`，前端通过 SSE 或轮询读取。
- **取消**：`generation_jobs.status = CANCELLED` 作为取消信号，Worker 在每个阶段边界检查。
- **幂等**：`COMMITTING` 阶段用 `(deck_id, content_hash)` 唯一索引兜底，重复提交不产生重复卡片。
- **成本追踪**：每次 LLM 调用累加 `token_usage`。

#### 生成 Prompt 的核心约束（写入系统提示）

```
1. 每张卡片只考查一个知识点。
2. 卡片必须自包含：禁止使用「上文」「该概念」「如图」等指代。
3. 正面是问题或提示，背面是答案；正面不得包含答案。
4. 禁止生成是非题、填空题式碎片。
5. 输出严格 JSON，符合给定 Schema。
```

### 5.4 RAG 知识库（`services/chat_service.py` + `infra/embedding.py`）

#### 索引策略

| 来源 | 切分 | 说明 |
| --- | --- | --- |
| 卡片 | 1 卡 = 1 chunk | `front + "\n" + back + "\n" + tags` |
| 资料原文 | 512 token / 重叠 64 | 按段落边界切分，保留 `source_id` 与页码 |

#### 检索流程

```mermaid
flowchart LR
    Q["用户问题"] --> Rewrite["查询改写<br/>（多轮时补全指代）"]
    Rewrite --> Hybrid["混合检索"]
    Hybrid --> Vec["向量检索<br/>pgvector HNSW top-20"]
    Hybrid --> Kw["关键词检索<br/>tsvector top-20"]
    Vec --> RRF["RRF 融合"]
    Kw --> RRF
    RRF --> Rerank["重排<br/>（可选，P1）"]
    Rerank --> TopK["top-6"]
    TopK --> Prompt["组装 Prompt<br/>含引用编号"]
    Prompt --> LLM["LLM 流式生成"]
    LLM --> Cite["解析引用 → citations 表"]
```

**RRF 融合公式**：`score = Σ 1 / (k + rank_i)`，`k = 60`。

**引用约束**：Prompt 要求模型用 `[1] [2]` 标注来源，服务端解析后写入 `citations`，前端渲染为可点击链接。若模型未引用任何来源，则标记 `grounded = false`。

#### 增量更新

- 卡片 `INSERT/UPDATE` → 发布 `card.index` 事件 → Worker 重新嵌入该卡片的 chunk。
- 卡片 `DELETE` → 删除对应 chunk。
- 卡片集删除 → 级联删除 chunk。

### 5.5 Agent 编排（`agents/`）

#### 接口隔离

```python
class AgentRuntime(Protocol):
    async def start(self, graph: str, state: dict, *, thread_id: str) -> AgentEvent: ...
    async def resume(self, thread_id: str, value: dict) -> AgentEvent: ...
    async def stream(self, thread_id: str) -> AsyncIterator[AgentEvent]: ...
```

`LangGraphRuntime` 是唯一实现。换框架只改这一个类。

#### 四个 Agent

| Agent | 职责 | 输入 | 输出 | 人工介入 |
| --- | --- | --- | --- | --- |
| **CardSmith** | 制卡 | 资料文本 + 配置 | 卡片草稿列表 | ✅ 草稿确认 |
| **Planner** | 学习计划 | 到期统计 + 时间预算 + 目标 | 7 天计划 | ✅ 计划确认 |
| **Tutor** | 答疑 | 问题 + 检索结果 | 带引用的回答 | ❌ 流式输出 |
| **Conductor** | 统筹调度（P1） | 全局状态 | 通知/建议 | ✅ 建议确认 |

#### CardSmith 图

```mermaid
flowchart LR
    Start([开始]) --> Parse["解析资料"]
    Parse --> Extract["抽取知识点"]
    Extract --> Draft["生成卡片"]
    Draft --> QC["质检去重"]
    QC --> Review{{"interrupt<br/>等待用户确认"}}
    Review -->|确认| Commit["落库"]
    Review -->|取消| End([结束])
    Commit --> End
```

**`interrupt` 用法**：`Review` 节点调用 `interrupt({"drafts": [...]})`，图状态持久化到 Postgres；前端确认后调用 `resume(thread_id, {"approved_ids": [...]})`。

#### Planner 图

```mermaid
flowchart LR
    Start([开始]) --> Load["加载到期统计"]
    Load --> Budget["计算时间预算<br/>（确定性）"]
    Budget --> Decide{"是否超预算？"}
    Decide -->|是| Prioritize["优先级排序<br/>（确定性 + LLM 解释）"]
    Decide -->|否| Compose["组装计划"]
    Prioritize --> Compose
    Compose --> Explain["LLM 生成理由"]
    Explain --> Confirm{{"interrupt<br/>等待确认"}}
    Confirm --> Save["保存计划"]
    Save --> End([结束])
```

> **注意**：`Budget` 与 `Prioritize` 是**确定性代码**（基于 FSRS 的 `due_at`、`stability`、卡片集权重），LLM 只负责 `Explain` 生成自然语言理由。

#### Tutor 图

```mermaid
flowchart LR
    Start([开始]) --> Rewrite["查询改写"]
    Rewrite --> Retrieve["混合检索"]
    Retrieve --> Enough{"结果足够？"}
    Enough -->|否| Clarify["告知无相关内容<br/>询问是否用通用知识"]
    Enough -->|是| Generate["LLM 流式生成<br/>带引用"]
    Clarify --> Generate
    Generate --> Persist["保存消息与引用"]
    Persist --> End([结束])
```

### 5.6 认证与鉴权

- **密码**：`argon2-cffi`，`Argon2id`，参数 `time_cost=3, memory_cost=64MB, parallelism=4`。
- **Token**：JWT（`HS256`），Access 15 分钟 / Refresh 30 天。
- **Refresh 轮换**：每次刷新签发新 Refresh Token，旧的加入黑名单（Redis，TTL = 剩余有效期）。
- **多租户隔离**：所有仓储方法强制 `user_id` 参数；Postgres RLS 作为兜底（`app.current_user_id` 会话变量）。
- **限流**：Redis 滑动窗口。登录 5/min/IP，LLM 接口 20/min/user。

### 5.7 通知调度（`workers/notification.py`）

- ARQ 定时任务，每分钟扫描「到点」的提醒。
- 依据 `users.settings.notification` 与静默时段过滤。
- 通过 FCM / APNs 发送，记录 `notification_logs` 防重复。
- 每日上限 3 条。

---

## 6. API 设计

### 6.1 约定

- Base URL：`/api/v1`
- 认证：`Authorization: Bearer <access_token>`
- 错误格式：

```json
{
  "error": {
    "code": "DECK_NOT_FOUND",
    "message": "卡片集不存在",
    "request_id": "req_xxx"
  }
}
```

- 分页：`?cursor=<opaque>&limit=20`，响应 `{"items": [...], "next_cursor": "..."}`。
- 幂等：写操作支持 `Idempotency-Key` 头。
- 时间：全部 UTC ISO 8601。

### 6.2 端点清单

#### 认证

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/auth/register` | 注册 |
| POST | `/auth/login` | 登录 |
| POST | `/auth/refresh` | 刷新 Token |
| POST | `/auth/logout` | 退出当前设备 |
| POST | `/auth/logout-all` | 退出所有设备 |
| GET | `/auth/me` | 当前用户 |

#### 文件夹 / 卡片集

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/folders` | 列表 |
| POST | `/folders` | 创建 |
| PATCH | `/folders/{id}` | 重命名 / 排序 |
| DELETE | `/folders/{id}` | 删除（卡片集移入未分类） |
| GET | `/decks` | 列表（含统计） |
| POST | `/decks` | 创建 |
| GET | `/decks/{id}` | 详情 |
| PATCH | `/decks/{id}` | 更新（含 config） |
| DELETE | `/decks/{id}` | 删除 |

#### 卡片

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/decks/{id}/cards` | 卡片列表（分页） |
| POST | `/decks/{id}/cards` | 新建 |
| GET | `/cards/{id}` | 详情 |
| PATCH | `/cards/{id}` | 更新 |
| DELETE | `/cards/{id}` | 删除 |
| POST | `/cards/batch` | 批量操作（移动/打标签/删除） |
| GET | `/search?q=&deck_id=` | 搜索 |

#### 复习

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/decks/{id}/review-queue` | 获取复习队列 |
| POST | `/reviews` | 提交复习记录（幂等） |
| POST | `/reviews/batch` | 批量提交（离线重放） |
| GET | `/stats/decks/{id}` | 卡片集统计 |
| GET | `/stats/overview` | 全局统计 |

#### 资料与制卡

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/sources` | 上传资料（multipart） |
| GET | `/sources/{id}` | 解析状态 |
| POST | `/generation/jobs` | 创建制卡任务 |
| GET | `/generation/jobs/{id}` | 任务状态 |
| GET | `/generation/jobs/{id}/events` | **SSE 进度流** |
| POST | `/generation/jobs/{id}/cancel` | 取消 |
| GET | `/generation/jobs/{id}/drafts` | 草稿列表 |
| PATCH | `/drafts/{id}` | 编辑草稿 |
| POST | `/generation/jobs/{id}/commit` | 确认落库 |

#### 计划

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/plans` | 生成计划（Agent） |
| GET | `/plans/active` | 当前计划 |
| POST | `/plans/{id}/approve` | 同意计划 |
| PATCH | `/plans/{id}/days/{day}` | 调整某天 |
| GET | `/plans/today` | 今日任务 |

#### 答疑

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/conversations` | 会话列表 |
| POST | `/conversations` | 新建会话 |
| GET | `/conversations/{id}/messages` | 消息列表 |
| POST | `/conversations/{id}/messages` | **发送消息（SSE 流式）** |
| DELETE | `/conversations/{id}` | 删除会话 |

#### 设备

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/devices` | 注册设备与推送令牌 |
| DELETE | `/devices/{id}` | 注销设备 |

### 6.3 关键接口示例

**提交复习记录（幂等）**

```http
POST /api/v1/reviews
Idempotency-Key: 7f3c...-uuid
Content-Type: application/json

{
  "id": "7f3c...-uuid",
  "card_id": "a1b2...",
  "rating": 3,
  "elapsed_ms": 4200,
  "reviewed_at": "2026-11-22T12:03:00Z"
}
```

```json
{
  "card_id": "a1b2...",
  "state": {
    "stability": 4.82,
    "difficulty": 5.13,
    "due_at": "2026-11-27T12:03:00Z",
    "reps": 3,
    "lapses": 0,
    "state": 2
  }
}
```

**SSE 进度流**

```
event: progress
data: {"stage":"DRAFTING","progress":45,"drafts_count":14}

event: progress
data: {"stage":"QC","progress":80,"drafts_count":30}

event: done
data: {"job_id":"...","drafts_count":28,"duplicates":2}
```

---

## 7. 移动端架构

### 7.1 分层

```mermaid
flowchart TB
    subgraph Presentation
        Screens["Screens<br/>（页面）"]
        Widgets["Widgets<br/>（组件）"]
    end
    subgraph Application
        Notifiers["Riverpod Notifiers<br/>（状态）"]
        UseCases["UseCases<br/>（用例）"]
    end
    subgraph Domain
        Entities["Entities<br/>（freezed）"]
        CardRenderers["CardRenderer 注册表"]
    end
    subgraph Data
        Repos["Repositories"]
        LocalDS["LocalDataSource<br/>Drift"]
        RemoteDS["RemoteDataSource<br/>Dio"]
        Outbox["Outbox Queue"]
    end

    Screens --> Notifiers
    Widgets --> CardRenderers
    Notifiers --> UseCases
    UseCases --> Repos
    Repos --> LocalDS
    Repos --> RemoteDS
    Repos --> Outbox
```

### 7.2 目录结构

```
app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── router/
│   │   ├── theme/
│   │   ├── network/          # dio 配置、拦截器
│   │   ├── storage/          # secure storage
│   │   └── utils/
│   ├── features/
│   │   ├── auth/
│   │   ├── decks/
│   │   ├── cards/
│   │   ├── review/
│   │   ├── generation/
│   │   ├── plan/
│   │   ├── chat/
│   │   └── settings/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   ├── shared/
│   │   ├── widgets/
│   │   └── card_renderers/   # 卡片类型渲染器注册
│   └── l10n/
├── test/
└── pubspec.yaml
```

### 7.3 状态管理约定

- 每个 feature 一个 `Notifier`，状态用 `freezed` 定义（不可变 + `copyWith`）。
- 异步数据用 `AsyncNotifier`，UI 用 `switch` 模式匹配 `AsyncValue`。
- **禁止**在 Widget 内直接调 API；必须经 `UseCase → Repository`。

### 7.4 离线与同步

#### 本地表

| 表 | 用途 |
| --- | --- |
| `local_decks` | 卡片集缓存 |
| `local_cards` | 卡片缓存（含复习状态） |
| `local_review_logs` | 待同步的复习记录 |
| `outbox` | 通用写操作队列 |
| `sync_cursor` | 增量同步游标 |

#### 同步策略

```mermaid
sequenceDiagram
    participant App
    participant Local as 本地库
    participant API as 服务端
    participant Outbox

    Note over App,Outbox: 启动 / 网络恢复
    App->>Local: 读取 sync_cursor
    App->>API: GET /sync?since=<cursor>
    API-->>App: 变更集 + new_cursor
    App->>Local: 事务内应用变更
    App->>Local: 更新 sync_cursor

    Note over App,Outbox: 离线写入
    App->>Outbox: 入队（含 idempotency_key）
    App->>Local: 乐观更新
    Note over App,Outbox: 联网后
    Outbox->>API: 按序重放
    API-->>Outbox: 成功 / 冲突
    Outbox->>Local: 确认或回滚
```

- **拉取**：`GET /sync?since=<cursor>` 返回 `updated_at > cursor` 的卡片集与卡片（增量）。
- **推送**：Outbox 按 `created_at` 顺序重放，指数退避（1s → 2s → 4s → 8s → 16s），最多 5 次。
- **冲突**：服务端返回 409 + 最新版本，客户端覆盖本地并提示「有更新」。

### 7.5 卡片渲染器注册（扩展点）

```dart
abstract class CardRenderer {
  String get typeId;
  Widget buildFront(BuildContext ctx, Card card);
  Widget buildBack(BuildContext ctx, Card card);
}

final cardRenderers = <String, CardRenderer>{
  'memory': MemoryCardRenderer(),
  // 未来：'schedule': ScheduleCardRenderer(),
};
```

未知类型降级为 `FallbackCardRenderer`（展示原始 JSON），保证向前兼容。

---

## 8. 关键流程时序

### 8.1 制卡全流程

```mermaid
sequenceDiagram
    autonumber
    participant U as 用户
    participant App as Flutter
    participant API as FastAPI
    participant Q as ARQ
    participant W as Worker
    participant LLM
    participant DB as Postgres

    U->>App: 选择 PDF
    App->>API: POST /sources (multipart)
    API->>DB: 插入 sources (pending)
    API->>Q: 入队 parse
    API-->>App: 202 {source_id}

    W->>DB: 更新 status=parsing
    W->>W: 抽取文本
    W->>DB: 更新 status=ready, extracted_text

    App->>API: POST /generation/jobs
    API->>DB: 插入 job (PENDING)
    API->>Q: 入队 generate
    API-->>App: 202 {job_id}

    App->>API: GET /jobs/{id}/events (SSE)
    W->>LLM: 抽取知识点
    W->>DB: stage=EXTRACTING 30%
    W->>LLM: 生成卡片（分批）
    W->>DB: stage=DRAFTING 60%
    W->>W: 质检去重
    W->>DB: 插入 drafts, stage=AWAITING_REVIEW 100%
    API-->>App: event: done

    App->>API: GET /jobs/{id}/drafts
    API-->>App: 草稿列表
    U->>App: 编辑 + 取消勾选
    App->>API: POST /jobs/{id}/commit {approved_ids}
    API->>DB: 事务：插入 cards + review_states
    API->>Q: 入队 embedding
    API-->>App: 200 {created: 25}
```

### 8.2 复习流程（含离线）

```mermaid
sequenceDiagram
    autonumber
    participant U as 用户
    participant App as Flutter
    participant Local as Drift
    participant Outbox
    participant API as FastAPI
    participant FSRS
    participant DB as Postgres

    U->>App: 开始复习
    App->>Local: 查询 due_at <= now
    Local-->>App: 队列（离线可用）
    loop 每张卡片
        U->>App: 翻面
        U->>App: 评分
        App->>FSRS: schedule(state, rating)
        FSRS-->>App: 新状态
        App->>Local: 写入 review_log + 更新 state
        App->>Outbox: 入队（idempotency_key）
    end
    Note over App,Outbox: 联网后
    Outbox->>API: POST /reviews/batch
    API->>DB: 按 id 去重后写入
    API-->>Outbox: 200
    Outbox->>Local: 标记已同步
```

> **关键决策**：客户端也实现一份 FSRS（Dart 移植），保证离线时排程正确；服务端重放时以客户端提交的 `rating` 重新计算并校验，**以服务端结果为准**（防止客户端被篡改）。

### 8.3 答疑流程

```mermaid
sequenceDiagram
    autonumber
    participant U as 用户
    participant App as Flutter
    participant API as FastAPI
    participant R as Retriever
    participant DB as Postgres
    participant LLM

    U->>App: 输入问题
    App->>API: POST /conversations/{id}/messages (SSE)
    API->>R: 查询改写
    R->>DB: 向量检索 top-20
    R->>DB: 关键词检索 top-20
    R->>R: RRF 融合 → top-6
    R-->>API: chunks
    API->>LLM: 流式生成（含引用要求）
    loop 流式
        LLM-->>API: token
        API-->>App: event: delta
    end
    API->>DB: 保存 message + citations
    API-->>App: event: done
    App->>U: 渲染回答 + 引用卡片
```

### 8.4 计划生成流程

```mermaid
sequenceDiagram
    autonumber
    participant U as 用户
    participant App as Flutter
    participant API as FastAPI
    participant P as Planner
    participant DB as Postgres

    U->>App: 设定目标 + 每日时长
    App->>API: POST /plans
    API->>DB: 聚合到期统计（按卡片集）
    API->>P: 运行 Planner 图
    P->>P: 计算时间预算（确定性）
    P->>P: 优先级排序（确定性）
    P->>P: LLM 生成理由
    P-->>API: 7 天计划
    API-->>App: 计划预览
    U->>App: 点击「同意」
    App->>API: POST /plans/{id}/approve
    API->>DB: 保存计划 + 注册推送
    API-->>App: 200
```

---

## 9. 非功能设计

### 9.1 性能

| 场景 | 措施 |
| --- | --- |
| 卡片列表 | 本地缓存优先；服务端分页 + 覆盖索引 |
| 复习队列 | `(user_id, due_at)` 索引；队列预取 50 张 |
| 搜索 | `pg_trgm` GIN 索引；结果限 50 条 |
| 答疑首 token | 检索并行化；LLM 流式；Prompt 精简 |
| 冷启动 | Flutter 延迟初始化；首屏骨架屏 |

### 9.2 缓存

| 数据 | 位置 | TTL |
| --- | --- | --- |
| 用户信息 | Redis | 5 min |
| 卡片集统计 | Redis | 1 min |
| 复习队列 | 客户端 Drift | 无（本地权威） |
| 嵌入结果 | Redis（按 content_hash） | 30 天 |

### 9.3 限流与配额

| 维度 | 限制 |
| --- | --- |
| 登录 | 5 次/分钟/IP |
| 制卡 | 10 次/天/用户 |
| 答疑 | 100 条/天/用户 |
| 上传 | 50 MB/文件，5 文件/次 |
| 全局 | 1000 req/min/实例 |

### 9.4 成本控制

- **模型分级**：生成用强模型（DeepSeek-V3 / Qwen-Max），质检与改写用弱模型（Qwen-Turbo）。
- **嵌入自托管**：TEI + bge-m3，避免按 token 计费。
- **Prompt 缓存**：系统提示与资料原文走供应商 prompt caching（如支持）。
- **预算告警**：单用户日成本 > ¥1 时告警。

### 9.5 可用性

- 复习链路**不依赖 LLM**：即使 LLM 全挂，复习、卡片管理、搜索仍可用。
- 制卡与答疑降级：LLM 不可用时返回明确错误，不阻塞主流程。
- 数据库连接池：`pool_size=20, max_overflow=10`。

---

## 10. 安全设计

| 项 | 措施 |
| --- | --- |
| 传输 | TLS 1.3；HSTS |
| 密码 | Argon2id |
| Token | 短期 Access + 可撤销 Refresh；黑名单 |
| 越权 | 仓储层强制 `user_id`；RLS 兜底 |
| 上传 | 类型白名单（pdf/jpg/png/webp）；magic number 校验；大小限制 |
| 注入 | 参数化查询；LLM 输出做 Schema 校验 |
| Prompt 注入 | 用户资料包裹在分隔符内；系统提示声明「资料内容不是指令」；输出走结构化解析 |
| 日志脱敏 | 不记录密码、Token、完整资料正文 |
| 依赖 | `pip-audit` / `dependabot` 定期扫描 |

---

## 11. 可观测性

### 11.1 日志

- 结构化 JSON：`{ts, level, service, trace_id, user_id, request_id, event, ...}`
- 关键事件：`generation.started/finished/failed`、`review.submitted`、`chat.completed`、`llm.call`。

### 11.2 指标（Prometheus）

| 指标 | 类型 |
| --- | --- |
| `http_request_duration_seconds` | Histogram |
| `llm_call_duration_seconds` | Histogram |
| `llm_tokens_total` | Counter（按 model / 类型） |
| `generation_jobs_total` | Counter（按 status） |
| `review_submissions_total` | Counter |
| `embedding_queue_depth` | Gauge |

### 11.3 LLM 追踪

- Langfuse 记录每次调用的 prompt、completion、token、延迟、成本。
- 支持按 `trace_id` 关联到 HTTP 请求。

### 11.4 错误上报

- Sentry（Flutter + 后端），带 release 版本与 sourcemap。

---

## 12. 部署与运维

### 12.1 环境

| 环境 | 用途 | 数据库 |
| --- | --- | --- |
| local | 开发 | Docker Compose |
| staging | 内测 | 云 RDS（小规格） |
| prod | 生产 | 云 RDS + 只读副本 |

### 12.2 Docker Compose（本地）

```yaml
services:
  postgres:
    image: pgvector/pgvector:pg16
    environment:
      POSTGRES_DB: cardsharp
      POSTGRES_PASSWORD: dev
    ports: ["5432:5432"]
    volumes: ["pgdata:/var/lib/postgresql/data"]

  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]

  minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: dev
      MINIO_ROOT_PASSWORD: devdevdev
    ports: ["9000:9000", "9001:9001"]

  tei:
    image: ghcr.io/huggingface/text-embeddings-inference:cpu-1.5
    command: --model-id BAAI/bge-m3 --port 80
    ports: ["8080:80"]

  api:
    build: ./backend
    env_file: .env
    ports: ["8000:8000"]
    depends_on: [postgres, redis, minio]

  worker:
    build: ./backend
    command: arq app.workers.main.WorkerSettings
    env_file: .env
    depends_on: [postgres, redis]

volumes:
  pgdata:
```

### 12.3 迁移

- Alembic 管理 Schema 变更。
- 部署流程：`alembic upgrade head` → 滚动重启 API → 重启 Worker。
- 破坏性变更采用「双写 → 迁移 → 删除」三步。

### 12.4 备份

- 数据库每日全量 + WAL 归档（PITR）。
- 对象存储开启版本控制。
- 备份恢复演练每月一次。

---

## 13. 测试策略

| 层 | 范围 | 工具 | 目标覆盖 |
| --- | --- | --- | --- |
| 单元测试 | `domain/`（FSRS、去重、校验） | pytest | ≥ 90% |
| 集成测试 | `services/` + 真实 Postgres | pytest + testcontainers | ≥ 70% |
| API 测试 | 路由契约 | httpx + Schemathesis | 全部端点 |
| Agent 测试 | 图执行、interrupt/resume | pytest + 固定 LLM 桩 | 关键路径 |
| 移动端 | Widget + 单元 | flutter_test | ≥ 60% |
| E2E | 核心链路 | integration_test | 5 条主流程 |
| 性能 | 复习队列、搜索 | k6 | P95 达标 |

### 13.1 关键测试用例

**FSRS**
- 相同输入 → 相同输出（纯函数）
- 间隔单调性：连续「简单」评分的间隔严格递增
- 边界：`stability` 极小/极大时不溢出
- 与官方 FSRS 测试向量对齐

**制卡**
- 加密 PDF → 明确错误
- 取消任务 → 草稿保留
- 重复提交 commit → 不产生重复卡片
- 质检：相似卡片被标记

**离线同步**
- 飞行模式复习 → 联网重放 → 服务端一致
- 重复 `id` 提交 → 只记一次
- 冲突 → 服务端为准

---

## 14. 技术风险与缓解

| # | 风险 | 影响 | 缓解 |
| --- | --- | --- | --- |
| T1 | LangGraph 版本不稳定 | 中 | `AgentRuntime` 接口隔离；锁定版本 |
| T2 | 客户端 FSRS 与服务端不一致 | 高 | 共享测试向量；服务端重算为准 |
| T3 | pgvector 检索性能不足 | 中 | HNSW 参数调优；预留 `VectorStore` 接口 |
| T4 | PDF 解析质量差 | 中 | 多引擎兜底（pypdf / pdfplumber / OCR） |
| T5 | LLM 输出不稳定导致解析失败 | 高 | 结构化输出 + 重试 + 降级为纯文本 |
| T6 | Flutter 包体积过大 | 低 | 按需加载；`--split-debug-info` |
| T7 | 推送到达率（国内 Android） | 中 | 接入厂商推送通道（P1） |

---

## 15. 迭代路线

| 版本 | 内容 |
| --- | --- |
| **MVP (v1.0)** | 记忆卡片全链路、Agent 制卡、FSRS 复习、计划、RAG 答疑 |
| v1.1 | 扫描件 OCR、图片生成、性能优化 |
| v1.5 | Web 制卡台、桌面端、厂商推送 |
| v2.0 | 卡片社区、日程卡片、灵感卡片、多人共享 |
| v3.0 | 插件市场、自定义 Agent、开放 API |

---

## 附录 A：关键常量

| 常量 | 值 | 说明 |
| --- | --- | --- |
| `FSRS_DECAY` | -0.5 | 遗忘曲线衰减 |
| `FSRS_FACTOR` | 19/81 | 缩放因子 |
| `DEFAULT_RETENTION` | 0.9 | 默认目标保留率 |
| `NEW_PER_DAY` | 20 | 每日新卡上限 |
| `DEDUP_THRESHOLD` | 0.9 | 疑似重复相似度阈值 |
| `CHUNK_SIZE` | 512 | 资料切分 token |
| `CHUNK_OVERLAP` | 64 | 切分重叠 |
| `RAG_TOP_K` | 6 | 检索返回数 |
| `RRF_K` | 60 | RRF 融合参数 |
| `DRAFT_TTL_DAYS` | 7 | 草稿保留天数 |
| `SOFT_DELETE_DAYS` | 30 | 软删除保留天数 |

## 附录 B：术语

见 [MVP 需求文档 · 附录 A](02-MVP需求文档.md#附录-a术语表)。
