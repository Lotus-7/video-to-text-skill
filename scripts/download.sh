#!/bin/bash

# download.sh - 视频下载模块
# 用途: 使用 yt-dlp 下载视频
# 参数: $1 = 目标目录, $2 = 视频URL
# 输出: 下载的视频文件路径 (stdout) 或错误信息 (stderr, 退出码非0)

set -e -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查参数
if [ "$#" -lt 2 ]; then
    echo "错误: download.sh 需要目标目录和URL参数" >&2
    exit 1
fi

# 检查依赖
if ! command -v yt-dlp &> /dev/null; then
    echo "错误: yt-dlp 未安装" >&2
    exit 1
fi

# 创建目标目录
TARGET_DIR="$1"
URL="$2"

# 记录日志的辅助函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [download] $1"
}

# 创建目标目录
mkdir -p "$TARGET_DIR"

log "开始下载: $URL"

# 检查是否为抖音链接
if [[ "$URL" == *"douyin.com"* ]]; then
    log "检测到抖音链接，使用专用解析器"

    # 调用抖音解析脚本 (如果存在)
    DOUYIN_SCRIPT="$SCRIPT_DIR/utils/douyin_sniffer.py"
    if [ -f "$DOUYIN_SCRIPT" ]; then
        python3 "$DOUYIN_SCRIPT" "$TARGET_DIR" "$URL" 2>&1 | while read -r line; do
            log "$line"
        done

        # 检查 Python 脚本是否成功执行
        DOUYIN_EXIT_CODE=${PIPESTATUS[0]}
        if [ $DOUYIN_EXIT_CODE -ne 0 ]; then
            echo "错误: 抖音解析脚本执行失败 (退出码: $DOUYIN_EXIT_CODE)" >&2
            exit 1
        fi

        # 查找下载的视频文件
        VIDEO_FILE=$(find "$TARGET_DIR" -type f \( -name "*.mp4" -o -name "*.mov" \) -mmin -1 | head -1)
        if [ -n "$VIDEO_FILE" ]; then
            echo "$VIDEO_FILE"
            exit 0
        else
            echo "错误: 抖音视频下载失败" >&2
            exit 1
        fi
    else
        log "警告: 抖音解析脚本不存在，使用 yt-dlp 尝试"
    fi
fi

# 使用 yt-dlp 下载
log "使用 yt-dlp 下载"

# 先获取视频标题 (用于文件名)
TITLE=$(yt-dlp --get-title "$URL" 2>/dev/null || echo "video_$(date +%s)")

# 下载视频
yt-dlp -P "$TARGET_DIR" \
       -o "%(title)s.%(ext)s" \
       --no-mtime \
       --format "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
       "$URL" 2>&1 | while read -r line; do
    # 过滤并简化 yt-dlp 输出
    if echo "$line" | grep -q "\[download\]"; then
        PROGRESS=$(echo "$line" | grep -o '\[download\].*[0-9]*%' | head -1)
        if [ -n "$PROGRESS" ]; then
            log "$PROGRESS"
        fi
    fi
done

# 查找下载的视频文件
VIDEO_FILE=$(find "$TARGET_DIR" -type f -name "*.mp4" -mmin -1 | head -1)

if [ -z "$VIDEO_FILE" ]; then
    # 尝试查找其他视频格式
    VIDEO_FILE=$(find "$TARGET_DIR" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" \) -mmin -1 | head -1)
fi

if [ -z "$VIDEO_FILE" ]; then
    echo "错误: 未找到下载的视频文件" >&2
    exit 1
fi

# 获取文件大小
FILE_SIZE=$(ls -lh "$VIDEO_FILE" | awk '{print $5}')

log "下载完成: $(basename "$VIDEO_FILE") ($FILE_SIZE)"

# 输出视频文件路径
echo "$VIDEO_FILE"
