#!/bin/bash

# text_correct.sh - 文本修正工具
# 用途: 应用错误词典修正文本中的错误
# 参数: $1 = 输入文件路径, $2 = 词典目录路径
# 输出: 修正后的文本内容 (stdout)

if [ "$#" -lt 2 ]; then
    echo "错误: text_correct.sh 需要输入文件和词典目录参数" >&2
    exit 1
fi

INPUT_FILE="$1"
DICT_DIR="$2"

if [ ! -f "$INPUT_FILE" ]; then
    echo "错误: 文件不存在: $INPUT_FILE" >&2
    exit 1
fi

if [ ! -d "$DICT_DIR" ]; then
    echo "错误: 词典目录不存在: $DICT_DIR" >&2
    exit 1
fi

# 读取输入文件
CONTENT=$(cat "$INPUT_FILE")

# 加载并应用词典
for yaml_file in "$DICT_DIR"/*.yaml; do
    if [ -f "$yaml_file" ]; then
        # 解析 YAML 文件并应用替换
        # 跳过注释行和空行
        while IFS= read -r line; do
            # 跳过注释和空行
            if [[ "$line" =~ ^[[:space:]]*# ]] || [[ ! "$line" =~ [^[:space:]] ]]; then
                continue
            fi

            # 解析 "key": "value" 格式
            if [[ "$line" =~ ^[[:space:]]*\"([^\"]+)\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
                WRONG="${BASH_REMATCH[1]}"
                CORRECT="${BASH_REMATCH[2]}"

                # Escape special sed characters
                WRONG_ESCAPED=$(echo "$WRONG" | sed 's/[&/\]/\\&/g')
                CORRECT_ESCAPED=$(echo "$CORRECT" | sed 's/[&/\]/\\&/g')
                CONTENT=$(echo "$CONTENT" | sed "s/$WRONG_ESCAPED/$CORRECT_ESCAPED/g")
            fi
        done < "$yaml_file"
    fi
done

# 输出修正后的内容
echo "$CONTENT"
