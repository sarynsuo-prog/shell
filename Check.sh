#!/bin/bash

# 显示脚本运行时间
echo "当前时间: $(date)"

# 查看 CPU 使用情况
echo "---------------- CPU 使用情况 ----------------"
top -bn1 | grep "Cpu(s)" | awk '{print "CPU 使用率: " $2 + $4 "%"}'

# 查看内存使用情况
echo "---------------- 内存使用情况 ----------------"
free -m | awk 'NR==2{printf "内存总量: %sMB, 已使用: %sMB, 空闲: %sMB, 使用率: %.2f%%\n", $2,$3,$4,$3*100/$2 }'

# 查看磁盘使用情况
echo "---------------- 磁盘使用情况 ----------------"
df -h | awk '$NF=="/"{printf "根目录磁盘总量: %s, 已使用: %s, 空闲: %s, 使用率: %s\n", $2,$3,$4,$5}'

# 检查 ifstat 是否安装
if ! command -v ifstat &> /dev/null
then
    echo "ifstat 未安装，正在尝试安装..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case $ID in
            ubuntu|debian)
                sudo apt-get update
                sudo apt-get install -y ifstat
                ;;
            centos|rhel)
                sudo yum install -y ifstat
                ;;
            *)
                echo "不支持的系统发行版，无法自动安装 ifstat，请手动安装。"
                exit 1
                ;;
        esac
    else
        echo "无法确定系统发行版，无法自动安装 ifstat，请手动安装。"
        exit 1
    fi
fi

# 查看网络使用情况
echo "---------------- 网络使用情况 ----------------"
ifstat -i eth0 1 1 | awk 'NR==4{printf "网络接口 eth0: 接收速度: %sKB/s, 发送速度: %sKB/s\n", $1,$2}'