---
name: video-to-text
description: 视频转文本工作流。一键完成视频下载、语音转录、文本校对（繁简转换+错别字修正+术语纠正）。支持多链接批量处理，可选人工审核模式。
---

# 视频转文本工作流技能

此技能整合了视频下载、语音转录、文本校对三个步骤，让您的视频内容一键转化为高质量的简体中文文本。

## 核心功能

1.  **一键处理**: 扔链接，得文本
2.  **自动校对**: 繁简转换 + 错别字修正 + 专业术语纠正
3.  **批量处理**: 支持多个链接同时处理
4.  **断点续传**: 跳过已转录文件，支持中断后继续

## 使用方式

### 基础用法
```
"把这几个视频转成文本：[链接1] [链接2]"
```

### 指定输出目录
```
"转文本：https://youtube.com/xxx 到 ~/Desktop/output"
```

## 配置

配置文件位置: `~/.video-to-text-config.yaml` (参考 `config.example.yaml`)

```yaml
output_dir: ~/Desktop/video-to-text
review_mode: false
keep_original: true
generate_report: true
max_concurrent_downloads: 2
whisper_model: medium
traditional_converter: builtin
```

## 文件结构

```
video-to-text/
├── README.md                    # 项目文档
├── SKILL.md                     # 本文件
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

## 依赖

- yt-dlp (视频下载)
- whisper.cpp (语音转录，通过 $WHISPER_WORKSPACE/transcribe.sh 调用)
- bash 4.0+

## 扩展词典

编辑 `references/` 目录下的 YAML 文件，格式: `"错误": "修正"`，变更即时生效。
