# 在 niko 仓库中调用 AI Analysis Diagram Factory

## 项目来源与许可

- 上游项目：<https://github.com/wzhoudargon/ai-analysis-diagram-factory>
- 本地副本路径：`resources/ai-analysis-diagram-factory/`
- 上游分支：`main`
- 上游提交 SHA（本次保存时）：`3c05997876ca972d68f63049f4324af7dd409206`
- 许可证：Apache License 2.0，见同目录 `LICENSE`
- 本目录保留上游项目的 README、skill、模板、脚本、示例、文档和许可证。此副本不会自动同步上游更新。

## 最快调用方式

在 Codex 中打开 niko 仓库后，直接输入：

```text
请使用本仓库中的 AI Analysis Diagram Factory：
先阅读 resources/ai-analysis-diagram-factory/skill/SKILL.md 和
resources/ai-analysis-diagram-factory/skill/references/template-index.md，
根据我提供的建筑模型截图、平面图或分析图需求选择合适模板。
严格区分建筑事实来源和风格参考；对现有建筑图像保持几何忠实，
不凭空增加楼层、房间、楼梯、体块或结构。请输出项目事实清单、
模板选择理由、可直接使用的中文提示词、负面约束和结果核查清单。
```

## 生成建筑爆炸轴测图

朱村高速服务区等建筑项目需要爆炸图时，优先调用：

`resources/ai-analysis-diagram-factory/skill/references/templates/architecture-exploded-axonometric-diagram.md`

可直接给 Codex 的任务：

```text
请阅读 resources/ai-analysis-diagram-factory/skill/SKILL.md、
resources/ai-analysis-diagram-factory/skill/references/template-index.md，
以及 resources/ai-analysis-diagram-factory/skill/references/templates/architecture-exploded-axonometric-diagram.md。
基于我提供的最新 SU 模型截图和可用的平面/剖面资料，为当前建筑制作爆炸轴测图方案。
优先保持真实体量、屋顶轮廓、楼板位置、开口和主要交通关系；
资料没有显示的室内细节不得编造。先检查资料并写出可执行方案；
如果要求直接生成图片，生成一张干净、分层对齐、标注克制的建筑爆炸轴测图；
如果要求直接操作 SU 模型，则先备份并使用可复核的脚本流程，不要擅自移动或删除原模型几何。
```

## 让 Codex 自动识别为技能（可选）

把本目录中的 `skill/` 内容复制到 Codex 的用户技能目录。Windows PowerShell 示例（在 niko 仓库根目录运行）：

```powershell
$target = Join-Path $HOME ".codex/skills/ai-analysis-diagram-factory"
New-Item -ItemType Directory -Force $target | Out-Null
Copy-Item -Path "resources/ai-analysis-diagram-factory/skill/*" -Destination $target -Recurse -Force
```

复制后重新打开 Codex，再尝试调用 `$ai-analysis-diagram-factory`。若技能未被识别，仍可使用上面的“最快调用方式”，明确要求 Codex 读取仓库中的 `SKILL.md`。

## 更新上游副本

当前副本是一次性快照，不会自动跟随上游更新。需要更新时，先比较上游仓库与本目录的差异，再同步文件；不要直接覆盖自己在本目录做过的本地修改。
