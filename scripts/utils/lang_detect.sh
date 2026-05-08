#!/bin/bash
set -e -o pipefail

# lang_detect.sh - 简繁体检测工具
# 用途: 检测文本是否包含繁体字
# 参数: $1 = 文本文件路径
# 输出: "traditional" (包含繁体) 或 "simplified" (纯简体) 或 "mixed" (混合)

if [ "$#" -lt 1 ]; then
    echo "错误: lang_detect.sh 需要文本文件路径参数" >&2
    exit 1
fi

TXT_FILE="$1"

if [ ! -f "$TXT_FILE" ]; then
    echo "错误: 文件不存在: $TXT_FILE" >&2
    exit 1
fi

# 常见繁体字列表 (样本检测)
# 这里使用一些高频繁体字作为样本
TRADITIONAL_SAMPLE="個們來過對還時會機樣這麼種樣資專案軟體網路程式資料庫硬碟伺服器滑鼠資料夾"

# 使用 grep 高效统计中文字符总数 (CJK Unified Ideographs 范围)
TOTAL_CHARS=$(grep -o '[一-龥]' "$TXT_FILE" 2>/dev/null | wc -l | tr -d ' ' || true)
TOTAL_CHARS=${TOTAL_CHARS:-0}

# 统计繁体字样本的出现次数
TRAD_COUNT=0
for char in $(echo "$TRADITIONAL_SAMPLE" | grep -o .); do
    COUNT=$(grep -o "$char" "$TXT_FILE" 2>/dev/null | wc -l | tr -d ' ' || true)
    COUNT=${COUNT:-0}
    TRAD_COUNT=$((TRAD_COUNT + COUNT))
done

# 计算繁体字比例
if [ $TOTAL_CHARS -eq 0 ]; then
    echo "simplified"
    exit 0
fi

RATIO=$(awk "BEGIN {printf \"%.2f\", $TRAD_COUNT / $TOTAL_CHARS}")

# 如果繁体字占比超过 1%，判定为包含繁体
if [ $(awk "BEGIN {print ($RATIO > 0.01)}") -eq 1 ]; then
    echo "traditional"
else
    echo "simplified"
fi
