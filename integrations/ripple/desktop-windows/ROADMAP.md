# AxiMate Ripple 桌面版 — 执行路线图（To-Do）

按顺序推进；**阶段 0** 的结论决定后续走 **路径 A**（可替换静态资源）还是 **路径 B**（必须 fork 打包流水线）。

---

## 阶段 0：验证官方 Desktop（Beta）能否接 Ripple Console（必做）

> 目标：弄清安装包里的 Console 是 **可替换文件** 还是 **打进 exe / 签名校验**，避免无效投入。

- [ ] **0.1** 从 [CoPaw GitHub Releases](https://github.com/agentscope-ai/CoPaw/releases) 下载并安装 **Windows Desktop（Beta）**，记录 **版本号 / tag**（写入下方「基线记录」）。
- [ ] **0.2** 在安装目录与 `%LOCALAPPDATA%` / `%APPDATA%` 下查找与 **console、web、dist、static、resources** 相关的子目录，列出路径。
- [ ] **0.3** 判断是否存在 **可写的静态资源目录**（含 `index.html`、`.js` chunk 等）；若有，尝试 **备份后替换** 一小段可识别文案或资源，重启应用验证是否生效。
- [ ] **0.4** 记录结论：  
  - **路径 A**：替换生效（或仅受更新覆盖限制）→ 可评估「官方 exe + 自构建 Console」过渡方案。  
  - **路径 B**：无法替换或校验失败 → **必须 fork CoPaw 并改 Desktop 打包流水线**（正式产品路径）。

**基线记录（请填写）：**

| 项 | 值 |
|----|-----|
| CoPaw Desktop 版本 | |
| 安装路径 | |
| 阶段 0 结论（A / B） | |

辅助：在仓库根运行 `.\integrations\ripple\desktop-windows\scripts\inspect-official-desktop.ps1` 做常见路径扫描（不修改系统）。

---

## 阶段 1：Console 产物标准化（本仓库 + 本地 `copaw/`）

- [ ] **1.1** 已能运行 `bootstrap-copaw.ps1` 并成功 `git apply` **`patches/001-ripple-windows-ui.patch`**。
- [ ] **1.2** 已能运行 `dev-ripple-windows.ps1`，浏览器中确认 **Ripple** 文案与 **青绿主色**。
- [ ] **1.3** 已能运行 `build-ripple-console.ps1`，确认生成 **`integrations/ripple/copaw/console/dist/`**。
- [ ] **1.4** 将 **CoPaw 上游 tag/commit** 与 **patch 版本** 记在下方「构建基线」（或发版说明模板）。

**构建基线：**

| 项 | 值 |
|----|-----|
| CoPaw `console` 对应 commit / tag | |
| Patch 文件 | `patches/001-ripple-windows-ui.patch` |

---

## 阶段 2：一键安装包（依阶段 0 分支）

### 若结论为 **路径 B**（推荐按此准备正式 SKU）

- [ ] **2B.1** 在 GitHub **fork** [`agentscope-ai/CoPaw`](https://github.com/agentscope-ai/CoPaw)（组织仓库可命名如 `AxiMate-Ripple-copaw`）。
- [ ] **2B.2** 在上游仓库定位 **Windows Desktop / 安装包** 的构建入口（脚本、workflow、打包目录）。
- [ ] **2B.3** 在 **打 exe 之前** 增加一步：在 `console` 目录执行 **`VITE_RIPPLE_DESKTOP=1` 的 `npm ci` + `npm run build`**，使产物进入原有打包步骤。
- [ ] **2B.4**（可选）将本仓库中的 **`001-ripple-windows-ui.patch`** 合入 fork（或等价 commit），避免双源漂移。
- [ ] **2B.5** 安装包元数据：**显示名称、快捷方式、关于页** 使用 **AxiMate Ripple**，并保留 **Powered by CoPaw** 与许可证信息。
- [ ] **2B.6** 在 fork 上启用 **Release / CI**，产出可下载的 **Windows 安装包**。

### 若结论为 **路径 A**（过渡方案）

- [ ] **2A.1** 文档化「安装官方 Beta → 覆盖 Console 目录」的步骤与 **版本锁定**。
- [ ] **2A.2** 评估自动更新是否会 **覆盖** 自定义 Console；若会，规划迁移到 **2B**。

---

## 阶段 3：仓库分工（避免 AxiMate 与 fork 打架）

- [ ] **3.1** **AxiMate 本仓**：保留产品规则、Ripple 文档、patch 镜像、发布说明；可选 **git submodule** 指向 fork 的 **固定 tag**。
- [ ] **3.2** **CoPaw fork**：作为 **可构建、可发 Release** 的真源；桌面安装包从 fork 的 CI 产出。

---

## 阶段 4：发布与合规

- [ ] **4.1** 每条 Ripple 桌面 Release 附带或引用 **SBOM**，标明 **CoPaw 版本** 与 **AxiMate 变更**。
- [ ] **4.2** 对外表述：**AxiMate Ripple（Powered by CoPaw）**；遵守 **`docs/PRODUCT-PACKAGING.md`** 与 **`docs/COMPLIANCE-APACHE2.md`**。
- [ ] **4.3** 更新根目录 **`NOTICE`**（若产品线描述有变）。

---

## 本仓库已提供的自动化

| 脚本 | 作用 |
|------|------|
| `scripts/bootstrap-copaw.ps1` | 克隆 CoPaw 并打 patch |
| `scripts/dev-ripple-windows.ps1` | Ripple Console 本地开发 |
| `scripts/build-ripple-console.ps1` | Ripple Console 生产构建 |
| `scripts/inspect-official-desktop.ps1` | 阶段 0 辅助扫描常见安装路径 |
| `scripts/regenerate-patch.ps1` | 从已修改的 `copaw/console` 重写 patch 文件 |
