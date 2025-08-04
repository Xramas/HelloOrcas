#!/bin/bash

# Cloudflare IP 文件
CF_IPV4_URL="https://www.cloudflare.com/ips-v4"
CF_IPV6_URL="https://www.cloudflare.com/ips-v6"

TMP_IPV4="/tmp/cf-ips-v4.txt"
TMP_IPV6="/tmp/cf-ips-v6.txt"

# 下载 Cloudflare IP 列表
curl -s $CF_IPV4_URL -o $TMP_IPV4
curl -s $CF_IPV6_URL -o $TMP_IPV6

# 删除旧规则（带有 Cloudflare 标记的）
ufw status numbered | grep 'Cloudflare' | awk -F'[][]' '{print $2}' | tac | while read num; do
    ufw --force delete $num
done

# 添加新的 IPv4 规则
while read ip; do
    ufw allow from $ip to any port 80 proto tcp comment 'Cloudflare'
    ufw allow from $ip to any port 443 proto tcp comment 'Cloudflare'
done < "$TMP_IPV4"

# 添加新的 IPv6 规则
while read ip; do
    ufw allow from $ip to any port 80 proto tcp comment 'Cloudflare'
    ufw allow from $ip to any port 443 proto tcp comment 'Cloudflare'
done < "$TMP_IPV6"

# 添加拒绝非 Cloudflare 的 HTTP/HTTPS 规则
ufw deny in proto tcp to any port 80 comment 'Deny non-Cloudflare HTTP'
ufw deny in proto tcp to any port 443 comment 'Deny non-Cloudflare HTTPS'
