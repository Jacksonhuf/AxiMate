# AxiMate Ripple — Windows 桌面 Console UI

本目录维护 **CoPaw Web Console** 上 **AxiMate Ripple** 品牌化与 **Windows 优先** 的 UI 调整。上游仍为 [CoPaw](https://github.com/agentscope-ai/CoPaw)；改动以 **patch** 形式纳入本仓库，**不**提交完整 `copaw/` 克隆（见根目录 `.gitignore`）。

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

## 本地开发（Windows）

```powershell
.\integrations\ripple\desktop-windows\scripts\dev-ripple-windows.ps1
```

浏览器打开脚本输出的地址（一般为 Vite `5173`），应看到 **Ripple** 文案与青绿主色。

## 生产构建

```powershell
.\integrations\ripple\desktop-windows\scripts\build-ripple-console.ps1
```

产物在 `integrations/ripple/copaw/console/dist/`，需按 [CoPaw 文档](https://github.com/agentscope-ai/CoPaw) 拷入 Python 包的 `src/copaw/console` 再发版。

## 修改 UI 后更新 patch

在已克隆的 `integrations/ripple/copaw` 内改完 `console/` 后，在仓库根执行：

```powershell
python -c "import subprocess, pathlib; r=subprocess.run(['git','diff','--','console'], cwd=r'integrations/ripple/copaw', capture_output=True, encoding='utf-8'); pathlib.Path('integrations/ripple/desktop-windows/patches/001-ripple-windows-ui.patch').write_text(r.stdout, encoding='utf-8')"
```

（在 AxiMate 根目录下请将 `cwd` 改为绝对路径。）

将更新后的 **`patches/001-ripple-windows-ui.patch`** 提交到 Git。

## 与官方 Electron / 安装包

CoPaw 若通过 **pywebview** 或独立 **Desktop** 安装包托管同一 Console，设置构建环境变量 **`VITE_RIPPLE_DESKTOP=1`** 即可沿用本套差异。具体打包链路以上游 Release 为准。
