# 基于 CoPaw 的本地开发（AxiMate）

AxiMate 的运行时之一来自上游 **[CoPaw](https://github.com/agentscope-ai/CoPaw)**（Apache-2.0）。你可以**只在本机开发 CoPaw 扩展**，不必先部署 HiClaw；需要 Matrix / Manager / Higress 统一出口时，再接入 **HiClaw + `copaw-worker`**。

## 官方文档（优先阅读）

| 主题 | 链接 |
|------|------|
| 总览 | [CoPaw 文档 — Introduction](https://copaw.agentscope.io/docs/intro) |
| 安装与快速开始 | [Quick start](https://copaw.agentscope.io/docs/quickstart) |
| 模型与 Key | [Models](https://copaw.agentscope.io/docs/models) |
| Skills | [Skills](https://copaw.agentscope.io/docs/skills) |
| MCP | [MCP](https://copaw.agentscope.io/docs/mcp) |
| 配置与工作目录 | [Config](https://copaw.agentscope.io/docs/config) |
| 多 Agent（CoPaw 内） | [Multi-Agent](https://copaw.agentscope.io/docs/multi-agent) |
| 源码与贡献 | [CoPaw GitHub](https://github.com/agentscope-ai/CoPaw) |

## 推荐本地环境

- **Python**：3.10–3.13（以 [CoPaw README](https://github.com/agentscope-ai/CoPaw) 为准）。
- **本仓库**：继续放产品文档、合规与部署脚本；CoPaw **本体**不 vendoring，用 pip / Docker / 单独 clone 开发。

## 方式 A：`pip`（迭代 Skills / 行为最快）

```bash
pip install copaw
copaw init          # 交互配置；或 copaw init --defaults
copaw app
```

浏览器打开 Console（常见为 **http://127.0.0.1:8088**），在 **Settings → Models** 配置 API Key，再按官方文档启用 Skills / MCP。

## 方式 B：Docker（接近单机交付形态）

```bash
docker pull agentscope/copaw:latest
docker run -p 127.0.0.1:8088:8088 \
  -v copaw-data:/app/working \
  -v copaw-secrets:/app/working.secret \
  agentscope/copaw:latest
```

密钥与模型配置见镜像说明与 [Models](https://copaw.agentscope.io/docs/models)。

## 方式 C：从源码跑 CoPaw（要改 CoPaw 核心或提 PR）

```bash
git clone https://github.com/agentscope-ai/CoPaw.git
cd CoPaw
cd console && npm ci && npm run build && cd ..
mkdir -p src/copaw/console && cp -R console/dist/. src/copaw/console/
pip install -e .
copaw init --defaults
copaw app
```

细节以上游 `README.md` 的 **Install from source** 为准。

## 在 AxiMate 仓里放什么

- **`components/copaw/extensions/`**：放 **AxiMate 自有的 skill 模板、说明或脚本**；实际加载路径需按 CoPaw 的 working dir / 配置把文件放到 CoPaw 能扫描的位置，或用手动复制、符号链接（以 [Config](https://copaw.agentscope.io/docs/config) 为准）。
- **产品逻辑**：优先通过 **Skill + MCP** 扩展，减少对 CoPaw 核心的 fork 面。

目录总览见 **`docs/DIRECTORY.md`**。

## 与 HiClaw / Higress 的衔接（后续）

当你需要 **Matrix 房间协作、Manager 派单、Higress 统一 LLM/MCP 凭据** 时：

1. 再使用本仓库 **`deploy/`** 部署 HiClaw。
2. Worker 选择 **CoPaw**，使用上游 **`copaw-worker`**（PyPI）与 [HiClaw worker 文档](https://github.com/alibaba/hiclaw) 对接。

在 HiClaw 里跑的 Worker 与单机 CoPaw 的目录结构不同，但 **Skills/MCP 的设计思路可复用**。

## 许可证

CoPaw 为 **Apache-2.0**；发版时在你的 SBOM 中锁定版本并保留 NOTICE 要求，见 `docs/COMPLIANCE-APACHE2.md`。
