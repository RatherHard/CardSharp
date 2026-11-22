# CardSharp 卡锐思

> 可拓展的 AI 卡片助手：用 Agent 把资料变成可运行的卡片集合，用长期学习计划驱动持续记忆。

## 这是什么

CardSharp 不是又一个 Anki 克隆。它把「卡片」抽象成一种**可运行的内容单元**，把「卡片集合」抽象成**带类型的能力包**（显示格式 / 运行形式 / 生成工作流 / 知识库建立方式）。MVP 先落地「记忆卡片」这一最通用的场景，但所有接口都按多类型设计，后续可平移到日程卡片、灵感卡片等。

## 文档

| 文档 | 说明 |
| --- | --- |
| [项目提案](docs/00-项目提案.md) | 最初的问题定义与功能设想 |
| [MVP 设计草案](docs/01-MVP设计草案.md) | 早期设计草稿（已被 03 取代，保留以追溯思路） |
| [MVP 需求文档](docs/02-MVP需求文档.md) | 范围、用户故事、功能与非功能需求、验收标准 |
| [MVP 设计文档](docs/03-MVP设计文档.md) | 技术栈、架构、数据模型、模块与接口设计 |

## 技术栈（已定）

| 层 | 选型 |
| --- | --- |
| 移动端 | Flutter 3.x（Dart 3） |
| 后端 | Python 3.12 + FastAPI |
| 数据库 | PostgreSQL 16 + pgvector |
| Agent 编排 | LangGraph（Postgres checkpointer + interrupt 人工确认） |
| 异步任务 | Redis + ARQ |
| 对象存储 | S3 兼容（MinIO / 阿里云 OSS） |

## 仓库结构（规划）

```
CardSharp/
├── docs/            # 需求与设计文档
├── backend/         # FastAPI 服务 + Agent 编排
├── app/             # Flutter 移动端
├── deploy/          # Docker Compose / 迁移脚本
└── README.md
```

## 状态

MVP 需求与设计评审中，尚未开始编码。
