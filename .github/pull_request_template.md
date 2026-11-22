## 改了什么

<!-- 一句话概括本次改动 -->

## 为什么

<!-- 关联需求 / issue，说明动机。没有关联 issue 请说明原因 -->

Closes #

## 怎么验证

<!-- 复现步骤 / 测试命令 / 截图 -->

```bash
make check
```

## 影响面

- [ ] 数据库 Schema 变更（含迁移文件）
- [ ] API 契约变更（需同步 `docs/03-MVP设计文档.md`）
- [ ] 破坏性变更（需在提交 footer 写 `BREAKING CHANGE:`）
- [ ] 需要更新环境变量（需同步 `backend/.env.example`）

## 自检

- [ ] `make check` 全绿
- [ ] 新增/修改代码有测试覆盖
- [ ] 无调试残留（`print` / `debugPrint` / `TODO`）
- [ ] 无硬编码密钥
- [ ] 分层未被破坏（`routers → services → domain`）
- [ ] 提交信息符合 [Conventional Commits](CONTRIBUTING.md#4-提交信息规范)
