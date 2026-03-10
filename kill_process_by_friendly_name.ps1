# kill_process_by_friendly_name.ps1

function Kill-ProcessByFriendlyName {
    param(
        [Parameter(Mandatory=$true, HelpMessage="请输入要查找和终止的应用程序的友好名称 (例如：LearnVFX 或 deletefile)。")]
        [string]$AppName
    )

    Write-Host "正在查找包含 '$AppName' 的进程..." -ForegroundColor Yellow

    # 使用 tasklist /v 获取所有进程详细信息，并通过 findstr 过滤
    # 输出示例：rider64.exe 95436 Console 6 1,681,584 K Running CHINAMI-CCRSOJT\Administrator 0:05:28 LearnVFX
    $processesFound = (tasklist /v | findstr /I "$AppName")

    if (-not $processesFound) {
        Write-Host "未找到包含 '$AppName' 的进程。" -ForegroundColor Green
        return
    }

    Write-Host "找到以下匹配 '$AppName' 的进程：" -ForegroundColor Green

    $pidsToKill = @() # 存储要终止的PID列表

    foreach ($line in $processesFound) {
        # 从每一行解析出进程名和PID
        # 使用正则表达式匹配，更健壮
        # 匹配模式：映像名(非空格字符) 空格 PID(数字)
        if ($line -match '^(\S+?)\s+(\d+)\s+.*') {
            $imageName = $matches[1]
            $currentPid = $matches[2] # <<<<<< 这里改名了！从 $pid 改为 $currentPid
            
            Write-Host "  - 映像名称: $imageName, PID: $currentPid, 详细信息: $line" -ForegroundColor Cyan
            $pidsToKill += $currentPid # <<<<<< 这里也改名了！
        } else {
            Write-Host "  - 警告：无法解析行 '$line'" -ForegroundColor Red
        }
    }

    if ($pidsToKill.Count -eq 0) {
        Write-Host "未能从匹配的行中解析出任何 PID。" -ForegroundColor Red
        return
    }

    Write-Host "`n是否要终止以上所有进程 (PID: $($pidsToKill -join ', '))？" -ForegroundColor Yellow
    $confirm = Read-Host "输入 'yes' 继续，其他输入则取消"

    if ($confirm -eq "yes") {
        foreach ($pidToStop in $pidsToKill) { # <<<<<< 这里循环变量也改名了！从 $pid 改为 $pidToStop
            try {
                Write-Host "正在终止 PID: $pidToStop..." -ForegroundColor Yellow
                Stop-Process -Id $pidToStop -Force -ErrorAction Stop
                Write-Host "成功终止 PID: $pidToStop。" -ForegroundColor Green
            }
            catch {
                Write-Host "终止 PID: $pidToStop 失败。错误: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        Write-Host "`n所有指定进程终止操作完成。" -ForegroundColor Green
    } else {
        Write-Host "操作已取消。" -ForegroundColor Red
    }
}

# --- 如何使用 ---
# 调用函数，传入你要查找的友好名称
# 例如：
# Kill-ProcessByFriendlyName -AppName "LearnVFX"
# Kill-ProcessByFriendlyName -AppName "deletefile"

# 示例：让用户输入
$userInput = Read-Host "请输入要查找和终止的应用程序的友好名称"
Kill-ProcessByFriendlyName -AppName $userInput