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
| G2 排程可解释且可约束 | 排程由 Agent 决策，但受确定性护栏约束，同输入可复现 |
| G3 类型可插拔 | 新增卡片类型不改核心 CRUD |
| G4 离线可用 | 复习链路完全离线；客户端只消费已排期队列 |
| G5 成本可控 | 单用户月成本 ≤ ¥3，嵌入自托管 |

### 1.2 关键设计原则

1. **Agent 产出草稿，用户做最终决策。** 任何 LLM 产物落库前必须经过显式确认。
2. **Agent 做决策，代码做约束。** 排程、去重、权限、计费的关键不变量由**确定性代码**保证；Agent 只在合法空间内做选择，越界即降级。
3. **客户端不承担业务计算。** 排程、去重、优先级全在服务端；客户端只做「渲染 + 队列消费 + 事件上报」。
4. **深模块、窄接口。** 每个模块对外只暴露一个稳定的接口，内部实现可替换（如嵌入模型、LLM 供应商、排程策略）。
5. **所有写操作幂等。** 客户端生成 `idempotency_key`，服务端去重，支撑离线重放。
6. **数据模型按「类型」抽象，不按「记忆卡片」硬编码。** 卡片内容存 `jsonb`，类型定义驱动校验。

---

## 2. 技术栈选型

### 2.1 选型总表

| 层 | 选型 | 版本 | 理由 |
| --- | --- | --- | --- |
| 移动端 | Flutter | 3.47 / Dart 3.13 | 单代码库覆盖 iOS + Android；**MVP 仅移动端**，不排期 Web/Desktop |
| 状态管理 | Riverpod + freezed | 3.5 / 3.x | 编译期安全、易测试、无 BuildContext 依赖 |
| 路由 | go_router | 18+ | 声明式、支持深链（推送跳转） |
| 本地库 | Drift (SQLite) | 2.35+ | 类型安全 SQL、迁移成熟；**只存缓存与 Outbox，不存排程** |
| 网络 | dio + retrofit | 5.x / 4.x | 拦截器、重试、类型安全 |
| 后端 | Python + FastAPI | 3.12 / 0.115+ | 异步原生、OpenAPI 自动生成、AI 生态最全 |
| ORM | SQLAlchemy 2.0 (async) + Alembic | 2.0 | 成熟、异步、迁移工具完善 |
| 数据库 | PostgreSQL + pgvector | 16 / 0.7+ | 关系 + 向量一体，少一个组件 |
| 全文检索 | pg_trgm + tsvector | 内置 | 中文模糊搜索够用，避免引入 ES |
| Agent 编排 | LangGraph | 0.2+ | 有状态图、`interrupt` 原生支持人工确认、Postgres checkpointer |
| 排程 | **排程 Agent + FSRS 护栏** | — | Agent 决策，FSRS 兜底；客户端不参与 |
| LLM 接入 | OpenAI 兼容协议（`openai` SDK） | 1.x | 一套代码切 DeepSeek / Qwen / GPT |
| 异步任务 | Redis + ARQ | 7 / 0.26+ | asyncio 原生，比 Celery 轻 |
| 嵌入 | bge-m3 自托管（TEI） | — | 中文效果好、1024 维、无按 token 费用 |
| 对象存储 | S3 兼容（MinIO / 阿里云 OSS） | — | 标准协议，本地与云一致 |
| 推送 | FCM + APNs | — | 双端标准方案 |
| 可观测 | OpenTelemetry + Langfuse + Sentry | — | 链路 + LLM 追踪 + 错误 |
| 部署 | Docker Compose → 云托管 | — | MVP 阶段单机足够 |

> **客户端不引入排程库**：Dart 侧没有 FSRS 依赖，排程全部在服务端（见 ADR-004）。

### 2.2 关键 ADR

#### ADR-001：为什么选 Flutter 而不是 React Native

| 维度 | Flutter | React Native |
| --- | --- | --- |
| 卡片翻转/手势动画 | 自绘引擎，60fps 稳定 | 依赖原生桥，复杂动画需额外优化 |
| 长列表性能（千张卡片） | `ListView.builder` 稳定 | 需额外优化 |
| 团队语言 | Dart（学习成本） | TypeScript（若团队是 TS 背景更优） |

**决策**：选 Flutter。核心理由是**复习场景高度依赖流畅的卡片交互与动画**（翻页、遮罩揭示、手势评分），且 Flutter 的渲染一致性让「设计稿还原」成本更低。

> **不构成理由的部分**：多端延展能力。MVP **明确仅移动端**（见需求文档 §2.4），不以「未来可出 Web/Desktop」作为选型依据——那会让选型偏离当前真实需求。

#### ADR-002：为什么用 LangGraph 而不是自研编排

