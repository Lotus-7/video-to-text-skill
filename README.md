# Video-to-Text

一键将视频链接转换为校对后的简体中文文本。集成下载、语音转录、文本校对三步工作流，支持多平台视频源。

## 功能特性

### 视频下载 (download.sh)
- 使用 yt-dlp 下载视频，支持 YouTube、Bilibili、抖音等平台
- 自动检测抖音链接，优先使用专用解析器
- 输出标准化的视频文件路径供下游使用

### 语音转录 (transcribe.sh)
- 基于本地 whisper.cpp 进行语音识别
- 自动跳过已转录文件，支持断点续传
- 转录结果输出为同目录下的 `.txt` 文件

### 文本校对 (proofread.sh)
- 简繁体自动检测 (lang_detect.sh)
- 三层词典驱动的文本修正 (text_correct.sh):
  - 繁简转换 (traditional_chars.yaml) -- 台湾技术用语转换
  - 错别字修正 (common_errors.yaml) -- Whisper 转录常见错误
  - 术语纠正 (tech_terms.yaml) -- AI/技术专业术语
- 可选保留原始转录文件备份

### 工作流整合 (workflow.sh)
- 一键执行完整流程: 下载 -> 转录 -> 校对
- 支持多链接批量处理
- 自动汇总处理结果与耗时统计

## 目录结构

```
video-to-text/
├── README.md                    # 项目文档
├── SKILL.md                     # Claude Code 技能定义
├── config.example.yaml          # 配置文件示例
├── scripts/
│   ├── workflow.sh              # 主工作流入口
│   ├── download.sh              # 视频下载模块
│   ├── transcribe.sh            # 语音转录模块
│   ├── proofread.sh             # 文本校对模块
│   └── utils/
│       ├── lang_detect.sh       # 简繁体检测工具
│       └── text_correct.sh      # 词典驱动的文本修正工具
└── references/
    ├── common_errors.yaml       # Whisper 转录常见错别字
    ├── tech_terms.yaml          # AI/技术术语纠正表
    └── traditional_chars.yaml   # 繁简转换规则 (台湾用语)
```

## 使用方式

### 通过 Claude Code

此技能作为 Claude Code skill 运行，在对话中直接说:

```
"把这几个视频转成文本：https://youtube.com/xxx https://bilibili.com/xxx"
"转文本：https://youtube.com/xxx 到 ~/Desktop/output"
```

SKILL.md 中定义了完整的触发规则和执行方式。

### 直接运行脚本

```bash
# 完整工作流
bash scripts/workflow.sh ~/Desktop/output https://youtube.com/watch?v=xxx

# 批量处理
bash scripts/workflow.sh ~/Desktop/output \
  https://youtube.com/watch?v=xxx \
  https://bilibili.com/video/BVxxx

# 单独使用各模块
bash scripts/download.sh ~/Downloads https://youtube.com/watch?v=xxx
bash scripts/transcribe.sh ~/Downloads/video.mp4
bash scripts/proofread.sh ~/Downloads/video.txt ./references true
```

## 配置

复制示例配置并编辑:

```bash
cp config.example.yaml ~/.video-to-text-config.yaml
```

配置项说明:

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `output_dir` | `~/Desktop/video-to-text` | 默认输出目录 |
| `review_mode` | `false` | 是否进入人工审核模式 |
| `keep_original` | `true` | 校对时保留原始转录文件 |
| `generate_report` | `true` | 是否生成校对报告 |
| `max_concurrent_downloads` | `2` | 并发下载数量 |
| `whisper_model` | `medium` | Whisper 模型大小 |
| `traditional_converter` | `builtin` | 简繁转换工具 (opencc/builtin) |

## 依赖

| 依赖 | 用途 | 安装 |
|------|------|------|
| **yt-dlp** | 视频下载 | `brew install yt-dlp` 或 `pip install yt-dlp` |
| **whisper.cpp** | 语音转录 | 参考 [whisper.cpp](https://github.com/ggerganov/whisper.cpp) 编译安装，脚本通过 `$WHISPER_WORKSPACE/transcribe.sh` 调用 |
| **bash 4.0+** | 脚本运行环境 | macOS 自带或通过 Homebrew 安装 |
| **awk** | 字符统计 | 系统自带 |

环境变量:
- `WHISPER_WORKSPACE`: whisper.cpp 工作区路径 (默认: `~/whisper_workspace`)

## 扩展错误词典

三个词典文件位于 `references/` 目录，均为 YAML 格式:

```yaml
# 每行一条规则，格式为 "错误写法": "正确写法"
"错误的词": "正确的词"
```

### 添加新的错别字规则

编辑 `references/common_errors.yaml`:

```yaml
# Whisper 转录常见错误
"卡帕菲": "Karpathy"
"你的新错误": "正确文本"
```

### 添加新的技术术语

编辑 `references/tech_terms.yaml`:

```yaml
# AI/技术术语
"减锁增强生成": "检索增强生成"
"Cloud Code": "Claude Code"
```

### 添加繁简转换规则

编辑 `references/traditional_chars.yaml`:

```yaml
# 台湾用语转换
"软体": "软件"
"程式": "程序"
```

词典变更无需重新编译，下次运行校对时自动生效。所有词典按文件名字母顺序依次加载，后加载的规则会覆盖先加载的。

## 许可证

MIT License
