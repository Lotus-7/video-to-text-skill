#!/bin/bash

# transcribe.sh - 语音转录模块
# 用途: 使用 whisper.cpp 将视频转为文字
# 参数: $1 = 视频文件路径
# 输出: 转录的文本文件路径 (stdout) 或错误信息 (stderr, 退出码非0)

set -e -o pipefail

WHISPER_WORKSPACE="/Users/lotus-7/whisper_workspace"

# 检查参数
if [ "$#" -lt 1 ]; then
    echo "错误: transcribe.sh 需要视频文件路径参数" >&2
    exit 1
fi

VIDEO_FILE="$1"

# 检查文件是否存在
if [ ! -f "$VIDEO_FILE" ]; then
    echo "错误: 视频文件不存在: $VIDEO_FILE" >&2
    exit 1
fi

# 获取视频目录和文件名
VIDEO_DIR="$(dirname "$VIDEO_FILE")"
VIDEO_BASENAME="$(basename "$VIDEO_FILE")"
VIDEO_NAME="${VIDEO_BASENAME%.*}"

# 输出文本文件路径
TXT_FILE="$VIDEO_DIR/$VIDEO_NAME.txt"

# 检查是否已经转录过
if [ -f "$TXT_FILE" ]; then
    echo "$TXT_FILE"
    echo "警告: 转录文件已存在，跳过" >&2
    exit 0
fi

# 记录日志的辅助函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [transcribe] $1"
}

log "开始转录: $VIDEO_BASENAME"

# 调用 whisper 转录脚本
TRANSCRIBE_SCRIPT="$WHISPER_WORKSPACE/transcribe.sh"

if [ ! -f "$TRANSCRIBE_SCRIPT" ]; then
    echo "错误: whisper 转录脚本不存在: $TRANSCRIBE_SCRIPT" >&2
    exit 1
fi

# 执行转录
bash "$TRANSCRIBE_SCRIPT" "$VIDEO_FILE" 2>&1 | while read -r line; do
    # 过滤 whisper 输出，只显示关键信息
    if echo "$line" | grep -qE "(正在提取音频|正在识别|完成|saving|whisper_)"; then
        :
    elif echo "$line" | grep -qE "^[0-9]+$"; then
        # 跳过纯数字输出
        :
    else
        echo "$line" >&2
    fi
done

# 检查转录结果
if [ ! -f "$TXT_FILE" ]; then
    echo "错误: 转录失败，未生成文本文件" >&2
    exit 1
fi

# 获取字数
WORD_COUNT=$(wc -m < "$TXT_FILE" | tr -d ' ')

log "转录完成: $WORD_COUNT 字"

# 输出文本文件路径
echo "$TXT_FILE"