- 需要**有状态的多轮图执行**（制卡流水线有 5 个阶段，答疑需要工具调用循环）。
- 需要**人工介入**（`interrupt` → 前端确认 → `resume`），自研需处理序列化与恢复。
- 需要**可观测**（Langfuse 原生集成）。

**决策**：用 LangGraph，但**通过一层 `AgentRuntime` 接口隔离**，避免框架锁定。若未来替换，只改适配层。

#### ADR-003：排程为什么交给 Agent，而不是固定算法

**背景**：产品要服务两类差异极大的用户——

- **考试冲刺型**：考期临近（≤ 30 天），需要短期高强度、按考纲优先级压缩间隔、允许「超量复习」。
- **强记忆型**：自评记忆力好，需要拉长间隔、减少无效重复，否则会因「太简单」而放弃。

固定参数的 FSRS 无法同时满足。FSRS 的权重是**全局最优**，不是**个体最优**；虽然支持按用户训练个性化权重，但那需要大量复习历史，冷启动阶段无解。

**备选方案**

| 方案 | 优点 | 缺点 |
| --- | --- | --- |
| A. 纯 FSRS + 可调参数 | 确定、可测试 | 参数空间表达不了「按考纲优先级」「考前突击」这类策略 |
| B. 纯 LLM 排程 | 灵活、可解释 | 不确定、无法保证单调性、成本高、难复现 |
| C. **Agent 决策 + 确定性护栏** | 灵活 + 可控 | 实现复杂度上升，需要护栏层 |

**决策**：采用 **C**。

- **Agent 负责决策**：结合用户画像（学习模式、每日预算、考试日期）与卡片质量（错误次数、难度、历史评分）输出 `SchedulePlan`。
- **确定性工具供 Agent 调用**：`compute_retrievability` / `estimate_interval` / `get_due_cards` / `get_card_quality` / `check_budget`。Agent **不能自己算数学**，只能调工具。
- **护栏层校验**（代码，非 LLM）：间隔单调性、上下界 `[1, 365]` 天、每日预算 ≤ 设定 × 1.15、幂等。违反则**降级为 FSRS 结果**并记录 `scheduler.fallback` 告警。
- **可复现**：温度 0 + 固定工具返回 + 护栏，保证同输入同输出。

**为什么不直接让 LLM 输出 `due_at`**：LLM 无法保证「评分越高间隔越长」这类单调性约束，也无法保证不超预算。护栏层把这些变成硬约束，Agent 只在合法空间内做选择。

**代价**：排程延迟从「纯函数微秒级」变成「LLM 秒级」。因此排程**异步批量执行**（每次复习记录同步后触发），不阻塞复习交互。

#### ADR-004：为什么客户端不参与排程

**背景**：离线复习需要「下次什么时候复习」的答案。

**备选方案**

| 方案 | 说明 |
| --- | --- |
| A. 客户端移植 FSRS（Dart） | 离线可算，但双实现一致性风险高，且与 ADR-003 冲突（Agent 排程无法离线） |
| B. **客户端只消费服务端已排期队列** | 离线时按预下载队列复习，评分入 Outbox，联网后服务端重排程 |

**决策**：采用 **B**。

- 客户端**不实现任何排程算法**，只做「队列消费 + 评分记录」。
- 预下载未来 7 天队列（含卡片内容与图片）。
- 离线评分写入 Outbox，联网重放后由服务端 Agent 重新排程。
- 好处：消除双实现一致性风险（原 T2）、离线逻辑极简、排程策略可随时调整而无需发版。

**代价**：离线队列可能过期（用户 10 天没联网）。缓解：过期时提示「需联网更新排期」，允许继续消费旧队列但标注「可能不是最优」。

#### ADR-005：为什么用 pgvector 而不是独立向量库

- MVP 数据量 < 1000 万向量，pgvector HNSW 足够。
- 少一个组件 = 少一套运维、备份、一致性保障。
- 支持**事务内**同时写业务数据与向量，避免双写不一致。

**决策**：pgvector。若未来 QPS 撑不住，再迁 Qdrant（通过 `VectorStore` 接口隔离）。

#### ADR-006：为什么「云端为主 + 本地缓存」而不是本地优先

本地优先（CRDT）能带来最好的离线体验，但 MVP 阶段冲突合并的复杂度会拖慢交付。

**决策**：服务端为唯一事实源；客户端做**读缓存 + 写 Outbox 队列**。离线可读、可写（复习记录），联网重放。冲突时以服务端为准并提示用户。

