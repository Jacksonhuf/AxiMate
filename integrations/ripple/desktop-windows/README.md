# AxiMate Ripple — Windows 桌面 Console UI

本目录维护 **CoPaw Web Console** 上 **AxiMate Ripple** 品牌化与 **Windows 优先** 的 UI 调整；并承载 **「官方 Desktop → 一键安装包」** 的**分阶段执行清单**。

## 先读：执行路线图（To-Do）

**[`ROADMAP.md`](ROADMAP.md)** — 阶段 0～4 勾选清单（含路径 A/B 分支、fork、合规）。  
请从 **阶段 0** 开始，再决定是否在 **CoPaw fork** 里接安装包流水线。

---

## 行为说明（`VITE_RIPPLE_DESKTOP=1`）

- 页签标题、顶栏 Logo 旁文案、登录页标题、欢迎语占位符等多语言覆盖为 **AxiMate Ripple**。
- 主题主色改为 **青绿 `#0d9488`**（水流意象）；默认 CoPaw 构建仍为橙色。
- `ripple-desktop.css`：在 `html.ripple-desktop` 下启用 **Segoe UI Variable**、字体平滑与细滚动条（适配 WebView2 / 内嵌浏览器）。

## 一次性：克隆并打补丁

在仓库根目录的 PowerShell 中：

```powershell
.\integrations\ripple\desktop-windows\scripts\bootstrap-copaw.ps1
```

脚本会：

1. 若不存在则 `git clone` 到 `integrations/ripple/copaw/`  
2. 在 **干净** 的 `console` 目录上执行 `git apply patches/001-ripple-windows-ui.patch`

若补丁曾应用过或本地有修改，请先进入 `copaw` 执行 `git checkout -- console` 再运行（或删除 `copaw` 后重新克隆）。

## 阶段 0 辅助：扫描本机是否已有 CoPaw Desktop 目录

```powershell
.\integrations\ripple\desktop-windows\scripts\inspect-official-desktop.ps1
```

只读列举常见安装路径下的目录名，便于填写 `ROADMAP.md` 中的「基线记录」。

## 本地开发（Windows）

```powershell
.\integrations\ripple\desktop-windows\scripts\dev-ripple-windows.ps1
```

浏览器打开脚本输出的地址（一般为 Vite `5173`），应看到 **Ripple** 文案与青绿主色。

## 生产构建（Console 静态资源）

```powershell
.\integrations\ripple\desktop-windows\scripts\build-ripple-console.ps1
```

产物在 `integrations/ripple/copaw/console/dist/`，需按 [CoPaw 文档](https://github.com/agentscope-ai/CoPaw) 拷入 Python 包的 `src/copaw/console` 或接入 **Desktop 打包流水线**（见 `ROADMAP.md` 阶段 2）。

## 修改 UI 后更新 patch

在已修改 `integrations/ripple/copaw/console/` 后，在**任意目录**执行：

```powershell
.\integrations\ripple\desktop-windows\scripts\regenerate-patch.ps1
```

将更新 **`patches/001-ripple-windows-ui.patch`** 并提交到 Git。

## 与官方 Desktop / 安装包

设置构建环境变量 **`VITE_RIPPLE_DESKTOP=1`** 构建出的 Console 可与 **官方 Desktop（Beta）** 或 **fork 后的安装包流水线** 对接；完整步骤见 **`ROADMAP.md`**。
