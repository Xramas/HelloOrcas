# HelloOrcas 动态 MOTD

**HelloOrcas** 是一个功能强大的 shell 脚本集合，用于在您登录 Linux 服务器时创建一个信息丰富、美观且动态的“每日消息”（MOTD）。它能提供关键系统信息的实时概览，帮助您快速掌握服务器的健康状况和活动。

## ✨ 功能特性

登录后，您将一目了然地看到：

  * **系统信息**: 主机名、操作系统版本和内核信息。
  * **性能监控**:
      * 实时 CPU 型号、核心数及使用率。
      * 内存（RAM）和交换（Swap）空间的使用情况。
      * 系统正常运行时间（Uptime）和平均负载。
  * **磁盘使用**: 以表格形式清晰展示所有已挂载文件系统的使用情况。
  * **网络状态**:
      * 各个网络接口的 IPv4 和 IPv6 地址。
      * 实时计算的网络上下行速度。
  * **登录安全**:
      * 显示上一次登录的 IP 地址及其详细的地理位置、时区和 ASN 组织信息。
      * **高亮警报**: 当检测到来自非白名单 IP 的登录时，会显示醒目的红色警报。
  * **系统健康**:
      * 自动检查失败的 `systemd` 服务。
      * 提示可用的软件包更新（适用于 Debian/Ubuntu 系统）。
      * 显示正在运行的 Docker 容器数量（如果已安装 Docker）。

## 🚀 工作原理

HelloOrcas 的核心由三部分组成：

1.  **MOTD 生成脚本** (`/etc/update-motd.d/`)：这是一系列遵循 `update-motd` 框架的编号脚本。当用户登录时，系统会按顺序执行这些脚本，并将它们的输出组合成最终的 MOTD。
2.  **后台数据更新器** (`/usr/local/bin/update-motd.sh`)：为了避免在登录时执行耗时操作（如计算网络速度和 CPU 使用率），此脚本被设计为通过 `cron` 任务每分钟在后台运行。它会预先计算好这些动态数据，并将其存储在 `/run/motd_data/` 目录中，以便 MOTD 脚本可以快速读取。
3.  **定时任务** (`crontab.sh`)：
      * 每分钟执行 `update-motd.sh` 以刷新动态数据。
      * 每天执行 `update-geoip.sh` 来下载和更新 GeoIP 数据库，确保 IP 地理位置信息的准确性。

## 🛠️ 安装与配置

#### 步骤 1: 安装依赖

您需要确保系统上安装了必要的命令行工具。

```bash
# 对于 Debian/Ubuntu 系统
sudo apt-get update
sudo apt-get install -y curl mmdb-bin bc

# 对于 CentOS/RHEL 系统
sudo yum install -y curl libmaxminddb-utils bc
```

#### 步骤 2: 部署脚本

1.  将 `etc/update-motd.d/` 目录下的所有脚本复制到您服务器的 `/etc/update-motd.d/` 目录下，并赋予它们可执行权限。

    ```bash
    sudo cp ./etc/update-motd.d/* /etc/update-motd.d/
    sudo chmod +x /etc/update-motd.d/*
    ```

2.  将 `usr/local/bin/` 目录下的所有脚本复制到 `/usr/local/bin/`，并赋予可执行权限。

    ```bash
    sudo cp ./usr/local/bin/* /usr/local/bin/
    sudo chmod +x /usr/local/bin/*
    ```

#### 步骤 3: 初始化 GeoIP 数据库

首次使用时，需要手动运行脚本来下载 GeoIP 数据库。

```bash
sudo /usr/local/bin/update-geoip.sh
```

#### 步骤 4: 配置定时任务 (Cron)

为了让系统动态信息保持更新，请将 `crontab.sh` 的内容添加到您的 `crontab` 中。

```bash
# 将以下两行添加到 crontab
# crontab -e
* * * * * /usr/local/bin/update-motd.sh >/dev/null 2>&1
0 0 * * * /usr/local/bin/update-geoip.sh >/dev/null 2>&1
```

#### 步骤 5: (可选) 配置 IP 白名单

为了使用登录警报功能，您可以编辑 IP 白名单文件，将您信任的 IP 地址（例如办公室或家庭网络 IP）添加进去，每行一个。

```bash
sudo nano /etc/update-motd.d/ip_whitelist.conf
```

**注意**: `90-alerts` 脚本中的白名单路径被硬编码为 `/etc/motd.d/ip_whitelist.conf`。为了使其正常工作，您需要将项目中的 `etc/update-motd.d/ip_whitelist.conf` 文件复制到该位置，或者创建一个符号链接。

```bash
# 选项 A: 复制文件
sudo cp ./etc/update-motd.d/ip_whitelist.conf /etc/motd.d/ip_whitelist.conf

# 选项 B: 创建符号链接 (如果 /etc/motd.d/ 目录不存在则先创建)
sudo mkdir -p /etc/motd.d
sudo ln -s /etc/update-motd.d/ip_whitelist.conf /etc/motd.d/ip_whitelist.conf
```

#### 步骤 6: (可选) 配置 UFW 防火墙

如果您使用 Cloudflare 作为服务的前端，`update-ufw-cloudflare.sh` 脚本可以帮助您自动配置 UFW 防火墙，使其仅允许来自 Cloudflare IP 的 HTTP/HTTPS 流量。您可以根据需要定期运行此脚本。

## 📜 包含的脚本

  * **核心库**: `00-lib.sh` (提供颜色、状态格式化等公共函数)
  * **MOTD 模块**:
      * `05-warning`: 显示欢迎横幅和警告。
      * `10-sysinfo`: 系统信息。
      * `20-uptime`: 运行时间与负载。
      * `30-cpu`: CPU 信息。
      * `40-memory`: 内存信息。
      * `50-disk`: 磁盘使用情况。
      * `60-network`: 网络接口信息。
      * `80-lastlogin`: 上次登录详情。
      * `90-alerts`: 未信任 IP 登录警报。
      * `95-health`: 系统健康检查。
  * **辅助工具**:
      * `ipinfo`: 独立的 IP 查询工具。
      * `update-geoip.sh`: GeoIP 数据库更新器。
      * `update-motd.sh`: 动态数据后台更新器。
      * `update-ufw-cloudflare.sh`: UFW 防火墙规则更新器。

## 📄 许可证

本项目基于 MIT 许可证授权。详情请见 [LICENSE](https://www.google.com/search?q=LICENSE) 文件。
