#!/bin/bash

# proofread.sh - 文本校对模块
# 用途: 检测并修正文本中的繁体字、错别字、术语错误
# 参数: $1 = 文本文件路径, $2 = 词典目录路径, $3 = 是否保留原始文件 (true/false)
# 输出: 校对后的文件路径 (stdout)

set -e -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查参数
if [ "$#" -lt 2 ]; then
    echo "错误: proofread.sh 需要文本文件和词典目录参数" >&2
    exit 1
fi

TXT_FILE="$1"
DICT_DIR="$2"
KEEP_ORIGINAL="${3:-true}"

# 检查文件是否存在
if [ ! -f "$TXT_FILE" ]; then
    echo "错误: 文本文件不存在: $TXT_FILE" >&2
    exit 1
fi

# 记录日志的辅助函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [proofread] $1"
}

log "开始校对: $(basename "$TXT_FILE")"

# 检测简繁
LANG_RESULT=$("$SCRIPT_DIR/utils/lang_detect.sh" "$TXT_FILE")
log "语言检测结果: $LANG_RESULT"

# 备份原始文件
if [ "$KEEP_ORIGINAL" = "true" ]; then
    ORIGINAL_FILE="${TXT_FILE%.*}.original.txt"
    cp "$TXT_FILE" "$ORIGINAL_FILE"
    log "已备份原始文件: $(basename "$ORIGINAL_FILE")"
fi

# 应用文本修正
CORRECTED_CONTENT=$("$SCRIPT_DIR/utils/text_correct.sh" "$TXT_FILE" "$DICT_DIR")

# 写回文件
printf '%s\n' "$CORRECTED_CONTENT" > "$TXT_FILE"

# 统计修正数量
if [ "$KEEP_ORIGINAL" = "true" ] && [ -f "${TXT_FILE%.*}.original.txt" ]; then
    ORIGINAL_SIZE=$(wc -m < "${TXT_FILE%.*}.original.txt" | tr -d ' ')
    NEW_SIZE=$(wc -m < "$TXT_FILE" | tr -d ' ')
    log "校对完成: 原文件 $ORIGINAL_SIZE 字, 新文件 $NEW_SIZE 字"
else
    log "校对完成"
fi

# 输出校对后的文件路径
echo "$TXT_FILE"
