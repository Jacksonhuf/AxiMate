# AxiMate Confluence（编排层 · Powered by HiClaw）

**意象：** 汇流 — 多股能力汇合协同。  
**上游：** [alibaba/hiclaw](https://github.com/alibaba/hiclaw) · **License:** Apache-2.0  

HiClaw 提供 **Manager / Workers**、**Matrix（Tuwunel）**、**MinIO** 等；**Higress（Spring 层）** 随官方安装一并拉起。

## 与本仓库的对接

| 路径 | 说明 |
|------|------|
| **[`deploy/`](../deploy/)**（仓库根目录） | 服务器引导、`deploy/.env`、SSH 脚本、**[`deploy/native/install-hiclaw.sh`](../deploy/native/install-hiclaw.sh)** 调用上游安装脚本 |

不在 `integrations/confluence/` 下重复放置安装脚本，以保持与服务器路径 **`/opt/aximate/deploy`** 的约定一致。

## 文档

- 架构：`docs/ARCHITECTURE.md`
- 目录：`docs/DIRECTORY.md`
- 合规：`docs/COMPLIANCE-APACHE2.md`

## 命名提示

对外建议使用 **「AxiMate Confluence（Powered by HiClaw）」**，与第三方同名产品区分。
