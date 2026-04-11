# AxiMate 产品线打包与发布规则（项目级）

本文档为 **AxiMate 全仓库约定**：规划发行物、对外承诺与文档表述时须遵守。三条产品线命名与目录见 **`docs/DIRECTORY.md`**；对外合规须使用上游真实名称 **Higress / HiClaw / CoPaw** 及 **Powered by** 表述。

## 规则总览

| 产品线 | 是否允许 **单独** 打包发布 | 约定 |
|--------|------------------------------|------|
| **AxiMate Ripple**（Powered by CoPaw） | **允许，且推荐可作为独立 SKU** | 与上游 CoPaw 交付形态一致（pip / Docker 等）；本仓 `integrations/ripple/` 可随文档与扩展单独发行。 |
| **AxiMate Spring**（Powered by Higress） | **允许** | 等同独立发行 **Higress**（Helm / 云镜像等）；可与 Confluence 栈解耦销售。 |
| **AxiMate Confluence**（Powered by HiClaw） | **允许，但须按「整套 HiClaw 栈」理解** | 上游安装通常 **捆绑** Matrix、MinIO、Manager 与 **Higress（Spring）**；**不得**对外承诺「仅 Confluence、完全不含网关」除非已 fork/改造上游安装与架构。 |
| **Confluence 与 Ripple** | 可拆分 | 常见组合：云上 Confluence 栈 + 可选 Ripple 单机/边缘包。 |

## 对外表述禁令（避免过度承诺）

1. **不得**承诺 **Confluence** 交付物中 **不包含** AI/API 网关能力（除非实现已与上游 HiClaw 默认架构脱钩并经书面确认）。  
2. **须**在对外材料中区分 **AxiMate Confluence** 与第三方同名协作产品（建议使用全称 + *Powered by HiClaw*）。  
3. **须**在每类发行物随附或引用 **SBOM**，并标明各上游 **Apache-2.0** 及 NOTICE 义务（见 **`docs/COMPLIANCE-APACHE2.md`**）。

## 与仓库目录的关系

- **`integrations/spring|confluence|ripple/`** — 各产品线在 monorepo 中的文档与扩展位；**不等于**单独安装包，但 **规划独立 SKU 时以本规则为准**。  
- **`deploy/`** — 当前默认对应 **Confluence（HiClaw）** 云上安装路径（内含 Spring 层能力）。

## 修订

变更产品线发布策略时，须 **同步更新本文档** 并复核 **`NOTICE`**、**`README.md`** 与合规文档。
