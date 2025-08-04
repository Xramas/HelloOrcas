#!/bin/bash
#
# 00-lib.sh - MOTD 公共函数与变量库
#

# --- 颜色定义 ---
RED='\033[0;31m'; ORANGE='\033[0;33m'; YELLOW='\033[1;33m';
GREEN='\033[0;32m'; CYAN='\033[1;36m'; GRAY='\033[0;37m'; NC='\033[0m'
RED_BG_WHITE_TEXT='\033[41;97m'

# --- 公共函数 ---

# 检查命令是否存在
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${YELLOW}Warning: Command '$1' not found. Some features may be disabled.${NC}" >&2
        return 1
    fi
    return 0
}

# 根据数值进行彩色输出
# 用法: colorize VALUE
colorize() {
    local value=$1
    if (( value >= 80 )); then
        echo -e "${RED}${value}%${NC}"
    elif (( value >= 50 )); then
        echo -e "${YELLOW}${value}%${NC}"
    else
        echo -e "${GREEN}${value}%${NC}"
    fi
}

# 彩色化网络接口状态
# 用法: color_state STATE
color_state() {
    case "$1" in
        up) echo -e "${GREEN}UP${NC}";;
        down) echo -e "${RED}DOWN${NC}";;
        *) echo "$1";;
    esac
}

# 格式化大小（字节 -> KB/MB）
# 用法: format_speed BYTES
format_speed() {
    local bytes=${1:-0}
    local kb=$((bytes / 1024))
    if ((kb < 1024)); then
        printf "%d KB/s" "$kb"
    else
        local mb=$(awk "BEGIN {printf \"%.2f\", $kb/1024}")
        printf "%s MB/s" "$mb"
    fi
}

# --- 后台任务使用的函数 ---

# 计算 CPU 使用率 (在 updater.sh 中调用)
# 用法: cpu_usage_calc
cpu_usage_calc() {
    local interval=1 # 使用1秒间隔以获得更平滑的读数
    local cpu=($(head -n1 /proc/stat))
    local idle=${cpu[4]}
    local total=0; for value in "${cpu[@]:1}"; do total=$((total + value)); done
    sleep $interval
    local cpu2=($(head -n1 /proc/stat))
    local idle2=${cpu2[4]}
    local total2=0; for value in "${cpu2[@]:1}"; do total2=$((total2 + value)); done
    local idle_diff=$((idle2 - idle))
    local total_diff=$((total2 - total))
    echo $(( (100 * (total_diff - idle_diff) / (total_diff > 0 ? total_diff : 1)) ))
}

# 获取网络速度 (在 updater.sh 中调用)
# 用法: get_speed_calc IFACE
get_speed_calc() {
    local iface=$1
    [[ -z "$iface" || ! -d /sys/class/net/$iface/statistics ]] && return
    local rx1=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || echo 0)
    local tx1=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || echo 0)
    sleep 1
    local rx2=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || echo 0)
    local tx2=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || echo 0)
    echo "$((rx2 - rx1))" "$((tx2 - tx1))" # 返回原始字节差值
}
