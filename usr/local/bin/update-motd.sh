#!/bin/bash
#
# motd_updater.sh - 在后台更新 MOTD 动态数据
# 请通过 cron 每分钟执行此脚本
#

# 加载函数库
source "/etc/update-motd.d/00-lib.sh"

# 定义数据存储目录
DATA_DIR="/run/motd_data"
mkdir -p "$DATA_DIR"

# 1. 更新 CPU 使用率
cpu_usage=$(cpu_usage_calc)
echo "$cpu_usage" > "$DATA_DIR/cpu_usage"

# 2. 更新网络速度
for iface in $(ls /sys/class/net | grep -v '^lo$'); do
    # 并行执行以节省时间
    (
        read -r rx_bytes tx_bytes <<< "$(get_speed_calc "$iface")"
        rx_speed=$(format_speed "$rx_bytes")
        tx_speed=$(format_speed "$tx_bytes")
        echo "↓${rx_speed} ${YELLOW}/${NC} ↑${tx_speed}" > "$DATA_DIR/net_speed_${iface}"
    ) &
done
wait # 等待所有后台网络任务完成
