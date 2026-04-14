# CoPaw（AxiMate 扩展面）

**上游：** [agentscope-ai/CoPaw](https://github.com/agentscope-ai/CoPaw) · [文档](https://copaw.agentscope.io/docs/intro) · **License:** Apache-2.0  

AxiMate 在 **不部署 HiClaw** 时，可仅基于 CoPaw 做 Skills、MCP、模型与渠道扩展。

## 本目录

| 路径 | 说明 |
|------|------|
| [`extensions/`](extensions/README.md) | AxiMate 自有的 skill 模板、脚本或说明（需按 CoPaw working dir 配置同步到运行环境） |

## 开发指引

详见 **`docs/DEV-COPAW.md`**（安装方式：pip / Docker / 上游源码）。

## 与 HiClaw 的关系

在 HiClaw 中选 **CoPaw Worker** 时，通过上游 **`copaw-worker`**（PyPI）接入 Matrix 与 MinIO；单机 CoPaw 与 Worker 模式目录不同，**Skills / MCP 设计可复用**。
