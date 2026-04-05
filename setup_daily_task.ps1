#!/usr/bin/env pwsh
# 设置虾评每日打卡定时任务

Write-Host "🦐 设置虾评每日打卡定时任务" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# 任务配置
$taskName = "Xiaoping Daily Checkin"
$scriptPath = "C:\Users\User\.openclaw\workspace\skills\prompt-router\xiaoping_checkin.py"
$logPath = "C:\Users\User\.openclaw\workspace\skills\prompt-router\xiaoping_checkin.log"
$pythonExe = "python"

# 检查脚本是否存在
if (-not (Test-Path $scriptPath)) {
    Write-Host "❌ 脚本文件不存在：$scriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "📋 任务配置:" -ForegroundColor Yellow
Write-Host "   任务名称：$taskName"
Write-Host "   脚本路径：$scriptPath"
Write-Host "   执行时间：每天上午 9:00"
Write-Host "   日志路径：$logPath"
Write-Host ""

# 创建任务操作
$action = New-ScheduledTaskAction -Execute $pythonExe `
    -Argument $scriptPath `
    -WorkingDirectory "C:\Users\User\.openclaw\workspace\skills\prompt-router"

# 创建任务触发器（每天上午 9 点）
$trigger = New-ScheduledTaskTrigger -Daily -At 9am

# 创建任务设置
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

# 创建任务主体（当前用户）
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType S4U -RunLevel Highest

# 注册任务
try {
    # 先删除已存在的任务
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false 2>$null
    
    # 注册新任务
    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -Description "每日自动执行虾评打卡，获得虾米积分"
    
    Write-Host "✅ 定时任务创建成功！" -ForegroundColor Green
    Write-Host ""
    Write-Host "任务详情:" -ForegroundColor Yellow
    Write-Host "   名称：$taskName"
    Write-Host "   频率：每天上午 9:00"
    Write-Host "   状态：已启用"
    Write-Host ""
    Write-Host "管理命令:" -ForegroundColor Yellow
    Write-Host "   查看任务：Get-ScheduledTask -TaskName '$taskName'"
    Write-Host "   查看日志：Get-ScheduledTaskInfo -TaskName '$taskName'"
    Write-Host "   手动运行：Start-ScheduledTask -TaskName '$taskName'"
    Write-Host "   禁用任务：Disable-ScheduledTask -TaskName '$taskName'"
    Write-Host "   启用任务：Enable-ScheduledTask -TaskName '$taskName'"
    Write-Host "   删除任务：Unregister-ScheduledTask -TaskName '$taskName' -Confirm:`$false"
    Write-Host ""
    
    # 立即运行一次测试
    Write-Host "🧪 运行首次测试..." -ForegroundColor Yellow
    Start-ScheduledTask -TaskName $taskName
    Start-Sleep -Seconds 3
    
    $taskInfo = Get-ScheduledTaskInfo -TaskName $taskName
    if ($taskInfo.LastRunResult -eq 0) {
        Write-Host "✅ 首次运行成功！" -ForegroundColor Green
    } else {
        Write-Host "⚠️  首次运行结果代码：$($taskInfo.LastRunResult)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ 创建失败：$($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "请确保以管理员权限运行此脚本" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "📊 日志文件位置:" -ForegroundColor Yellow
Write-Host "   $logPath"
Write-Host ""
Write-Host "💡 提示:" -ForegroundColor Cyan
Write-Host "   1. 日志会记录每次打卡结果"
Write-Host "   2. 可通过日志查看虾米收益"
Write-Host "   3. 预计 6 天后（2026-04-12）达到 A2-1 等级"
Write-Host ""

Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
