# SnnapyGhost

English version: [README.md](./README.md)

一个面向最新 macOS 和 Apple Silicon 的轻量浮动截图工具。

SnnapyGhost 运行在菜单栏中。按下 `control + shift + 2` 后，你可以框选屏幕区域截图，截图会立即以悬浮窗口的形式显示在最上层，支持拖动、跨桌面显示、双击关闭。

## 功能特性

- 菜单栏后台应用，无主窗口
- 全局快捷键 `control + shift + 2`
- 框选任意屏幕区域截图
- 截图后自动生成悬浮图
- 悬浮图可拖动、始终置顶
- 悬浮图可在所有桌面和全屏空间显示
- 支持多张截图同时存在
- 双击任意悬浮图即可关闭

## 系统要求

- macOS 15.2 或更高版本
- Apple Silicon / M 系列芯片
- 已授予“屏幕与系统音频录制”权限
- 已安装 Swift 工具链

说明：
当前版本已经可以使用 Command Line Tools 构建；如果你后续要做更完整的调试、签名或分发，建议安装完整 Xcode。

## 安装方式

### 方式一：从源码构建

在项目根目录执行：

```bash
swift build
bash Scripts/build_app.sh
```

构建完成后，应用会生成在：

```text
dist/SnnapyGhost.app
```

你可以直接双击这个 `.app` 启动，或者把它移动到 `/Applications` 后再启动。

### 方式二：直接运行开发版本

如果你只是想快速试用：

```bash
swift run SnnapyGhost
```

## 首次启动

SnnapyGhost 是菜单栏应用，启动后不会显示 Dock 图标，也不会弹出主窗口。

启动成功后请确认：

- 菜单栏中出现相机图标
- 或者按下 `control + shift + 2` 能进入截图选择状态

## 权限授权

截图功能依赖 macOS 的“屏幕与系统音频录制”权限。

首次使用时，如果系统提示授权，请允许 SnnapyGhost。

如果没有看到授权弹窗，请手动前往：

```text
系统设置 > 隐私与安全性 > 屏幕与系统音频录制
```

找到 `SnnapyGhost` 并开启权限。

重要：
如果你刚刚勾选了权限，通常需要彻底退出并重新打开应用，新权限才会对当前进程生效。

## 使用方式

1. 启动 `SnnapyGhost.app`
2. 按下 `control + shift + 2`
3. 在屏幕上拖拽选择要截图的区域
4. 松开鼠标后，截图会自动以悬浮窗口形式出现
5. 拖动悬浮图到任意位置
6. 双击悬浮图关闭该截图

## 菜单栏入口

点击菜单栏图标后，你可以：

- 手动开始截图
- 查看权限状态
- 请求屏幕录制权限
- 打开系统设置
- 退出应用

## 常见问题

### 双击应用后看起来“没反应”

这是正常现象。SnnapyGhost 是菜单栏应用，没有 Dock 图标和主窗口。请查看菜单栏中的图标。

### 明明开了权限，应用还是提示没有权限

请先确认你运行的是最新重新构建出来的 `.app`。

然后按这个顺序处理：

1. 退出 SnnapyGhost
2. 在系统设置里关闭再重新打开 `SnnapyGhost` 的“屏幕与系统音频录制”权限
3. 重新启动应用

如果还不行，可以重置权限：

```bash
tccutil reset ScreenCapture local.construct.SnnapyGhost
```

然后重新打开应用并再次授权。

### 截图后应用闪退

请先确保你使用的是最新构建的版本。如果问题仍然存在，请检查最新的崩溃日志：

```text
~/Library/Logs/DiagnosticReports/
```

## 开发说明

项目使用：

- Swift Package Manager
- AppKit
- Carbon HotKey API
- ScreenCaptureKit

常用命令：

```bash
swift build
swift run SnnapyGhost
bash Scripts/build_app.sh
```
