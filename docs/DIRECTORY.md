# AxiMate 仓库目录设计

AxiMate 基于三个 **独立上游**：**Higress**、**HiClaw**、**CoPaw**（均为 Apache-2.0）。本仓库 **不内嵌** 其源码，用目录表达 **产品边界** 与 **自有扩展**；运行时版本由安装方式与 SBOM 锁定。

## 设计原则

1. **`components/`** — 按上游组件划分 **文档与 AxiMate 自有扩展**；三者平级，职责清晰。  
2. **`deploy/`** — 保留在 **仓库根目录**，与服务器约定路径 `/opt/aximate/deploy` 一致，避免破坏现有脚本与文档链接。  
3. **`docs/`** — 跨组件架构、合规、总览类文档。  
4. **当前阶段** — 优先在 **`components/copaw/`** 落地扩展；HiClaw / Higress 以 `deploy/` 与上游文档为主。

## 目录树（目标形态）

```text
AxiMate/
├── README.md                 # 产品总览与入口链接
├── LICENSE / NOTICE          # 本仓授权与声明
├── components/               # 三上游：文档 + AxiMate 扩展（无上游子模块）
│   ├── README.md             # 三组件索引
│   ├── copaw/                # 【当前优先】CoPaw
│   │   ├── README.md
│   │   └── extensions/       # AxiMate 自有 skills / 模板 / 脚本
│   ├── hiclaw/               # HiClaw（说明 + 指向 deploy/）
│   │   └── README.md
│   └── higress/              # Higress（概念与后续网关笔记）
│       └── README.md
├── deploy/                   # 云上安装 HiClaw（含 Higress）— 路径固定
│   ├── .env.example
│   ├── README.md
│   ├── native/
│   │   └── install-hiclaw.sh
│   └── scripts/
│       ├── bootstrap-server.sh
│       ├── update-stack.sh
│       ├── deploy-remote.ps1
│       └── …
└── docs/
    ├── ARCHITECTURE.md       # 逻辑架构与上游关系
    ├── DIRECTORY.md          # 本文件
    ├── COMPLIANCE-APACHE2.md
    └── DEV-COPAW.md          # CoPaw 本地开发步骤
```

## 组件与目录对应

| 上游 | 运行时来源 | 本仓库中的位置 |
|------|------------|----------------|
| **CoPaw** | `pip` / `docker` / 上游 Git | `components/copaw/` + `docs/DEV-COPAW.md` |
| **HiClaw** | 官方 `hiclaw-install.sh`（由 `deploy/` 调用） | `deploy/` + `components/hiclaw/README.md` |
| **Higress** | HiClaw 安装过程拉起 | `components/higress/README.md`（说明）；实操见 HiClaw / Higress 官方文档 |

## 后续可扩展（按需）

- `components/hiclaw/patches/` — 仅当需要记录对上游的补丁说明时使用（一般不提交上游源码）。  
- `components/higress/policies/` — 导出的路由 / Wasm 策略片段（与官方格式对齐）。  
- `packages/` — 若未来增加 **AxiMate 自有微服务**（gRPC/REST），可与 `components/` 并存。

## 变更说明

原根目录 **`copaw-extensions/`** 已合并为 **`components/copaw/extensions/`**，避免与 `components/` 并列时语义重复。
