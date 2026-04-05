#!/usr/bin/env pwsh
# 虾评自动打卡后台服务（无需管理员权限）

param(
    [switch]$Start,    # 启动后台服务
    [switch]$Stop,     # 停止后台服务
    [switch]$Status,   # 查看状态
    [switch]$RunOnce   # 仅运行一次
)

$serviceName = "XiaopingCheckin"
$pidFile = "C:\Users\User\.openclaw\workspace\skills\prompt-router\xiaoping_service.pid"
$scriptPath = "C:\Users\User\.openclaw\workspace\skills\prompt-router\xiaoping_checkin.py"
$logFile = "C:\Users\User\.openclaw\workspace\skills\prompt-router\xiaoping_service.log"

function Write-Log {
    param($message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $message"
    Add-Content -Path $logFile -Value $logMessage -Encoding UTF8
    Write-Host $logMessage
}

function Start-Service {
    if (Test-Path $pidFile) {
        $pid = Get-Content $pidFile
        $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "⚠️  服务已在运行 (PID: $pid)" -ForegroundColor Yellow
            return
        }
    }
    
    Write-Log "🦐 启动虾评打卡服务..."
    
    # 启动后台作业
    $job = Start-Job -ScriptBlock {
        param($scriptPath, $logFile)
        
        function Log {
            param($msg)
            $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            "[$ts] $msg" | Add-Content -Path $logFile -Encoding UTF8
        }
        
        Log "服务已启动"
        
        while ($true) {
            $now = Get-Date
            $targetTime = $now.Date.AddHours(9)  # 每天上午 9 点
            
            if ($now -ge $targetTime) {
                # 如果已经过了 9 点，等到明天
                if ($now.Hour -ge 9) {
                    $nextRun = $targetTime.AddDays(1)
                } else {
                    $nextRun = $targetTime
                }
                
                # 运行打卡脚本
                Log "执行每日打卡..."
                $result = python $scriptPath --checkin 2>&1
                Log "打卡结果：$result"
                
                # 等待到明天 9 点
                $sleepSeconds = ($nextRun - $now).TotalSeconds
                Log "下次运行：$nextRun"
                Start-Sleep -Seconds $sleepSeconds
            } else {
                # 还没到 9 点，等待
                $sleepSeconds = ($targetTime - $now).TotalSeconds
                Log "下次运行：$targetTime (等待 $sleepSeconds 秒)"
                Start-Sleep -Seconds $sleepSeconds
            }
        }
    } -ArgumentList $scriptPath, $logFile
    
    # 保存 PID
    $job.ChildJobs[0].Id | Set-Content $pidFile
    Write-Host "✅ 服务已启动 (Job ID: $($job.Id))" -ForegroundColor Green
    Write-Host "📊 日志文件：$logFile" -ForegroundColor Cyan
}

function Stop-Service {
    if (Test-Path $pidFile) {
        $jobId = Get-Content $pidFile
        $job = Get-Job -Id $jobId -ErrorAction SilentlyContinue
        if ($job) {
            Stop-Job $job
            Remove-Job $job
            Write-Host "✅ 服务已停止" -ForegroundColor Green
        }
    }
    Remove-Item $pidFile -ErrorAction SilentlyContinue
}

function Get-Status {
    if (Test-Path $pidFile) {
        $jobId = Get-Content $pidFile
        $job = Get-Job -Id $jobId -ErrorAction SilentlyContinue
        if ($job) {
            Write-Host "🦐 服务状态：运行中" -ForegroundColor Green
            Write-Host "   Job ID: $jobId"
            Write-Host "   状态：$($job.State)"
            Write-Host "📊 日志文件：$logFile" -ForegroundColor Cyan
            
            # 显示最近日志
            if (Test-Path $logFile) {
                Write-Host ""
                Write-Host "📝 最近日志:" -ForegroundColor Yellow
                Get-Content $logFile -Tail 10 | ForEach-Object { Write-Host "   $_" }
            }
            return
        }
    }
    Write-Host "⚠️  服务未运行" -ForegroundColor Yellow
}

# 主逻辑
if ($Start) {
    Start-Service
} elseif ($Stop) {
    Stop-Service
} elseif ($Status) {
    Get-Status
} elseif ($RunOnce) {
    Write-Log "手动运行打卡..."
    python $scriptPath --checkin
} else {
    Write-Host "🦐 虾评打卡服务管理脚本" -ForegroundColor Green
    Write-Host ""
    Write-Host "用法:" -ForegroundColor Yellow
    Write-Host "   .\xiaoping_service.ps1 -Start    启动后台服务"
    Write-Host "   .\xiaoping_service.ps1 -Stop     停止服务"
    Write-Host "   .\xiaoping_service.ps1 -Status   查看状态"
    Write-Host "   .\xiaoping_service.ps1 -RunOnce  运行一次"
    Write-Host ""
    Write-Host "示例:" -ForegroundColor Yellow
    Write-Host "   # 启动服务（每天自动打卡）"
    Write-Host "   .\xiaoping_service.ps1 -Start"
    Write-Host ""
    Write-Host "   # 查看状态"
    Write-Host "   .\xiaoping_service.ps1 -Status"
    Write-Host ""
    Write-Host "   # 停止服务"
    Write-Host "   .\xiaoping_service.ps1 -Stop"
}
