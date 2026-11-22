# CardSharp 开发者命令
#
# Windows 用户若无 make，可直接执行对应命令（见 CONTRIBUTING.md）。
# 所有目标均在仓库根目录执行。

SHELL := /bin/bash
.DEFAULT_GOAL := help

BACKEND := backend
MOBILE  := mobile
COMPOSE := docker compose -f deploy/docker-compose.yml

.PHONY: help
help: ## 显示所有可用命令
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

# ---------------------------------------------------------------- 环境

.PHONY: setup
setup: ## 一次性初始化：安装前后端依赖
	cd $(BACKEND) && uv sync --all-groups
	cd $(MOBILE) && flutter pub get
	@test -f $(BACKEND)/.env || cp $(BACKEND)/.env.example $(BACKEND)/.env
	@echo "✅ 依赖安装完成。记得编辑 backend/.env 填入 LLM_API_KEY"

.PHONY: infra-up
infra-up: ## 启动本地依赖（Postgres / Redis / MinIO）
	$(COMPOSE) up -d postgres redis minio

.PHONY: infra-down
infra-down: ## 停止本地依赖
	$(COMPOSE) down

.PHONY: infra-reset
infra-reset: ## 清空本地数据卷（危险）
	$(COMPOSE) down -v

# ---------------------------------------------------------------- 后端

.PHONY: dev
dev: ## 启动后端开发服务器（热重载）
	cd $(BACKEND) && uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

.PHONY: worker
worker: ## 启动异步 Worker
	cd $(BACKEND) && uv run arq app.workers.main.WorkerSettings

.PHONY: migrate
migrate: ## 应用数据库迁移
	cd $(BACKEND) && uv run alembic upgrade head

.PHONY: migration
migration: ## 生成迁移（make migration m="描述"）
	cd $(BACKEND) && uv run alembic revision --autogenerate -m "$(m)"

.PHONY: test
test: ## 运行后端测试
	cd $(BACKEND) && uv run pytest

.PHONY: lint
lint: ## 后端静态检查
	cd $(BACKEND) && uv run ruff check . && uv run ruff format --check .

.PHONY: fmt
fmt: ## 后端自动格式化
	cd $(BACKEND) && uv run ruff check --fix . && uv run ruff format .

.PHONY: typecheck
typecheck: ## 后端类型检查
	cd $(BACKEND) && uv run mypy app

# ---------------------------------------------------------------- 移动端

.PHONY: app-test
app-test: ## 运行 Flutter 测试
	cd $(MOBILE) && flutter test

.PHONY: app-lint
app-lint: ## Flutter 静态检查
	cd $(MOBILE) && flutter analyze

.PHONY: app-fmt
app-fmt: ## Flutter 格式化
	cd $(MOBILE) && dart format --line-length 100 lib test

.PHONY: app-gen
app-gen: ## 生成代码（freezed / json / drift / retrofit）
	cd $(MOBILE) && dart run build_runner build --delete-conflicting-outputs

.PHONY: app-run
app-run: ## 在已连接设备上运行 App
	cd $(MOBILE) && flutter run

# ---------------------------------------------------------------- 质量门禁

.PHONY: check
check: lint typecheck test app-lint app-test ## 提交前完整检查
	@echo "✅ 全部检查通过"
