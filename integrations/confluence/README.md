# HiClaw（AxiMate 编排面）

**上游：** [alibaba/hiclaw](https://github.com/alibaba/hiclaw) · **License:** Apache-2.0  

HiClaw 提供 **Manager / Workers**、**Matrix（Tuwunel）**、**MinIO** 等；**Higress AI Gateway** 随官方安装一并拉起。

## 与本仓库的对接

| 路径 | 说明 |
|------|------|
| **[`deploy/`](../deploy/)**（仓库根目录） | 服务器引导、`deploy/.env`、SSH 脚本、**[`deploy/native/install-hiclaw.sh`](../deploy/native/install-hiclaw.sh)** 调用上游安装脚本 |

不在 `integrations/hiclaw/` 下重复放安装脚本，避免与服务器路径 `/opt/aximate/deploy` 约定不一致。

## 文档

- 架构总览：`docs/ARCHITECTURE.md`
- 目录设计：`docs/DIRECTORY.md`
- 合规：`docs/COMPLIANCE-APACHE2.md`