> 与 ADR-004 的关系：正因为客户端不参与排程，本地缓存**不需要**合并排程状态，冲突面大幅收窄——只需合并「复习记录」这一种不可变事件。

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
    users ||--o| learner_profiles : has
    users ||--o{ devices : has
    users ||--o{ folders : owns
    users ||--o{ decks : owns
    users ||--o{ tags : owns
    users ||--o{ conversations : owns
    users ||--o{ study_plans : owns
    users ||--o{ sources : uploads
    users ||--o{ schedule_runs : triggers

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

    schedule_runs ||--o{ schedule_items : produces
    cards ||--o{ schedule_items : scheduled
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

#### schedule_runs / schedule_items

> 排程 Agent 的执行记录。**只追加**，用于可观测、可回溯、可复现。

```sql
schedule_runs(
    id            uuid PK,
    user_id       uuid FK,
    mode          varchar(16),      -- standard / sprint / strong_memory / custom
    trigger       varchar(32),      -- review_sync / manual / daily_cron
    card_count    int,
    fallback_count int,             -- 护栏降级卡片数
    duration_ms   int,
    token_usage   jsonb,
    created_at    timestamptz
)

schedule_items(
    id            uuid PK,
    run_id        uuid FK,
    card_id       uuid FK,
    due_at        timestamptz,
    interval_days real,
    rationale     text,             -- 面向用户的一句话理由
    fallback      boolean,          -- 是否由 FSRS 兜底
    guard_rule    varchar(64) NULL, -- 触发的护栏规则
    created_at    timestamptz
)
```

索引：`(user_id, created_at DESC)`、`(card_id, created_at DESC)`。

> **为什么落库**：排程结果需要可回溯（用户问「为什么这张卡今天复习」），也需要可复现（测试比对快照）。`review_states` 只存最终状态，`schedule_items` 存**决策依据**。

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

> 字段命名对齐设计稿：**明文**（`plaintext`）= 正面，**暗文**（`ciphertext`）= 背面。

```jsonc
{
  "plaintext": "线粒体的主要功能是什么？",
  "ciphertext": "通过有氧呼吸产生 ATP，为细胞提供能量。",
  "images": [],                    // [{key, width, height, alt}]
  "hint": "与能量代谢有关",
  "extra": "细胞器章节 · 第 3 节"
}
```

约束：`plaintext` ≤ 200 字，`ciphertext` ≤ 500 字，均不可为空。

### 4.5 learner_profiles（学习画像）

> 排程 Agent 的输入。与 `users` 一对一。

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| user_id | uuid PK | |
| mode | varchar(16) | `standard` / `sprint` / `strong_memory` / `custom` |
| daily_minutes | int | 每日可用时长，默认 30 |
| exam_date | date NULL | 考试日期（`sprint` 模式必填） |
| desired_retention | real | 0.70–0.99，默认 0.90 |
| new_per_day | int | 每日新卡上限，默认 20 |
| max_reviews_per_day | int | 每日复习上限，默认 200 |
| updated_at | timestamptz | |

> **模式切换只影响未来排程**，不追溯历史（见需求文档 Q6）。切换时记录 `profile.mode_changed` 事件用于分析。

### 4.6 扩展点：新增卡片类型

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
│   │   ├── schedule.py          # 排程历史 / 画像
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
│   │   ├── schedule_service.py  # 排程编排（触发 Agent + 落库）
│   │   ├── generation_service.py
│   │   ├── plan_service.py
│   │   ├── chat_service.py
│   │   └── search_service.py
│   ├── domain/
│   │   ├── scheduling_tools.py  # 确定性工具（Agent 只能调用）
│   │   ├── scheduling_guard.py  # 护栏（纯函数）
│   │   ├── fsrs.py              # 兜底排程（纯函数）
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
│   │   │   ├── scheduler.py     # 排程（核心）
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

### 5.2 排程 Agent（`agents/graphs/scheduler.py` + `domain/fsrs.py`）

> **架构定位**：排程是「Agent 决策 + 代码约束」的双层结构。Agent 负责**选择**，护栏负责**合法性**，FSRS 负责**兜底**。

#### 5.2.1 分层职责

```mermaid
flowchart TB
    Trigger["复习记录同步完成"] --> Collect["收集上下文<br/>（确定性）"]
    Collect --> Profile["加载用户画像<br/>（学习模式/预算/考期）"]
    Profile --> Agent["排程 Agent<br/>（LLM，温度 0）"]
    Agent -->|调用| Tools["确定性工具集"]
    Tools --> Agent
    Agent --> Plan["SchedulePlan<br/>每张卡片 due_at + 理由"]
    Plan --> Guard{"护栏校验<br/>（代码）"}
    Guard -->|通过| Persist["写入 review_states"]
    Guard -->|违反| Fallback["降级 FSRS 计算"]
    Fallback --> Persist
    Persist --> Notify["更新客户端队列"]
```

| 层 | 职责 | 实现 | 可测试性 |
| --- | --- | --- | --- |
| **上下文收集** | 聚合到期卡片、卡片质量、用户画像 | 纯 SQL 查询 | 集成测试 |
| **Agent 决策** | 输出每张卡片的 `due_at` + 理由 | LangGraph + LLM | 桩 LLM 单测 |
| **确定性工具** | 提供数学计算能力 | 纯函数 | 单元测试 |
| **护栏** | 校验合法性、越界降级 | 纯函数 | 单元测试（核心） |
| **FSRS 兜底** | 护栏失败时的确定性结果 | 纯函数 | 单元测试 |

#### 5.2.2 确定性工具（`domain/scheduling_tools.py`）

Agent **不能自己算数学**，只能调用这些工具。工具是纯函数，无 IO。

```python
DECAY = -0.5
FACTOR = 19 / 81


def compute_retrievability(elapsed_days: float, stability: float) -> float:
    """R(t, S) = (1 + FACTOR * t / S) ^ DECAY"""
    if stability <= 0:
        return 0.0
    if elapsed_days <= 0:
        return 1.0
    return float((1 + FACTOR * elapsed_days / stability) ** DECAY)


def estimate_interval(stability: float, retention: float) -> float:
    """由目标保留率反解间隔天数：I = (S / FACTOR) * (r ^ (1/DECAY) - 1)"""
    if stability <= 0:
        return 0.0
    raw = (stability / FACTOR) * (retention ** (1 / DECAY) - 1)
    return float(min(max(raw, 1.0), 36500.0))


def initial_stability(rating: int, w: tuple[float, ...]) -> float:
    return float(w[rating - 1])


def next_stability_on_recall(s: float, d: float, r: float, rating: int, w) -> float:
    hard_penalty = w[15] if rating == 2 else 1.0
    easy_bonus = w[16] if rating == 4 else 1.0
    return float(
        s
        * (
            1
            + math.exp(w[8])
            * (11 - d)
            * s ** (-w[9])
            * (math.exp(w[10] * (1 - r)) - 1)
            * hard_penalty
            * easy_bonus
        )
    )


def next_stability_on_forget(s: float, d: float, r: float, w) -> float:
    return float(w[11] * d ** (-w[12]) * ((s + 1) ** w[13] - 1) * math.exp(w[14] * (1 - r)))
```

**工具契约**（供 Agent function calling 使用）：

| 工具 | 输入 | 输出 |
| --- | --- | --- |
| `get_due_cards` | `deck_ids`, `horizon_days` | `list[CardSnapshot]` |
| `get_card_quality` | `card_ids` | `list[CardQuality]`（错误次数/难度/历史评分） |
| `compute_retrievability` | `stability`, `elapsed_days` | `float` |
| `estimate_interval` | `stability`, `retention` | `float` |
| `check_budget` | `plan`, `daily_minutes` | `BudgetReport` |

#### 5.2.3 学习模式（Learner Profile）

```python
@dataclass(frozen=True)
class LearnerProfile:
    mode: Literal["standard", "sprint", "strong_memory", "custom"]
    daily_minutes: int
    exam_date: date | None
    desired_retention: float          # 0.70 – 0.99
    new_per_day: int
    max_reviews_per_day: int
```

| 模式 | `desired_retention` | `new_per_day` | 排程策略 |
| --- | --- | --- | --- |
| `standard` | 0.90 | 20 | 均衡 |
| `sprint` | 0.95 | 50 | 压缩间隔、按考纲优先级、允许超量 |
| `strong_memory` | 0.85 | 15 | 拉长间隔、降低频次 |
| `custom` | 用户指定 | 用户指定 | 完全手动 |

> **模式只影响未来排程**，不追溯历史记录（见需求文档 Q6）。

#### 5.2.4 输出契约

```python
@dataclass(frozen=True)
class ScheduleItem:
    card_id: UUID
    due_at: datetime
    interval_days: float
    rationale: str          # 一句话理由，面向用户展示

@dataclass(frozen=True)
class SchedulePlan:
    items: list[ScheduleItem]
    mode: str
    generated_at: datetime
    fallback_used: bool
```

#### 5.2.5 确定性护栏（`domain/scheduling_guard.py`）

**这是整个排程架构的质量底线。** 纯函数，输入 `SchedulePlan` + 当前状态，输出 `GuardResult`。

```python
@dataclass(frozen=True)
class GuardViolation:
    card_id: UUID
    rule: str
    detail: str

@dataclass(frozen=True)
class GuardResult:
    ok: bool
    violations: list[GuardViolation]

def validate(
    plan: SchedulePlan,
    previous: dict[UUID, ReviewState],
    ratings: dict[UUID, int],
    profile: LearnerProfile,
) -> GuardResult:
    """校验排程计划。任一规则不满足即 ok=False。"""
```

| 规则 | 说明 | 违反后果 |
| --- | --- | --- |
| `MONOTONIC_INTERVAL` | 同一卡片，评分越高间隔越长 | 该卡片降级 FSRS |
| `INTERVAL_BOUNDS` | `1 ≤ interval ≤ 365` 天 | 钳制到边界 |
| `DAILY_BUDGET` | 预计耗时 ≤ `daily_minutes × 1.15` | 按优先级截断 |
| `NO_DUPLICATE` | 同一卡片不出现多次 | 去重 |
| `NO_PAST_DUE` | `due_at > now` | 钳制到 `now + 1 天` |

**降级策略**：违反 `MONOTONIC_INTERVAL` 或 `INTERVAL_BOUNDS` 时，**该卡片**使用 FSRS 结果；其余卡片保留 Agent 结果。记录 `scheduler.fallback` 结构化日志。

#### 5.2.6 可复现性

排程必须可复现，否则无法调试、无法测试：

- LLM `temperature = 0`，`seed` 固定。
- 工具返回确定（SQL 加 `ORDER BY`）。
- 护栏是纯函数。
- 测试用固定 LLM 桩（fixture），断言 `SchedulePlan` 逐字段相等。

#### 5.2.7 测试要求

| 类型 | 范围 | 目标 |
| --- | --- | --- |
| 单元 | 工具函数（数学正确性） | 100% 分支 |
| 单元 | 护栏（每条规则 + 组合） | 100% 分支 |
| 单元 | 模式差异（sprint 间隔 < standard < strong_memory） | 属性测试 |
| 集成 | Agent 图执行 + 桩 LLM | 关键路径 |
| 回归 | 固定输入 → 快照比对 | 全量 |

**必须覆盖的用例**：

- Given 同一卡片连续「简单」，Then 间隔严格递增（护栏保证）
- Given Agent 输出间隔 400 天，Then 钳制到 365 天
- Given Agent 输出 `due_at` 在过去，Then 钳制到 `now + 1 天`
- Given 计划总耗时超预算，Then 按优先级截断
- Given 护栏失败，Then 该卡片使用 FSRS 结果且记录告警

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
3. 明文是问题或提示，暗文是答案；明文不得包含答案。
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

#### 五个 Agent

| Agent | 职责 | 输入 | 输出 | 人工介入 |
| --- | --- | --- | --- | --- |
| **CardSmith** | 制卡 | 资料文本 + 配置 | 卡片草稿列表 | ✅ 草稿确认 |
| **Scheduler** | **排程** | 复习记录 + 用户画像 + 卡片质量 | `SchedulePlan`（每卡 `due_at` + 理由） | ❌ 异步执行 |
| **Planner** | 长期学习计划 | 到期统计 + 时间预算 + 目标 | 7 天计划 | ✅ 计划确认 |
| **Tutor** | 答疑 | 问题 + 检索结果 | 带引用的回答 | ❌ 流式输出 |
| **Conductor** | 统筹调度（P1） | 全局状态 | 通知/建议 | ✅ 建议确认 |

> **Scheduler 与 Planner 的区别**：
>
> - **Scheduler** 决定「**这张卡片下次什么时候复习**」——细粒度、每卡一条、异步批量。
> - **Planner** 决定「**今天/本周学什么**」——粗粒度、按天聚合、需要用户确认。
>
> Planner 的输入依赖 Scheduler 的输出（`due_at` 分布），二者顺序执行。

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

#### Scheduler 图

```mermaid
flowchart LR
    Start([开始]) --> Load["加载待排程卡片<br/>（确定性）"]
    Load --> Profile["加载用户画像<br/>（确定性）"]
    Profile --> Decide["Agent 决策<br/>（LLM，温度 0）"]
    Decide -->|function calling| Tools["确定性工具"]
    Tools --> Decide
    Decide --> Plan["组装 SchedulePlan"]
    Plan --> Guard{"护栏校验"}
    Guard -->|通过| Write["写入 review_states"]
    Guard -->|违反| Fallback["该卡片降级 FSRS"]
    Fallback --> Write
    Write --> Emit["发布 schedule.updated 事件"]
    Emit --> End([结束])
```

**关键实现要点**：

- **无人工介入**：排程是后台任务，不阻塞用户。
- **批量**：一次处理一个用户的全部待排程卡片（上限 500），避免多次 LLM 调用。
- **部分失败**：单张卡片失败不影响其余，失败卡片用 FSRS 兜底。
- **可观测**：每次执行记录 `scheduler.run`（卡片数、耗时、token、fallback 数）。

#### Planner 图

```mermaid
flowchart LR
    Start([开始]) --> Load["加载到期统计<br/>（来自 Scheduler 输出）"]
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

> **注意**：`Budget` 与 `Prioritize` 是**确定性代码**（基于 Scheduler 产出的 `due_at`、`stability`、卡片集权重），LLM 只负责 `Explain` 生成自然语言理由。

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
| GET | `/decks/{id}/review-queue` | 获取**已排期**复习队列（客户端只读） |
| GET | `/review-queue` | 全局复习队列（跨卡片集） |
| POST | `/reviews` | 提交复习记录（幂等） |
| POST | `/reviews/batch` | 批量提交（离线重放），触发重排程 |
| GET | `/stats/decks/{id}` | 卡片集统计 |
| GET | `/stats/overview` | 全局统计 |

#### 排程

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/profile` | 获取学习画像 |
| PUT | `/profile` | 更新学习画像（模式/预算/考期） |
| POST | `/schedule/run` | 手动触发重排程（调试/管理用） |
| GET | `/schedule/runs` | 排程执行历史 |
| GET | `/schedule/items?card_id=` | 某卡片的排程决策记录（含理由） |

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
| POST | `/cards/{id}/ask` | **卡片内联答疑**（上下文=当前卡片） |
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

> **核心约束（ADR-004）：客户端不参与排程。** 本地库只存「缓存 + 待上报事件」，**不存排程算法、不计算 `due_at`**。

#### 本地表

| 表 | 用途 | 是否参与排程 |
| --- | --- | --- |
| `local_decks` | 卡片集缓存（只读） | ❌ |
| `local_cards` | 卡片内容缓存（只读） | ❌ |
| `local_review_queue` | **服务端已排期的今日队列**（预下载 7 天） | 只读消费 |
| `local_review_logs` | 待同步的复习记录（不可变事件） | ❌ 只上报 |
| `outbox` | 通用写操作队列 | ❌ |
| `sync_cursor` | 增量同步游标 | ❌ |

> **关键**：`local_review_queue` 是**服务端排程结果的副本**，客户端只按顺序消费，**不做任何重排**。`local_review_logs` 是**不可变事件流**，只追加、不修改——这使冲突面收窄到「同一事件的重复提交」，用幂等键即可解决。

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
    API-->>App: 变更集 + 排程队列 + new_cursor
    App->>Local: 事务内应用变更（覆盖队列）
    App->>Local: 更新 sync_cursor

    Note over App,Outbox: 离线复习
    App->>Local: 从 local_review_queue 取下一条
    App->>Outbox: 评分入队（含 idempotency_key）
    App->>Local: 标记该条已消费（不计算 due_at）

    Note over App,Outbox: 联网后
    Outbox->>API: POST /reviews/batch 按序重放
    API->>API: 服务端 Agent 重新排程
    API-->>Outbox: 200 + 新队列
    Outbox->>Local: 覆盖 local_review_queue
```

- **拉取**：`GET /sync?since=<cursor>` 返回 `updated_at > cursor` 的卡片集、卡片与**排程队列**。
- **推送**：Outbox 按 `created_at` 顺序重放，指数退避（1s → 2s → 4s → 8s → 16s），最多 5 次。
- **冲突**：因为客户端不写排程状态，冲突只可能发生在「同一 `review_id` 重复提交」——服务端幂等去重即可，**不需要**版本号或 CRDT。
- **队列过期**：预下载 7 天，超期未联网时提示「需联网更新排期」，允许继续消费旧队列但标注「可能不是最优」。

#### 自由浏览的离线语义

用户在离线状态下**自由浏览**（FR-4.4）时：

- 只读 `local_cards`，**不写** `local_review_logs`。
- 不产生任何排程副作用。
- 「浏览过」记录仅本地保存，不同步（避免无意义流量）。

### 7.5 卡片页面 UI 结构

> 依据 [卡片页面设计稿](卡片页面.png)。

#### 布局

```
┌──────────────────────────────────┐
│  ← 返回                    小星星 │  AppBar
├──────────────────────────────────┤
│  卡片明文                         │
│  ┌────────────────────────────┐  │
│  │ 线粒体的主要功能是什么？      │  │  FrontSection
│  └────────────────────────────┘  │
│                                  │
│  卡片暗文                         │
│  ┌────────────────────────────┐  │
│  │ ░░░░░ 点击翻页揭示 ░░░░░░░  │  │  BackSection（遮罩）
│  └────────────────────────────┘  │
│                                  │
│  图片                             │
│  ┌────────────────────────────┐  │
│  │        [ image ]           │  │  ImageSection
│  └────────────────────────────┘  │
├──────────────────────────────────┤
│  Agent 分析/解惑区          [展开] │  InlineChatSection
│  ┌────────────────────────────┐  │
│  │ （折叠时无内容）             │  │
│  └────────────────────────────┘  │
├──────────────────────────────────┤
│  选项/回答输入/提问输入区          │  InputSection
│  [A] [B] [C] [D]                 │
│  ┌──────────────────────┐ [发送] │
│  │ 输入你的回答/提问…    │        │
│  └──────────────────────┘        │
├──────────────────────────────────┤
│  ‹ 翻页                   1 / 20 ›│  PagerBar
└──────────────────────────────────┘
```

#### 组件树

```dart
CardPage
├── CardAppBar(back, StarRating)
├── SingleChildScrollView
│   ├── FrontSection(text)
│   ├── BackSection(text, revealed)
│   ├── ImageSection(images)
│   ├── InlineChatSection(cardId, collapsed)
│   └── InputSection(mode)
└── PagerBar(prev, next, index, total)
```

#### 两种模式

| 模式 | 暗文 | 输入区 | 评分 | 排程影响 |
| --- | --- | --- | --- | --- |
| **复习模式** | 默认遮罩，翻页揭示 | 显示 | 显示 | 记录 `review_log` |
| **浏览模式** | 直接展示 | 隐藏（只留提问） | 隐藏 | **无** |

#### 状态管理

```dart
@freezed
class CardPageState with _$CardPageState {
  const factory CardPageState({
    required Card card,
    required CardPageMode mode,       // review | browse
    @Default(false) bool revealed,    // 暗文是否揭示
    @Default(false) bool chatExpanded,
    @Default(0) int index,
    required int total,
  }) = _CardPageState;
}
```

#### 交互契约

| 交互 | 复习模式 | 浏览模式 |
| --- | --- | --- |
| 点击「翻页」 | 揭示暗文 | 切下一张 |
| 左右滑动 | 切下一张（已评分） | 切下一张 |
| 点击小星星 | 记录评分 + 切下一张 | 无响应（隐藏） |
| 点击图片 | 全屏查看 | 全屏查看 |
| 展开答疑区 | 请求 LLM（上下文=当前卡片） | 同左 |

### 7.6 卡片渲染器注册（扩展点）

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
    participant Sched as 排程 Agent
    participant DB as Postgres

    Note over App,DB: ① 预下载（联网时）
    App->>API: GET /sync?since=<cursor>
    API-->>App: 排程队列（未来 7 天）
    App->>Local: 写入 local_review_queue

    Note over App,DB: ② 复习（可离线）
    U->>App: 开始复习
    App->>Local: 读取 local_review_queue
    Local-->>App: 队列（服务端已排期）
    loop 每张卡片
        U->>App: 翻页揭示暗文
        U->>App: 小星星评分
        App->>Local: 追加 review_log（不可变事件）
        App->>Outbox: 入队（idempotency_key）
        Note right of App: 客户端不计算 due_at
    end

    Note over App,DB: ③ 同步（联网后）
    Outbox->>API: POST /reviews/batch
    API->>DB: 按 review_id 幂等去重
    API->>Sched: 触发重排程（异步）
    Sched->>Sched: Agent 决策 + 护栏校验
    Sched->>DB: 写入 review_states
    API-->>Outbox: 200 + 新队列
    Outbox->>Local: 覆盖 local_review_queue
```

> **关键决策（ADR-004）**：客户端**不实现排程算法**。离线复习是消费**服务端已排期**的队列，评分只作为不可变事件上报。
>
> 这带来三个好处：
>
> 1. **无双实现一致性风险**——不存在「Dart FSRS 与 Python FSRS 结果不一致」的问题。
> 2. **排程策略可随时调整**——改 Agent 提示词或护栏规则即可，不需要发版。
> 3. **冲突面极窄**——客户端不写排程状态，只需对 `review_id` 幂等去重。

### 8.3 自由浏览流程

```mermaid
sequenceDiagram
    autonumber
    participant U as 用户
    participant App as Flutter
    participant Local as Drift
    participant API as FastAPI

    U->>App: 点击卡片集内任意卡片
    App->>Local: 读取 local_cards
    Local-->>App: 卡片内容
    App->>App: 浏览模式（明文+暗文同时展示）
    loop 左右翻页
        U->>App: 滑动 / 点击翻页
        App->>Local: 读取下一张
    end
    U->>App: 点击「开始复习」
    App->>App: 切换到复习模式
    Note right of App: 浏览过程不产生 review_log
```

> **与复习模式的区别**：浏览模式**不写** `review_log`、**不显示**评分控件、**不影响**排程。用户随时可切换到复习模式。

### 8.4 答疑流程

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

### 8.5 计划生成流程

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
| 单元测试 | `domain/`（排程工具、护栏、去重、校验） | pytest | ≥ 90% |
| 集成测试 | `services/` + 真实 Postgres | pytest + testcontainers | ≥ 70% |
| API 测试 | 路由契约 | httpx + Schemathesis | 全部端点 |
| Agent 测试 | 图执行、interrupt/resume、**排程可复现** | pytest + 固定 LLM 桩 | 关键路径 |
| 移动端 | Widget + 单元 | flutter_test | ≥ 60% |
| E2E | 核心链路 | integration_test | 5 条主流程 |
| 性能 | 复习队列、搜索 | k6 | P95 达标 |

### 13.1 关键测试用例

**排程工具（纯函数）**
- `compute_retrievability`：`R(S, S) ≈ 0.9`
- `estimate_interval`：保留率越高间隔越短
- 边界：`stability` 极小/极大时不溢出

**排程护栏（核心）**
- 间隔单调性：连续「简单」评分的间隔严格递增
- 间隔越界：400 天 → 钳制到 365 天
- 过去时间：`due_at` 在过去 → 钳制到 `now + 1 天`
- 预算超限：总耗时 > `daily_minutes × 1.15` → 按优先级截断
- 降级：护栏失败 → 该卡片使用 FSRS 结果 + 记录告警

**排程模式差异**
- `sprint` 平均间隔 < `standard` < `strong_memory`
- 模式切换只影响未来，不追溯历史

**排程可复现**
- 固定输入 + 固定 LLM 桩 → `SchedulePlan` 逐字段相等
- 同一 `review_id` 重复同步 → 只排一次

**制卡**
- 加密 PDF → 明确错误
- 取消任务 → 草稿保留
- 重复提交 commit → 不产生重复卡片
- 质检：相似卡片被标记

**离线同步**
- 飞行模式复习 → 联网重放 → 服务端完成重排程
- 重复 `review_id` 提交 → 只记一次
- 自由浏览 → **不产生** `review_log`
- 队列过期 → 提示「需联网更新排期」

---

## 14. 技术风险与缓解

| # | 风险 | 影响 | 缓解 |
| --- | --- | --- | --- |
| T1 | LangGraph 版本不稳定 | 中 | `AgentRuntime` 接口隔离；锁定版本 |
| T2 | **排程 Agent 输出不稳定 / 不可复现** | 高 | 温度 0 + 固定 seed + 确定性工具 + 护栏降级；快照回归测试 |
| T3 | **排程延迟**（LLM 秒级） | 中 | 异步批量执行，不阻塞复习交互；队列预生成 |
| T4 | pgvector 检索性能不足 | 中 | HNSW 参数调优；预留 `VectorStore` 接口 |
| T5 | PDF 解析质量差 | 中 | 多引擎兜底（pypdf / pdfplumber / OCR） |
| T6 | LLM 输出不稳定导致解析失败 | 高 | 结构化输出 + 重试 + 降级为纯文本 |
| T7 | Flutter 包体积过大 | 低 | 按需加载；`--split-debug-info` |
| T8 | 推送到达率（国内 Android） | 中 | 接入厂商推送通道（P1） |
| T9 | 离线队列过期（用户长期不联网） | 低 | 7 天预下载 + 过期提示 + 允许消费旧队列 |

> **已消除的风险**：原 T2「客户端 FSRS 与服务端不一致」——因为客户端不参与排程（ADR-004），该风险不复存在。

---

## 15. 迭代路线

| 版本 | 内容 |
| --- | --- |
| **MVP (v1.0)** | 记忆卡片全链路、Agent 制卡、**排程 Agent（三种模式）**、卡片页面、计划、RAG 答疑 |
| v1.1 | 扫描件 OCR、图片生成、性能优化 |
| v1.5 | 学习模式自定义参数、厂商推送通道 |
| v2.0 | 卡片社区、日程卡片、灵感卡片、多人共享 |
| v3.0 | 插件市场、自定义 Agent、开放 API |
| 未排期 | 桌面端 / Web 制卡台（见需求文档 §8） |

---

## 附录 A：关键常量

| 常量 | 值 | 说明 |
| --- | --- | --- |
| `FSRS_DECAY` | -0.5 | 遗忘曲线衰减 |
| `FSRS_FACTOR` | 19/81 | 缩放因子 |
| `DEFAULT_RETENTION` | 0.9 | 默认目标保留率 |
| `NEW_PER_DAY` | 20 | 每日新卡上限（`standard`） |
| `SPRINT_NEW_PER_DAY` | 50 | 冲刺模式每日新卡上限 |
| `MIN_INTERVAL_DAYS` | 1 | 排程间隔下界 |
| `MAX_INTERVAL_DAYS` | 365 | 排程间隔上界 |
| `BUDGET_TOLERANCE` | 1.15 | 每日预算容忍系数 |
| `SCHEDULE_BATCH_SIZE` | 500 | 单次排程卡片上限 |
| `QUEUE_PREFETCH_DAYS` | 7 | 客户端预下载队列天数 |
| `DEDUP_THRESHOLD` | 0.9 | 疑似重复相似度阈值 |
| `CHUNK_SIZE` | 512 | 资料切分 token |
| `CHUNK_OVERLAP` | 64 | 切分重叠 |
| `RAG_TOP_K` | 6 | 检索返回数 |
| `RRF_K` | 60 | RRF 融合参数 |
| `DRAFT_TTL_DAYS` | 7 | 草稿保留天数 |
| `SOFT_DELETE_DAYS` | 30 | 软删除保留天数 |

## 附录 B：术语

见 [MVP 需求文档 · 附录 A](02-MVP需求文档.md#附录-a术语表)。
