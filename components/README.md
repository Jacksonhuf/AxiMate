# AxiMate × 上游组件

本仓库按 **三个独立上游** 划分产品与扩展边界（**不 vendoring** 其源码，仅文档、胶水与自有扩展）：

| 目录 | 上游 | 角色 |
|------|------|------|
| [`copaw/`](copaw/README.md) | [CoPaw](https://github.com/agentscope-ai/CoPaw) | Worker / 单机助手运行时；**当前优先开发入口** |
| [`hiclaw/`](hiclaw/README.md) | [HiClaw](https://github.com/alibaba/hiclaw) | 多 Agent 编排、Matrix、MinIO；与根目录 [`deploy/`](../deploy/) 对接安装 |
| [`higress/`](higress/README.md) | [Higress](https://github.com/alibaba/higress) | AI/API 网关；随 HiClaw 安装部署，本目录为概念与扩展说明 |

完整目录树与设计说明：**[`docs/DIRECTORY.md`](../docs/DIRECTORY.md)**。
