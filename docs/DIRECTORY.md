# AxiMate 仓库目录设计

AxiMate 基于三个 **独立上游**：**Higress**、**HiClaw**、**CoPaw**（均为 Apache-2.0）。本仓库 **不内嵌** 其源码；用目录表达 **AxiMate 产品线边界** 与 **自有扩展**。对外合规与 SBOM 须使用上游真实名称与许可证。

## 产品线与目录（意象 · 方案 2 · 水流）

| AxiMate 产品名 | 目录 | 意象 | 上游 |
|----------------|------|------|------|
| **AxiMate Spring** | `integrations/spring/` | 泉源 · 统一入口 | Higress |
| **AxiMate Confluence** | `integrations/confluence/` | 汇流 · 编排协同 | HiClaw |
| **AxiMate Ripple** | `integrations/ripple/` | 涟漪 · 轻量执行 | CoPaw |

**命名说明：** 「Confluence」为 AxiMate 子品牌，与第三方协作软件可能同名；对外建议使用全称 **AxiMate Confluence**，并标注 *Powered by HiClaw*。

## 为何使用 `integrations/`

| 目录名 | 常见含义 | 本仓库 |
|--------|----------|--------|
| `components/` | 易与前端 UI 组件混淆 | 未采用 |
| `integrations/` | 与外部系统 / 上游的对接与扩展 | **采用** |
| `packages/` | 可发布多包 workspace | 预留，自有库时再建 |

## 设计原则

1. **`integrations/{spring,confluence,ripple}/`** — 与三产品线一一对应；内含 README 与 AxiMate 自有扩展位。  
2. **`deploy/`** — 固定在 **仓库根目录**，与服务器 **`/opt/aximate/deploy`** 一致（安装 **Confluence 栈**，内含 **Spring** 网关）。  
3. **`docs/`** — 跨产品线架构、合规、目录说明与 **Ripple** 开发指南（`DEV-RIPPLE.md`）。  
4. **当前阶段** — 优先在 **`integrations/ripple/extensions/`** 落地扩展。  
5. **打包与发布** — 须遵守项目级规则 **`docs/PRODUCT-PACKAGING.md`**（何者可单独 SKU、Confluence 与网关关系等）。

## 目录树

```text
AxiMate/
├── README.md
├── LICENSE / NOTICE
├── integrations/
│   ├── README.md                 # Spring / Confluence / Ripple 索引
│   ├── spring/                   # AxiMate Spring（Higress）
│   │   └── README.md
│   ├── confluence/               # AxiMate Confluence（HiClaw）
│   │   └── README.md
│   └── ripple/                   # AxiMate Ripple（CoPaw）— 当前优先扩展
│       ├── README.md
│       └── extensions/
│           └── README.md
├── deploy/                       # 云上安装 HiClaw（含 Higress）
│   ├── .env.example
│   ├── README.md
│   ├── native/install-hiclaw.sh
│   └── scripts/ …
└── docs/
    ├── ARCHITECTURE.md
    ├── DIRECTORY.md              # 本文件
    ├── PRODUCT-PACKAGING.md      # 产品线单独/合并发布 — 项目级规则
    ├── COMPLIANCE-APACHE2.md
    ├── DEV-RIPPLE.md             # Ripple（CoPaw）本地开发
    └── DEV-COPAW.md              # 重定向至 DEV-RIPPLE.md
```

## 产品线、上游与路径对应

| 上游 | 运行时来源 | 本仓库位置 |
|------|------------|------------|
| **CoPaw** | pip / docker / 上游 Git | `integrations/ripple/` · `docs/DEV-RIPPLE.md` |
| **HiClaw** | 官方 `hiclaw-install.sh`（`deploy/` 调用） | `deploy/` · `integrations/confluence/README.md` |
| **Higress** | HiClaw 安装拉起 | `integrations/spring/README.md`；实操见上游文档 |

## 后续可扩展（按需）

- `integrations/confluence/patches/` — 对上游补丁说明（一般不提交上游源码）。  
- `integrations/spring/policies/` — 路由 / Wasm 策略片段。  
- **`packages/`** — AxiMate 自有可发布库；与 `integrations/` 并存。

## 变更摘要

- `integrations/` 下目录由上游名改为 **产品线目录名**：`spring` / `confluence` / `ripple`。  
- `docs/DEV-COPAW.md` 重命名为 **`docs/DEV-RIPPLE.md`**；原路径保留 **短重定向文件**。
