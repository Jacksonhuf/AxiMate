# AxiMate 架构

## 三层职责

```text
Client / Model consumers
        │
        ▼
┌───────────────────────────────────┐
│  AxiMate Gateway (Higress)        │
│  鉴权 · AI Proxy · 多模型路由     │
│  Wasm 插件（策略、审计、限流等）   │
└───────────────────────────────────┘
        │ gRPC / REST
        ▼
┌───────────────────────────────────┐
│  AxiMate Orchestrator (HiClaw)    │
│  任务拆解 · Multi-Agent · 状态     │
└───────────────────────────────────┘
        │ gRPC / REST / MCP client
        ▼
┌───────────────────────────────────┐
│  AxiMate Worker (MCP skills)        │
│  具体 Tool/Skill 执行               │
└───────────────────────────────────┘
```

## 通信约定

- 服务间优先 **gRPC** 或 **REST**。
- Worker 能力以 **MCP（Model Context Protocol）** 暴露，便于统一工具发现与调用，并与网关侧代理策略对齐。

## 技术栈（约束）

| 区域 | 首选语言 / 框架 |
|------|-----------------|
| Gateway 扩展 | Go（Higress / Envoy Wasm） |
| Orchestrator | Python（与 HiClaw / Agent 生态对齐） |
| Worker | Python 或 Go；对外协议 MCP |
| 控制台 / 门户 | React + Ant Design |

## 仓库组织（Monorepo）

Gateway、Orchestrator、Worker 作为**同一仓库**中的目录协同演进（见根目录 `README.md` 中 **Monorepo development model**）。上游开源组件以依赖或独立 Fork 形式对齐版本；除非团队与发布节奏需要，暂不拆成三个独立业务仓库。

## 与合规文档的关系

上游 Apache-2.0 组件的版本、NOTICE 与再分发方式见 `docs/COMPLIANCE-APACHE2.md`。
