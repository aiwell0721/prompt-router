#!/usr/bin/env pwsh
# Prompt-Router ClawHub 发布脚本

Write-Host "🦀 ClawHub 发布脚本" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green
Write-Host ""

# Step 1: 检查登录状态
Write-Host "Step 1: 检查 ClawHub 登录状态..." -ForegroundColor Yellow
$testResult = clawhub search prompt-router 2>&1

if ($testResult -match "Not logged in") {
    Write-Host "⚠️  未登录，开始认证..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "👉 浏览器将打开，请点击 'Authorize' 授权" -ForegroundColor Cyan
    Write-Host ""
    clawhub login
    
    # 等待登录完成
    Start-Sleep -Seconds 5
}

# Step 2: 发布技能
Write-Host ""
Write-Host "Step 2: 发布 Prompt-Router 技能..." -ForegroundColor Yellow
Write-Host ""

$changelog = "Initial release - Fast routing engine with <10ms latency, zero LLM cost for simple tasks. 基于文本匹配的快速路由引擎。"

clawhub publish `
  "C:/Users/User/.openclaw/workspace/skills/prompt-router" `
  --slug prompt-router `
  --name "Prompt-Router" `
  --version 1.0.0 `
  --changelog $changelog

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ 发布成功！" -ForegroundColor Green
    Write-Host ""
    Write-Host "📦 技能页面：https://clawhub.ai/skills/prompt-router" -ForegroundColor Cyan
    Write-Host ""
    
    # Step 3: 验证
    Write-Host "Step 3: 验证发布..." -ForegroundColor Yellow
    clawhub search prompt-router
} else {
    Write-Host ""
    Write-Host "❌ 发布失败，请检查错误信息" -ForegroundColor Red
    Write-Host ""
    Write-Host "常见问题：" -ForegroundColor Yellow
    Write-Host "  1. 未登录：运行 'clawhub login'" -ForegroundColor White
    Write-Host "  2. Slug 已存在：尝试不同 slug 或升级版本" -ForegroundColor White
    Write-Host "  3. 网络问题：检查网络连接" -ForegroundColor White
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
