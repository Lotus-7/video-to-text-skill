#!/bin/bash

# workflow.sh - 视频转文本工作流主入口
# 用途: 整合下载、转录、校对三个步骤
# 参数: $1 = 输出目录, $2... = 视频URL列表

set -e -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
DICT_DIR="$SKILL_DIR/references"

# 默认配置
OUTPUT_DIR="${OUTPUT_DIR:-~/Desktop/video-to-text}"
KEEP_ORIGINAL="${KEEP_ORIGINAL:-true}"

# 加载用户配置
CONFIG_FILE="$HOME/.video-to-text-config.yaml"
if [ -f "$CONFIG_FILE" ]; then
    # 简单解析 YAML 配置 (提取 output_dir)
    OUTPUT_DIR=$(grep "^output_dir:" "$CONFIG_FILE" | sed 's/output_dir:[[:space:]]*//' | sed 's/~/$HOME/' | sed 's/"//g' | sed "s/'//g")
    KEEP_ORIGINAL=$(grep "^keep_original:" "$CONFIG_FILE" | sed 's/keep_original:[[:space:]]*//' | sed 's/"//g' | sed "s/'//g")
fi

# 展开波浪号
OUTPUT_DIR="${OUTPUT_DIR/#\~/$HOME}"

# 检查参数
if [ "$#" -lt 2 ]; then
    cat >&2 << EOF
用法: $0 <输出目录> <URL1> [URL2] ...

示例:
  $0 ~/Desktop/output https://youtube.com/watch?v=xxx
  $0 ~/output https://bilibili.com/video/BVxxx https://youtube.com/watch?v=yyy
EOF
    exit 1
fi

OUTPUT_DIR="$1"
shift
URLS=("$@")

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 记录日志的辅助函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [workflow] $1"
}

# 打印工作流标题
print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📹 视频转文本工作流"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# 打印工作流底部
print_footer() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📁 输出目录: $OUTPUT_DIR"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# 处理单个URL
process_url() {
    local url="$1"
    local index="$2"
    local total="$3"

    echo ""
    echo "[$index/$total] 处理: $url"

    # Step 1: 下载
    log "开始下载..."
    VIDEO_PATH=$("$SCRIPT_DIR/download.sh" "$OUTPUT_DIR" "$url" 2>&1 | tee /dev/stderr | tail -1)

    if [ ! -f "$VIDEO_PATH" ]; then
        log "❌ 下载失败: $url"
        return 1
    fi

    log "✅ 下载完成: $(basename "$VIDEO_PATH")"

    # Step 2: 转录
    log "开始转录..."
    TXT_PATH=$("$SCRIPT_DIR/transcribe.sh" "$VIDEO_PATH" 2>&1 | tee /dev/stderr | tail -1)

    if [ ! -f "$TXT_PATH" ]; then
        log "❌ 转录失败"
        return 1
    fi

    log "✅ 转录完成: $(basename "$TXT_PATH")"

    # Step 3: 校对
    log "开始校对..."
    CORRECTED_PATH=$("$SCRIPT_DIR/proofread.sh" "$TXT_PATH" "$DICT_DIR" "$KEEP_ORIGINAL" 2>&1 | tee /dev/stderr | tail -1)

    if [ ! -f "$CORRECTED_PATH" ]; then
        log "❌ 校对失败"
        return 1
    fi

    log "✅ 校对完成"

    return 0
}

# 主流程
main() {
    local total=${#URLS[@]}
    local success=0
    local failed=0
    local start_time=$(date +%s)

    print_header
    echo "处理 $total 个链接..."
    echo ""

    # 处理每个URL
    for i in "${!URLS[@]}"; do
        index=$((i + 1))
        url="${URLS[$i]}"

        if process_url "$url" "$index" "$total"; then
            success=$((success + 1))
        else
            failed=$((failed + 1))
        fi
    done

    # 计算耗时
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))

    # 打印汇总
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📊 汇总"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  成功: $success/$total"
    if [ $failed -gt 0 ]; then
        echo "  失败: $failed"
    fi
    echo "  总耗时: ${minutes}分${seconds}秒"

    print_footer
}

main
