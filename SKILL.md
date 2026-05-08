---
name: video-to-text
description: 视频转文本工作流。一键完成视频下载、语音转录、文本校对（繁简转换+错别字修正+术语纠正）。支持多链接批量处理，可选人工审核模式。**IMPORTANT: This skill requires subagent-driven-development for execution.**
---

# 📹 视频转文本工作流技能

此技能整合了视频下载、语音转录、文本校对三个步骤，让您的视频内容一键转化为高质量的简体中文文本。

## 执行方式

**当此技能被触发时，必须使用 `superpowers:subagent-driven-development` 执行。**

实现计划位于: `docs/superpowers/plans/2025-05-08-video-to-text-workflow.md`

**执行流程：**
1. 首先调用 `superpowers:subagent-driven-development`
2. 将上述实现计划传递给该技能
3. 按照 subagent-driven-development 的流程执行各任务（共12个任务）

## 🚀 核心功能

1.  **一键处理**：扔链接，得文本
2.  **自动校对**：繁简转换 + 错别字修正 + 专业术语纠正
3.  **批量处理**：支持多个链接同时处理
4.  **可选审核**：全自动模式或人工审核模式
5.  **断点续传**：支持中断后继续处理

## 📖 使用方式

### 基础用法
```
"把这几个视频转成文本：[链接1] [链接2]"
```

### 指定输出目录
```
"转文本：https://youtube.com/xxx 到 ~/Desktop/output"
```

### 审核模式
```
"转文本并审核：https://bilibili.com/xxx"
```

## ⚙️ 配置

配置文件位置：`~/.video-to-text-config.yaml`

```yaml
# 默认输出目录
output_dir: ~/Desktop/video-to-text

# 默认是否进入审核模式
review_mode: false

# 是否保留原始转录文件
keep_original: true

# 是否生成校对报告
generate_report: true

# 并发下载数量
max_concurrent_downloads: 2

# 转录模型 (medium/large/small)
whisper_model: medium

# 简繁转换工具 (opencc/builtin)
traditional_converter: builtin
```

## 📁 文件结构

```
video-to-text/
├── SKILL.md                          # 本文件
├── scripts/
│   ├── workflow.sh                   # 主入口
│   ├── download.sh                   # 下载模块
│   ├── transcribe.sh                 # 转录模块
│   ├── proofread.sh                  # 校对模块
│   └── utils/
│       ├── lang_detect.sh            # 简繁检测
│       └── text_correct.sh           # 文本修正
├── references/
│   ├── common_errors.yaml            # 常见错别字
│   ├── tech_terms.yaml               # 专业术语
│   └── traditional_chars.yaml        # 繁简规则
└── outputs/                          # 默认输出目录
```

## 📚 实现计划

完整的实现计划包含12个任务：
1. 创建技能目录结构和 SKILL.md
2. 创建用户配置文件
3. 创建错误词典文件
4. 创建下载模块 (download.sh)
5. 创建转录模块 (transcribe.sh)
6. 创建简繁检测工具 (lang_detect.sh)
7. 创建文本修正工具 (text_correct.sh)
8. 创建校对模块 (proofread.sh)
9. 创建主工作流入口 (workflow.sh)
10. 端到端测试
11. 完整工作流测试
12. 文档更新和最终提交

计划文件: `docs/superpowers/plans/2025-05-08-video-to-text-workflow.md`

---
> **由小七大人的哆啦A梦精心维护。**
