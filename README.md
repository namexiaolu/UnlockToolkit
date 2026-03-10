# UnlockToolkit - 文件/文件夹占用解除工具

Windows 右键菜单工具，用于快速检测并解除文件或文件夹的进程占用。

## 项目背景

在使用 LockHunter 和 IObit Unlocker 等第三方工具时，经常遇到无法完整检测文件占用的情况。然而，通过简单的 PowerShell 原生命令（如 `Get-Process` 和 `tasklist`）却能准确找到占用进程。

本项目基于这一发现，利用 Windows 原生 PowerShell 能力，提供了一个轻量、高效、无需安装额外软件的文件占用解除方案。

## 功能特性

- 右键菜单集成（文件、文件夹、文件夹背景）
- 自动检测占用进程
- GUI 对话框确认后终止进程
- 支持通过友好名称查找进程

## 安装方法

### 前置准备

**重要：** 默认脚本路径为 `D:\tools\UnlockTool.ps1`，如果你的文件存放在其他位置，需要先修改路径配置：

1. **修改 .reg 文件**：用文本编辑器打开 `register_unlock_menu.reg`，将所有 `D:\\tools\\UnlockTool.ps1` 替换为你的实际路径（注意使用双反斜杠 `\\`）

2. **修改 PowerShell 脚本**：打开 `registerUnlockTool.ps1`，修改第2行的 `$ScriptPath` 变量为你的实际路径

### 方法1：使用 .reg 文件（推荐）

1. 双击 `register_unlock_menu.reg`
2. 点击"是"确认导入注册表

**注册表写入内容：** 在 `HKEY_CLASSES_ROOT` 下创建右键菜单项，包含菜单显示文本、图标和执行命令（调用 PowerShell 运行 UnlockTool.ps1）

### 方法2：使用 PowerShell 脚本

以管理员身份运行 PowerShell：

```powershell
.\registerUnlockTool.ps1
```

## 使用方法

安装后，在文件或文件夹上右键，选择"检查并解除占用"即可。

### 日志文件

脚本运行时会生成调试日志，默认位置：
- 调试日志：`D:\tools\unlock_debug.log`
- 错误日志：`D:\tools\unlock_error.log`

**自定义日志路径：** 打开 `UnlockTool.ps1`，修改第12行和第34行的 `$logFile` 变量为你想要的路径。

## 文件说明

- `UnlockTool.ps1` - 主程序脚本
- `registerUnlockTool.ps1` - 注册表注册脚本
- `register_unlock_menu.reg` - 注册表文件（快速安装）
- `kill_process_by_friendly_name.ps1` - 独立的进程终止工具

## 卸载方法

删除以下注册表项：

- `HKEY_CLASSES_ROOT\*\shell\CheckLock`
- `HKEY_CLASSES_ROOT\Directory\shell\CheckLock`
- `HKEY_CLASSES_ROOT\Directory\Background\shell\CheckLock`

## 注意事项

- 需要管理员权限才能终止某些系统进程
- 终止进程前会弹出确认对话框
- 默认路径为 `D:\tools\`，如需更改请参考"安装方法"中的路径配置说明
