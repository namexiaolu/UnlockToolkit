# 修改为你的脚本实际路径
$ScriptPath = "D:\tools\UnlockTool.ps1"

# 定义注册表路径 (分别针对文件、文件夹、文件夹背景)
$RegPaths = @(
    @{Path = "Registry::HKEY_CLASSES_ROOT\*\shell\CheckLock"; Name = "文件"; Param = "%1"},
    @{Path = "Registry::HKEY_CLASSES_ROOT\Directory\shell\CheckLock"; Name = "文件夹"; Param = "%1"},
    @{Path = "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\CheckLock"; Name = "文件夹背景"; Param = "%V"}
)

foreach ($item in $RegPaths) {
    $regPath = $item.Path
    $typeName = $item.Name
    $param = $item.Param

    Write-Host "正在注册 $typeName 右键菜单..." -ForegroundColor Yellow

    try {
        # 如果已存在，先删除（比 -Force 更快）
        if (Test-Path $regPath) {
            Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue
        }

        # 创建菜单项
        $null = New-Item -Path $regPath -Value "检查并解除占用" -Force -ErrorAction Stop

        # 设置图标
        $null = Set-ItemProperty -Path $regPath -Name "Icon" -Value "taskmgr.exe,0" -ErrorAction Stop

        # 创建执行命令
        $command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""$ScriptPath"" ""$param"""
        $null = New-Item -Path "$regPath\command" -Value $command -Force -ErrorAction Stop

        Write-Host "  ✓ $typeName 注册成功" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ $typeName 注册失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n右键菜单注册完成！" -ForegroundColor Green

Write-Host "`n右键菜单注册完成！" -ForegroundColor Green