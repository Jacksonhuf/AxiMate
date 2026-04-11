# AxiMate Ripple（执行层 · Powered by CoPaw）

**意象：** 涟漪 — 轻触即扩散、落地具体任务。  
**上游：** [agentscope-ai/CoPaw](https://github.com/agentscope-ai/CoPaw) · [文档](https://copaw.agentscope.io/docs/intro) · **License:** Apache-2.0  

不部署 **Confluence（HiClaw）** 时，可仅基于 CoPaw 做 Skills、MCP、模型与渠道扩展。

## 本目录

| 路径 | 说明 |
|------|------|
| [`extensions/`](extensions/README.md) | AxiMate 自有的 skill 模板、脚本或说明（需按 CoPaw working dir 配置同步到运行环境） |
| [`desktop-windows/`](desktop-windows/README.md) | **Windows 桌面** Console：Ripple 品牌化 UI、patch 与 `bootstrap` / `dev` / `build` 脚本 |

## 开发指引

详见 **`docs/DEV-RIPPLE.md`**（pip / Docker / 上游源码安装）。

## 与 Confluence（HiClaw）的关系

在 HiClaw 中选择 **CoPaw Worker** 时，通过 **`copaw-worker`**（PyPI）接入 Matrix 与 MinIO；单机 Ripple（CoPaw）与 Worker 模式目录不同，**Skills / MCP 设计可复用**。
