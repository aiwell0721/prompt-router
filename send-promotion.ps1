#!/usr/bin/env pwsh
# Prompt-Router 社区推广自动发送脚本

Write-Host "📢 Prompt-Router 社区推广" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host ""

# 准备消息内容
$discordMessage = @"
🎉 **新技能发布：Prompt-Router** 🚀

让技能调用快如闪电！⚡

**核心特性：**
⚡ 极速响应 - <10ms 路由决策（vs 500ms+ LLM）
💰 零成本 - 简单任务无需 LLM 调用，节省 50%+ Token
🛡️ 可降级 - LLM 故障时仍可工作
🎯 确定性 - 相同输入始终相同输出
🌐 中英文 - 完美支持混合输入

**性能数据：**
- 平均延迟：**7.38ms**
- 路由成功率：**71.4%**
- 测试通过率：**100%** (14/14)

**安装：**
`clawhub install prompt-router`

**链接：**
- GitHub: https://github.com/aiwell0721/prompt-router
- ClawHub: https://clawhub.ai/skills/prompt-router

欢迎试用、反馈和贡献！🙌

#OpenClaw #Skill #Performance #Routing
"@

Write-Host "✅ Discord 宣传文案已准备" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Discord 消息内容：" -ForegroundColor Yellow
Write-Host "-------------------"
Write-Host $discordMessage
Write-Host "-------------------"
Write-Host ""

# 复制到剪贴板
$discordMessage | Set-Clipboard
Write-Host "✅ 已复制到剪贴板，可直接粘贴到 Discord" -ForegroundColor Green
Write-Host ""

# 提供发送选项
Write-Host "📤 发送选项：" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Discord #skills-showcase" -ForegroundColor White
Write-Host "   1. 打开 https://discord.com/channels/@openclaw" -ForegroundColor Gray
Write-Host "   2. 进入 #skills-showcase 频道" -ForegroundColor Gray
Write-Host "   3. 粘贴并发送（已复制到剪贴板）" -ForegroundColor Gray
Write-Host ""
Write-Host "2. 飞书通知" -ForegroundColor White
Write-Host "   运行：lark-cli im +messages-send --chat-id <chat_id> --text '消息内容'" -ForegroundColor Gray
Write-Host ""
Write-Host "3. 手动发送其他平台" -ForegroundColor White
Write-Host "   - 虾评社区：https://xiaping.coze.site" -ForegroundColor Gray
Write-Host "   - Twitter/X: @OpenClaw" -ForegroundColor Gray
Write-Host "   - 微博：#OpenClaw#" -ForegroundColor Gray
Write-Host ""

Write-Host "📊 推广材料位置：" -ForegroundColor Yellow
Write-Host "   C:/Users/User/.openclaw/workspace/skills/prompt-router/PROMOTION_MATERIALS.md" -ForegroundColor Cyan
Write-Host ""

Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
