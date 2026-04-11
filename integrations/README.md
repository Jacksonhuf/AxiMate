# AxiMate 集成目录（`integrations/`）

本目录按 **AxiMate 产品子品牌** 组织与三大开源上游的对接说明及自有扩展位。**上游源码不放入本仓库**（不 vendoring）；合规与 SBOM 须写明真实项目名 **Higress、HiClaw、CoPaw**。

## 产品线命名（意象 · 水流）

| 目录 | AxiMate 产品名 | 意象 | 上游 |
|------|----------------|------|------|
| [`spring/`](spring/README.md) | **AxiMate Spring** | 泉源：统一入口 | [Higress](https://github.com/alibaba/higress) |
| [`confluence/`](confluence/README.md) | **AxiMate Confluence** | 汇流：多能力协同编排 | [HiClaw](https://github.com/alibaba/hiclaw) |
| [`ripple/`](ripple/README.md) | **AxiMate Ripple** | 涟漪：轻量执行与扩散 | [CoPaw](https://github.com/agentscope-ai/CoPaw) |

**说明：** 「Confluence」为 AxiMate 内部产品线名，与第三方协作软件同名；对外文档建议使用全称 **AxiMate Confluence**，并在括号中标注 *Powered by HiClaw* 以免混淆。

**当前优先开发入口：** **`integrations/ripple/`**（单机 CoPaw 扩展）。

云上安装 **Confluence 栈**（含 **Spring** 网关）：根目录 **[`deploy/`](../deploy/)**（调用上游 `hiclaw-install.sh`）。

完整目录树与设计原则：**[`docs/DIRECTORY.md`](../docs/DIRECTORY.md)**。
