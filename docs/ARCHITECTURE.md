# AxiMate 架构

## 产品定位与上游基础

**AxiMate** 建立在原生开源项目 **Higress**、**HiClaw**、**CoPaw** 之上：

- **Higress**：由 **HiClaw 官方安装流程**一并部署为 AI Gateway（流量、MCP、凭据隔离等）。
- **HiClaw**：多 Agent 编排与协作运行时（Manager / Workers、Matrix、MinIO 等）。
- **CoPaw**：在 HiClaw 中作为 **Worker 运行时** 选用（轻量 Worker）；非本仓库内自研 Python Worker 容器。

三者均为 **Apache-2.0**（以各仓库及发布物 `LICENSE` 为准；发版时用 SBOM 锁定版本并复核）。

## AxiMate 产品线命名（意象 · 水流）

对外可使用子品牌与上游并列说明（示例：**AxiMate Spring（Powered by Higress）**）：

| 产品名 | 对应上游 | 意象 |
|--------|----------|------|
| **AxiMate Spring** | Higress | 泉源 · 统一入口 |
| **AxiMate Confluence** | HiClaw | 汇流 · 编排协同 |
| **AxiMate Ripple** | CoPaw | 涟漪 · 轻量执行 |

仓库目录映射见 **`docs/DIRECTORY.md`**（`integrations/spring|confluence|ripple/`）。

## 逻辑分层（与上游对应关系）

```text
用户 / 客户端（如 Element Web）
        │
        ▼
┌───────────────────────────────────┐
│  HiClaw 平台（上游）                │
│  · Higress AI Gateway             │
│  · Manager / Workers（含 CoPaw 等） │
│  · Matrix / MinIO / …             │
└───────────────────────────────────┘
```

本仓库 **不再** 通过自建 Nginx + 自研编排 + 自研 Worker 的 Compose 模拟上述能力；云上部署请走 **`deploy/` 中的 HiClaw 原生安装脚本**。

## 通信约定

- 服务间扩展时优先 **gRPC** 或 **REST**。
- 工具与模型侧能力与 **MCP**、Higress 网关策略对齐（参见 HiClaw / Higress 文档）。

## 技术栈（产品扩展）

| 区域 | 说明 |
|------|------|
| 网关与 AI 代理 | 上游 **Higress**（随 HiClaw 部署） |
| 编排 | 上游 **HiClaw** |
| Worker 运行时 | 上游 **CoPaw**（在 HiClaw 内配置） |
| 自有控制台 / 门户 | 规划 **React + Ant Design**（本仓库尚未实现） |

## 仓库组织（Monorepo）

本仓存放文档、合规与 **部署自动化**；运行时镜像与安装逻辑来自 **HiClaw 官方安装脚本** 及上游镜像仓库。

按 **Spring / Confluence / Ripple** 产品线划分的物理目录见 **`docs/DIRECTORY.md`**（**`integrations/spring|confluence|ripple/`**）；当前优先在 **`integrations/ripple/`** 扩展。**`deploy/`** 固定在仓库根目录，与服务器 `/opt/aximate/deploy` 约定一致。

## 与合规文档的关系

上游 Apache-2.0 组件的版本、NOTICE 与再分发方式见 `docs/COMPLIANCE-APACHE2.md`。

## 仅基于 Ripple（CoPaw）的本地开发

不部署 Confluence（HiClaw）时，可在本机按 **`docs/DEV-RIPPLE.md`** 安装与扩展 CoPaw（Skills / MCP）；与 HiClaw 的衔接见该文档末尾。
