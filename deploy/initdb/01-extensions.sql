-- 初始化扩展。仅在数据库首次创建时执行一次。
-- pgvector 由 pgvector/pgvector 镜像提供。

CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS citext;

-- 中文全文检索：使用 simple 配置 + pg_trgm 兜底。
-- 生产环境可替换为 zhparser / pg_jieba。
