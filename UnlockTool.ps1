# UnlockTool.ps1
param([string]$Path)

# 错误处理
$ErrorActionPreference = "Stop"
try {
    # 加载程序集
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # 调试日志
    $logFile = "D:\tools\unlock_debug.log"
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - 接收参数: $Path" | Out-File -FilePath $logFile -Append

    # 验证路径
    if (-not $Path) {
        [System.Windows.Forms.MessageBox]::Show("未接收到路径参数", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        exit
    }

    if (-not (Test-Path $Path)) {
        [System.Windows.Forms.MessageBox]::Show("路径不存在: $Path", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        exit
    }

    # 提取文件或文件夹名称
    $SearchName = Split-Path $Path -Leaf
    if (-not $SearchName) {
        [System.Windows.Forms.MessageBox]::Show("无法提取文件/文件夹名称", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        exit
    }
} catch {
    $errorMsg = $_.Exception.Message
    $logFile = "D:\tools\unlock_error.log"
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - 错误: $errorMsg" | Out-File -FilePath $logFile -Append

    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
    [System.Windows.Forms.MessageBox]::Show("脚本执行出错: $errorMsg", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# 搜索进程
$FoundProcesses = @()

$allProcs = Get-Process | Where-Object {
    try {
        $_.CommandLine -like "*$SearchName*" -or $_.MainWindowTitle -like "*$SearchName*"
    } catch { $false }
}

foreach ($p in $allProcs) {
    $FoundProcesses += [PSCustomObject]@{
        Name = $p.ProcessName
        Id   = $p.Id
        Title = $p.MainWindowTitle
    }
}

# 备用方案：使用 tasklist
if ($FoundProcesses.Count -eq 0) {
    $tasklist = tasklist /v /fo csv | ConvertFrom-Csv | Where-Object { $_."窗口标题" -like "*$SearchName*" -or $_."映像名称" -like "*$SearchName*" }
    foreach ($item in $tasklist) {
        $FoundProcesses += [PSCustomObject]@{
            Name = $item."映像名称"
            Id   = $item."PID"
            Title = $item."窗口标题"
        }
    }
}

# 显示 GUI 对话框
if ($FoundProcesses.Count -gt 0) {
    $procInfo = $FoundProcesses | ForEach-Object { "· [$($_.Name)] (PID: $($_.Id))`n  标题: $($_.Title)" } | Out-String

    $msgText = "检测到以下程序可能正在占用 '$SearchName'：`n`n$procInfo`n是否强制结束这些进程以解除占用？"

    $result = [System.Windows.Forms.MessageBox]::Show($msgText, "占用检测 - $SearchName", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)

    if ($result -eq "Yes") {
        foreach ($proc in $FoundProcesses) {
            try {
                Stop-Process -Id $proc.Id -Force -ErrorAction Stop
            } catch {
                [System.Windows.Forms.MessageBox]::Show("无法结束 PID: $($proc.Id)`n$($_.Exception.Message)", "错误")
            }
        }
    }
} else {
    [System.Windows.Forms.MessageBox]::Show("未发现明显的程序占用 '$SearchName'。", "检测结果")
}
