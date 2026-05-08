# Video-to-Text 工作流技能

一键将视频链接转换为校对后的简体中文文本。

## 功能特性

- ✅ 视频下载 (支持 YouTube, Bilibili, 抖音等)
- ✅ 语音转录 (使用 Whisper.cpp)
- ✅ 文本校对 (繁简转换 + 错别字修正 + 术语纠正)
- ✅ 批量处理
- ✅ 断点续传
- ✅ Subagent-Driven Development 自动执行

## 技术架构

此技能使用 `superpowers:subagent-driven-development` 模式执行，确保每个任务由独立的子代理完成，包含两阶段审查（规格合规性 + 代码质量）。

## 目录结构

```
video-to-text/
├── SKILL.md              # 技能定义（包含执行指令）
├── scripts/
│   ├── workflow.sh       # 主入口
│   ├── download.sh       # 下载模块
│   ├── transcribe.sh     # 转录模块
│   ├── proofread.sh      # 校对模块
│   └── utils/
│       ├── lang_detect.sh    # 简繁检测
│       └── text_correct.sh   # 文本修正
├── references/
│   ├── common_errors.yaml    # 常见错别字
│   ├── tech_terms.yaml       # 专业术语
│   └── traditional_chars.yaml # 繁简规则
└── outputs/             # 默认输出目录
```

## 依赖

- yt-dlp
- whisper.cpp
- bash 4.0+
- Claude Code with superpowers

## 使用方式

### 通过 Claude Code

```
"把这几个视频转成文本：[链接1] [链接2]"
"转文本：https://youtube.com/xxx 到 ~/Desktop/output"
"转文本并审核：https://bilibili.com/xxx"
```

### 配置

编辑 `~/.video-to-text-config.yaml`:

```yaml
output_dir: ~/Desktop/video-to-text
keep_original: true
generate_report: true
```

## 实现计划

完整的实现计划位于：`docs/superpowers/plans/2025-05-08-video-to-text-workflow.md`

## 许可证

MIT License
