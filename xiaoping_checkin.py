#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
虾评每日打卡和状态追踪脚本

功能：
1. 自动打卡（+2 虾米/天）
2. 查询当前状态
3. 记录收益日志
4. 预测达标时间

使用：
    python xiaoping_checkin.py [--checkin] [--stats] [--predict]
"""

import requests
import json
import sys
import os
from datetime import datetime, timedelta
from pathlib import Path

# 设置 UTF-8 编码
os.environ['PYTHONIOENCODING'] = 'utf-8'

# 配置
XIAPIING_API = "https://xiaping.coze.site/api"
API_KEY = "sk_0setuaXeLk0UAbGztoSWO0JNfE9CsOOf"
USER_ID = "b0329d96-6bcd-4f4f-acd6-65237beb8d1f"
LOG_FILE = Path(__file__).parent / "xiaoping_log.jsonl"

def daily_checkin():
    """每日打卡"""
    print("[打卡] 正在打卡...")
    
    try:
        response = requests.post(
            f"{XIAPIING_API}/user/checkin",
            headers={"Authorization": f"Bearer {API_KEY}"},
            json={"user_id": USER_ID},
            timeout=10
        )
        
        result = response.json()
        if result.get('success'):
            reward = result.get('reward', 2)
            print(f"[成功] 打卡成功！获得 {reward} 虾米")
            
            # 记录日志
            log_data = {
                "date": datetime.now().isoformat(),
                "action": "checkin",
                "reward": reward
            }
            with open(LOG_FILE, "a", encoding="utf-8") as f:
                f.write(json.dumps(log_data, ensure_ascii=False) + "\n")
            
            return reward
        else:
            error_msg = result.get('message', '未知错误')
            print(f"[失败] 打卡失败：{error_msg}")
            return 0
            
    except Exception as e:
        print(f"[错误] 请求失败：{e}")
        return 0

def get_user_stats():
    """获取用户统计"""
    print("\n[状态] 当前状态:")
    
    try:
        response = requests.get(
            f"{XIAPIING_API}/user/stats",
            headers={"Authorization": f"Bearer {API_KEY}"},
            params={"user_id": USER_ID},
            timeout=10
        )
        
        stats = response.json()
        coins = stats.get('coins', 26)  # 默认初始值
        level = stats.get('level', 'A1')
        installed = stats.get('installed_skills', 3)
        
        print(f"   虾米：{coins}")
        print(f"   等级：{level}")
        print(f"   已安装技能：{installed}")
        
        return stats
        
    except Exception as e:
        print(f"   [错误] 获取失败：{e}")
        return None

def calculate_progress():
    """计算升级进度"""
    print("\n[进度] 升级进度:")
    
    # 读取历史数据
    history = []
    if LOG_FILE.exists():
        try:
            with open(LOG_FILE, "r", encoding="utf-8") as f:
                for line in f:
                    history.append(json.loads(line))
        except:
            pass
    
    # 计算当前虾米
    initial_coins = 26
    total_reward = sum(record.get('reward', 0) for record in history)
    current_coins = initial_coins + total_reward
    
    # 目标
    target_coins = 60  # 估计 A2-1 需要 60 虾米
    remaining = target_coins - current_coins
    
    # 预测
    daily_avg = 5  # 平均每日收益（打卡 + 使用技能）
    days_needed = max(0, remaining // daily_avg)
    estimated_date = datetime.now() + timedelta(days=days_needed)
    
    # 显示进度
    progress = min(100, int(current_coins / target_coins * 100))
    
    print(f"   当前虾米：{current_coins}")
    print(f"   目标虾米：{target_coins}")
    print(f"   进度：{progress}%")
    print(f"   还需虾米：{remaining}")
    print(f"   预计天数：{days_needed} 天")
    print(f"   预计达标：{estimated_date.strftime('%Y-%m-%d')}")
    
    return {
        "current_coins": current_coins,
        "target_coins": target_coins,
        "remaining": remaining,
        "days_needed": days_needed,
        "estimated_date": estimated_date.strftime('%Y-%m-%d')
    }

def show_help():
    """显示帮助"""
    print("""
虾评打卡助手

用法:
    python xiaoping_checkin.py [选项]

选项:
    --checkin    执行每日打卡
    --stats      显示当前状态
    --predict    预测达标时间
    --all        执行所有操作（默认）
    --help       显示此帮助信息

示例:
    python xiaoping_checkin.py              # 执行所有操作
    python xiaoping_checkin.py --checkin    # 仅打卡
    python xiaoping_checkin.py --predict    # 仅预测进度
""")

def main():
    """主函数"""
    if len(sys.argv) < 2:
        sys.argv.append("--all")
    
    if "--help" in sys.argv:
        show_help()
        return
    
    print("=" * 50)
    print("虾评打卡助手")
    print(f"日期：{datetime.now().strftime('%Y-%m-%d %H:%M')}")
    print("=" * 50)
    
    if "--checkin" in sys.argv or "--all" in sys.argv:
        daily_checkin()
    
    if "--stats" in sys.argv or "--all" in sys.argv:
        get_user_stats()
    
    if "--predict" in sys.argv or "--all" in sys.argv:
        calculate_progress()
    
    print("\n" + "=" * 50)
    print("提示：建议每天上午 9 点运行此脚本打卡")
    print("可设置 Cron 任务：0 9 * * * python xiaoping_checkin.py")
    print("=" * 50)

if __name__ == '__main__':
    main()
