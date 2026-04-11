# AxiMate Ripple — 本地开发（Powered by CoPaw）

**Ripple** 为 AxiMate 产品线中的 **轻量执行 / 单机助手** 层（意象：涟漪，轻触即扩散）。运行时基于上游 **[CoPaw](https://github.com/agentscope-ai/CoPaw)**（Apache-2.0）。你可**只在本机开发扩展**，不必先部署 **Confluence（HiClaw）** 与 **Spring（Higress）**；需要 Matrix / Manager / 统一网关时再接入 HiClaw + `copaw-worker`。

仓库内自有资产目录：**`integrations/ripple/extensions/`**。

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
- **本仓库**：不 vendoring CoPaw 源码；用 pip / Docker / 单独 clone 开发。

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

- **`integrations/ripple/extensions/`**：AxiMate 自有的 skill 模板、说明或脚本；实际加载路径需按 CoPaw 的 working dir / 配置同步（见 [Config](https://copaw.agentscope.io/docs/config)）。
- **产品逻辑**：优先 **Skill + MCP** 扩展，少 fork CoPaw 核心。

目录总览：**`docs/DIRECTORY.md`**。

## 与 Confluence（HiClaw）/ Spring（Higress）的衔接

需要 **Matrix、Manager、Higress 统一 LLM/MCP 凭据** 时：

1. 使用本仓库 **`deploy/`** 部署 HiClaw（内含 Higress）。
2. Worker 选 **CoPaw**，通过 **`copaw-worker`**（PyPI）与 [HiClaw worker 文档](https://github.com/alibaba/hiclaw) 对接。

Worker 模式与单机 CoPaw 目录不同，**Skills/MCP 思路可复用**。

## Windows 桌面版 Console UI（品牌化）

Ripple 定位为 **桌面产品** 时，对 CoPaw **Web Console** 的 Windows 优先 UI 与 **AxiMate Ripple** 文案由本仓库维护：

- 说明与脚本：**[`integrations/ripple/desktop-windows/README.md`](../integrations/ripple/desktop-windows/README.md)**
- 对上游的差异：**`integrations/ripple/desktop-windows/patches/001-ripple-windows-ui.patch`**（构建时设置 **`VITE_RIPPLE_DESKTOP=1`**）

## 许可证

CoPaw 为 **Apache-2.0**；发版时在 SBOM 锁定版本并保留 NOTICE，见 `docs/COMPLIANCE-APACHE2.md`。
